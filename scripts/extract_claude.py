"""Extract clean digest from Claude CLI JSONL transcript.

Usage: python3 extract_claude.py <session.meta> <output.md>

Reads the .meta file to find the session name, locates the matching
JSONL in ~/.claude/projects/, extracts user+assistant text (skipping
tool_use, thinking, system messages).
"""

import json
import sys
from pathlib import Path


def find_claude_session(meta_path: str) -> Path | None:
    meta = Path(meta_path).read_text()
    session_name = None
    project_dir = None
    for line in meta.splitlines():
        if line.startswith('session_name:'):
            session_name = line.split(':', 1)[1].strip()
        if line.startswith('project_dir:'):
            project_dir = line.split(':', 1)[1].strip()

    if not session_name:
        return None

    claude_dir = Path.home() / '.claude' / 'projects'
    if not claude_dir.exists():
        return None

    candidates = []
    for jsonl in claude_dir.rglob('*.jsonl'):
        try:
            with open(jsonl) as f:
                first_line = f.readline()
                obj = json.loads(first_line)
                if obj.get('sessionName') == session_name:
                    candidates.append(jsonl)
                    continue
                if obj.get('type') == 'summary' and session_name in str(obj):
                    candidates.append(jsonl)
        except (json.JSONDecodeError, KeyError):
            continue

    if not candidates and project_dir:
        safe_path = project_dir.replace('/', '-').strip('-')
        project_claude_dir = claude_dir / safe_path
        if project_claude_dir.exists():
            jsonls = sorted(project_claude_dir.glob('*.jsonl'), key=lambda p: p.stat().st_mtime, reverse=True)
            if jsonls:
                candidates = [jsonls[0]]

    return candidates[0] if candidates else None


def extract_turns(jsonl_path: Path) -> list[dict]:
    turns = []

    with open(jsonl_path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg_type = obj.get('type')

            if msg_type == 'user':
                message = obj.get('message', {})
                content = message.get('content', '')
                if isinstance(content, list):
                    text_parts = [b.get('text', '') for b in content if b.get('type') == 'text']
                    content = '\n'.join(text_parts)
                if isinstance(content, str) and content.strip():
                    turns.append({'type': 'user', 'content': content.strip()})

            elif msg_type == 'assistant':
                message = obj.get('message', {})
                content_blocks = message.get('content', [])
                if isinstance(content_blocks, list):
                    text_parts = [b.get('text', '') for b in content_blocks if b.get('type') == 'text']
                    text = '\n'.join(t for t in text_parts if t.strip())
                    if text.strip():
                        turns.append({'type': 'assistant', 'content': text.strip()})

    return turns


def format_digest(turns: list[dict], meta_path: str, jsonl_path: Path | None) -> str:
    name = Path(meta_path).stem
    parts = name.split('_')
    agent = parts[0] if parts else 'unknown'
    date = parts[1] if len(parts) > 1 else 'unknown'
    time = parts[2].replace('-', ':') if len(parts) > 2 else 'unknown'

    lines = [
        f'# Session Digest: {agent.title()} — {date} {time}',
        '',
        f'**Agent:** {agent.title()}',
        f'**Source:** `{jsonl_path or "not found"}`',
        '',
        '---',
        '',
    ]

    for i, turn in enumerate(turns, 1):
        role = 'Input (user → agent)' if turn['type'] == 'user' else 'Output (agent → user)'
        lines.append(f'## Turn {i}')
        lines.append('')
        lines.append(f'### {role}')
        lines.append('')
        lines.append(turn['content'])
        lines.append('')
        lines.append('---')
        lines.append('')

    return '\n'.join(lines)


def main():
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <session.meta> <output.md>')
        sys.exit(1)

    meta_path = sys.argv[1]
    out_path = sys.argv[2]

    jsonl_path = find_claude_session(meta_path)
    if not jsonl_path:
        print(f'  ⚠ Could not find Claude JSONL for {meta_path}')
        print(f'  Tip: check ~/.claude/projects/ manually')
        Path(out_path).write_text(f'# Session not found\n\nMeta: {meta_path}\n')
        return

    turns = extract_turns(jsonl_path)
    digest = format_digest(turns, meta_path, jsonl_path)
    Path(out_path).write_text(digest)
    print(f'  → {out_path} ({len(turns)} turns)')


if __name__ == '__main__':
    main()
