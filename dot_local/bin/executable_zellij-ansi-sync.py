#!/usr/bin/env python3
"""
matugen post_hook for the zellij theme: splices real 16-color ANSI values
(DMS's dank16 palette, same source as alacritty's dank-theme.toml) into
~/.config/zellij/themes/matugen.kdl's terminal_colors / multiplayer_user_colors.

Why not let matugen's own template render these: Material-You roles
(primary/secondary/tertiary/error) don't carry 16 distinct, well-separated
hues - the approximation looked washed-out/desaturated once actually used
as ANSI color names (zellij's terminal_colors feeds Claude Code's
`ansi:<name>` theme tokens for selection/diff backgrounds). dank16 is
DMS's own base16-style generation from the wallpaper source color and
already looks right in alacritty, so reuse it verbatim instead of
re-deriving a worse approximation.

Fails soft: any problem (file missing, unexpected structure, etc.) leaves
the matugen-rendered file untouched and just prints a warning - a global
Claude Code theme / zellij chrome regression here from a sync hiccup on a
specific machine would be a worse outcome than slightly-off ANSI colors.
"""
import json
import sys
from pathlib import Path

DMS_COLORS = Path.home() / ".cache/dms/dms-colors.json"
ZELLIJ_THEME = Path.home() / ".config/zellij/themes/matugen.kdl"

ANSI_ORDER = [
    "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
    "bright_black", "bright_red", "bright_green", "bright_yellow",
    "bright_blue", "bright_magenta", "bright_cyan", "bright_white",
]
# 10 distinct, non-background/foreground hues for zellij's multiplayer cursors
PLAYER_COLOR_INDEXES = [1, 4, 2, 3, 5, 6, 9, 12, 10, 11]


def hex_to_rgb_triple(hex_color: str) -> str:
    h = hex_color.lstrip("#")
    r, g, b = (int(h[i : i + 2], 16) for i in (0, 2, 4))
    return f"{r} {g} {b}"


def main() -> int:
    try:
        data = json.loads(DMS_COLORS.read_text())
        mode = data["mode"]
        dank16 = data["dank16"]
        rgb_by_index = [hex_to_rgb_triple(dank16[f"color{i}"][mode]) for i in range(16)]
    except Exception as exc:
        print(f"zellij-ansi-sync: skipping, couldn't read {DMS_COLORS}: {exc}", file=sys.stderr)
        return 0

    terminal_colors_lines = "\n".join(
        f"            {name} {rgb_by_index[i]}" for i, name in enumerate(ANSI_ORDER)
    )
    player_lines = "\n".join(
        f"            player_{n} {rgb_by_index[idx]}"
        for n, idx in enumerate(PLAYER_COLOR_INDEXES, start=1)
    )
    block = (
        f"        terminal_colors {{\n{terminal_colors_lines}\n        }}\n"
        f"        multiplayer_user_colors {{\n{player_lines}\n        }}\n"
    )

    try:
        text = ZELLIJ_THEME.read_text()
    except Exception as exc:
        print(f"zellij-ansi-sync: skipping, couldn't read {ZELLIJ_THEME}: {exc}", file=sys.stderr)
        return 0

    closing = "    }\n}\n"
    if not text.endswith(closing):
        print(
            f"zellij-ansi-sync: skipping, {ZELLIJ_THEME} doesn't end with the expected "
            "`matugen {}` / `themes {}` closing braces - template structure changed?",
            file=sys.stderr,
        )
        return 0

    ZELLIJ_THEME.write_text(text[: -len(closing)] + block + closing)
    return 0


if __name__ == "__main__":
    sys.exit(main())
