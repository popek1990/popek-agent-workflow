"""Extract clean digest from Gemini CLI sessions.

Handles two formats:
- .script files (terminal capture from sokol-log.sh wrapper)
- .jsonl files (Gemini CLI native logs from ~/.gemini/tmp/)

Usage: python3 extract_gemini.py <input.script|input.jsonl> <output.md>
"""

import json
import re
import sys
from pathlib import Path

ANSI_RE = re.compile(r'\x1b\[[0-9;]*[a-zA-Z]|\x1b\].*?\x07|\x1b\(B')
SPINNER_RE = re.compile(
    r'^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏⠿⠾⠽⠻⠟⠯⠷⠖⠶⠲⠒⠐⠠⠤⠰⠘⠈\s✓✗●○◉◎⬤]+\s*'
    r'(Thinking|Reading|Writing|Searching|Editing|Running|Verifying).*',
    re.UNICODE,
)
TOOL_RE = re.compile(r'^\s*[✓✗]\s+(ReadFile|WriteFile|EditFile|ListDir|SearchFiles|RunCommand|Shell).*')
PROMPT_RE = re.compile(r'^>\s')
SEPARATOR_RE = re.compile(r'^[-─━═]{3,}$')


def strip_ansi(text: str) -> str:
    return ANSI_RE.sub('', text)


def is_noise(line: str) -> bool:
    stripped = line.strip()
    if not stripped:
        return False
    if SPINNER_RE.match(stripped):
        return True
    if TOOL_RE.match(stripped):
        return True
    if stripped.startswith('Tokens:') or stripped.startswith('Context:'):
        return True
    return False


# --- JSONL format (Gemini native) ---

def parse_jsonl(path: Path) -> list[dict]:
    turns: list[dict] = []
    total_input = 0
    total_output = 0
    seen_ids: set[str] = set()

    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            entry_id = obj.get('id')
            if entry_id:
                if entry_id in seen_ids:
                    continue
                seen_ids.add(entry_id)

            entry_type = obj.get('type')

            if entry_type == 'user':
                content = obj.get('content', [])
                if isinstance(content, list):
                    text = '\n'.join(b.get('text', '') for b in content if isinstance(b, dict))
                elif isinstance(content, str):
                    text = content
                else:
                    text = ''
                if text.strip():
                    turns.append({'type': 'user', 'content': text.strip()})

            elif entry_type == 'gemini':
                content = obj.get('content', '')
                tokens = obj.get('tokens', {})
                total_input += tokens.get('input', 0)
                total_output += tokens.get('output', 0)
                thoughts = obj.get('thoughts', [])

                parts: list[str] = []
                if content and content.strip():
                    parts.append(content.strip())
                for t in thoughts:
                    desc = t.get('description', '')
                    if desc.strip():
                        parts.append(f'*[thinking: {desc.strip()}]*')

                if parts:
                    turns.append({
                        'type': 'agent',
                        'content': '\n\n'.join(parts),
                        'tokens': tokens,
                    })

    return turns


# --- Script format (terminal capture) ---

def parse_script(raw_text: str) -> list[dict]:
    lines = raw_text.split('\n')
    turns: list[dict] = []
    current: dict | None = None

    for line in lines:
        clean = strip_ansi(line).rstrip()
        if is_noise(clean):
            continue

        if PROMPT_RE.match(clean):
            if current:
                turns.append(current)
            current = {'type': 'user', 'content': clean[2:].strip()}
        else:
            if current and current['type'] == 'user' and clean.strip():
                turns.append(current)
                current = {'type': 'agent', 'lines': []}

            if current is None or current.get('type') != 'agent':
                if clean.strip():
                    current = {'type': 'agent', 'lines': []}

            if current and current.get('type') == 'agent':
                if not SEPARATOR_RE.match(clean.strip()):
                    current.setdefault('lines', []).append(clean)

    if current:
        turns.append(current)

    result: list[dict] = []
    for turn in turns:
        if 'lines' in turn:
            content = '\n'.join(turn['lines']).strip()
            if content:
                result.append({'type': turn['type'], 'content': content})
        elif turn.get('content', '').strip():
            result.append(turn)

    return result


# --- Digest formatting ---

def format_digest(turns: list[dict], source_file: str) -> str:
    name = Path(source_file).stem
    parts = name.split('_')
    agent = parts[0] if parts else 'sokol'
    date = parts[1] if len(parts) > 1 else name
    time_str = parts[2].replace('-', ':') if len(parts) > 2 else ''

    header_lines = [
        f'# Session Digest: {agent.title()} — {date} {time_str}',
        '',
        f'**Agent:** {agent.title()}',
        f'**Source:** `{source_file}`',
        f'**Turns:** {len([t for t in turns if t.get("content", "").strip()])}',
        '',
        '---',
        '',
    ]

    turn_num = 0
    for turn in turns:
        content = turn.get('content', '').strip()
        if not content:
            continue
        turn_num += 1
        role = 'Input (user → agent)' if turn['type'] == 'user' else 'Output (agent → user)'
        header_lines.append(f'## Turn {turn_num}')
        header_lines.append('')
        header_lines.append(f'### {role}')
        header_lines.append('')
        header_lines.append(content)
        header_lines.append('')
        header_lines.append('---')
        header_lines.append('')

    return '\n'.join(header_lines)


def main() -> None:
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <input.script|input.jsonl> <output.md>')
        sys.exit(1)

    input_path = sys.argv[1]
    out_path = sys.argv[2]
    path = Path(input_path)

    if path.suffix == '.jsonl':
        turns = parse_jsonl(path)
    else:
        raw_text = path.read_text(errors='replace')
        turns = parse_script(raw_text)

    digest = format_digest(turns, input_path)
    Path(out_path).write_text(digest)
    print(f'  → {out_path} ({len(turns)} turns)')


if __name__ == '__main__':
    main()
