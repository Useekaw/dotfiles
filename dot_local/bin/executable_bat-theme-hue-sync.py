#!/usr/bin/env python3
"""
matugen post_hook for bat's custom theme (~/.config/bat/themes/matugen.tmtheme):
substitutes the ~8 original gruvbox-material hue accents (string/function/
constant/error colors etc) with DMS's real dank16 palette, same source as
alacritty's dank-theme.toml.

Why: bat.tmtheme's background/foreground/comment/selection roles come
straight from matugen's own Material-You scheme (verified byte-identical
to DMS's values for those specific roles). But there's no reliable
Material role for "green" or "pink" on every wallpaper (this source color
collapses secondary and tertiary into the same orange, for instance), so
the few scopes that need real hue diversity (strings, functions, constants,
...) are left as their original static gruvbox-material hex in the
template and swapped here for the matching dank16 slot instead.

Fails soft: leaves the original gruvbox-material hues in place (a
perfectly reasonable static fallback) if dms-colors.json is missing.
"""
import json
import sys
from pathlib import Path

DMS_COLORS = Path.home() / ".cache/dms/dms-colors.json"
THEME_FILE = Path.home() / ".config/bat/themes/matugen.tmtheme"

# original gruvbox-material hex -> dank16 slot to replace it with
HUE_REPLACEMENTS = {
    "#ea6962": "color9",  # red, main (keywords/storage/...)
    "#c14a4a": "color1",  # red, darker punctuation variant
    "#89b482": "color10",  # green, light (operators/functions/hyperlinks)
    "#4f8062": "color2",  # green, darker (method-call punctuation)
    "#a9b665": "color2",  # green, olive (strings/entities/...)
    "#d8a657": "color11",  # yellow, main (entities/warnings/...)
    "#b47109": "color3",  # yellow, darker punctuation variant
    "#728a1c": "color3",  # yellow, olive-dark (punctuation)
    "#d3869b": "color13",  # pink/magenta, main
    "#945e80": "color5",  # pink/magenta, darker punctuation variant
}


def main() -> int:
    try:
        data = json.loads(DMS_COLORS.read_text())
        mode = data["mode"]
        dank16 = data["dank16"]
    except Exception as exc:
        print(f"bat-theme-hue-sync: skipping, couldn't read {DMS_COLORS}: {exc}", file=sys.stderr)
        return 0

    try:
        text = THEME_FILE.read_text()
    except Exception as exc:
        print(f"bat-theme-hue-sync: skipping, couldn't read {THEME_FILE}: {exc}", file=sys.stderr)
        return 0

    for old_hex, slot in HUE_REPLACEMENTS.items():
        try:
            new_hex = dank16[slot][mode]
        except Exception as exc:
            print(f"bat-theme-hue-sync: skipping {old_hex} -> {slot}: {exc}", file=sys.stderr)
            continue
        text = text.replace(old_hex, new_hex)

    THEME_FILE.write_text(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
