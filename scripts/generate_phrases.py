#!/usr/bin/env python3
"""
DEPRECATED / PERMANENTLY DISABLED

Greek Pantomime Synthetic Phrase Generator.

This script has been permanently disabled. All game phrases are now sourced
exclusively from `frases100000.txt` via `scripts/process_phrases.py`.

Do NOT generate synthetic phrases. Use `scripts/process_phrases.py` instead.
"""

import sys


def main():
    print(
        "ERROR: Synthetic phrase generation is permanently disabled.\n"
        "All game phrases are sourced directly from `frases100000.txt`.\n"
        "Please use `python3 scripts/process_phrases.py` instead.",
        file=sys.stderr,
    )
    sys.exit(1)


if __name__ == "__main__":
    main()
