#!/usr/bin/env python3
"""
matugen post_hook for the Claude Code custom theme (~/.claude/themes/matugen.json):
overwrites selectionBg with DMS's real `primary_container` value instead of
matugen's own Tera-computed one.

Why: matugen's own CLI (no --spec/--contrast flags matching DMS's actual
settings) computes a different primary_container than DMS does for the
same source color - close to black here, nowhere near alacritty's actual
selection background. dms-colors.json already holds DMS's real computed
Material roles (not just the dank16 ANSI palette), so read the exact value
alacritty's own dank-theme.toml was built from instead of re-deriving it.

Fails soft: leaves the matugen-rendered file as-is if anything looks off.
"""
import json
import sys
from pathlib import Path

DMS_COLORS = Path.home() / ".cache/dms/dms-colors.json"
THEME_FILE = Path.home() / ".claude/themes/matugen.json"


def main() -> int:
    try:
        data = json.loads(DMS_COLORS.read_text())
        primary_container = data["colors"][data["mode"]]["primary_container"]
    except Exception as exc:
        print(f"claude-code-theme-sync: skipping, couldn't read {DMS_COLORS}: {exc}", file=sys.stderr)
        return 0

    try:
        theme = json.loads(THEME_FILE.read_text())
    except Exception as exc:
        print(f"claude-code-theme-sync: skipping, couldn't read {THEME_FILE}: {exc}", file=sys.stderr)
        return 0

    theme.setdefault("overrides", {})["selectionBg"] = primary_container
    THEME_FILE.write_text(json.dumps(theme, indent=4) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
