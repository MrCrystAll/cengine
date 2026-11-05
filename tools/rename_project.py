#!/usr/bin/env python3
"""Rename the project placeholder ("skel") everywhere.

    python tools/rename_project.py <newname> [--old skel] [--dry-run]

Rewrites identifiers in text files and renames files/directories:
    skel -> <new>   (skel::core, skel_add_library, include/skel/, skel-cli)
    Skel -> <New>   (SkelModule.cmake)
    SKEL -> <NEW>   (SKEL_BUILD_TESTS, SKEL_CORE_EXPORT)
Only whole identifiers are matched: "skeleton" is left untouched.
Skips .git/, build/, install/, out/ and vcpkg_installed/.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKIP_DIRS = {".git", "build", "install", "out", "vcpkg_installed", ".vs", ".cache", "__pycache__"}
TEXT_SUFFIXES = {
    ".txt", ".cmake", ".in", ".json", ".md", ".hpp", ".h", ".cpp", ".cc", ".yml", ".yaml",
    ".py", ".clang-format", ".clang-tidy", ".editorconfig", ".gitignore", ".gitattributes", "",
}


def patterns(old: str, new: str) -> list[tuple[re.Pattern[str], str]]:
    variants = [
        (old.lower(), new.lower()),
        (old.capitalize(), new.capitalize()),
        (old.upper(), new.upper()),
    ]
    # Not preceded by a letter, not followed by a lowercase letter (blocks "skeleton").
    return [(re.compile(rf"(?<![A-Za-z]){re.escape(o)}(?![a-z])"), n) for o, n in variants]


def iter_files(root: Path):
    for path in root.rglob("*"):
        if any(part in SKIP_DIRS for part in path.relative_to(root).parts):
            continue
        yield path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("new")
    parser.add_argument("--old", default="skel")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if not re.fullmatch(r"[a-z][a-z0-9]*", args.new):
        parser.error("new name must be lowercase letters/digits, starting with a letter (e.g. 'orbit')")
    if args.new == args.old:
        parser.error("new name equals old name")

    subs = patterns(args.old, args.new)
    changed = 0

    for path in iter_files(ROOT):
        if not path.is_file() or path.resolve() == Path(__file__).resolve():
            continue
        if path.suffix not in TEXT_SUFFIXES and path.name not in TEXT_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        new_text = text
        for rx, repl in subs:
            new_text = rx.sub(repl, new_text)
        if new_text != text:
            changed += 1
            print(f"edit   {path.relative_to(ROOT)}")
            if not args.dry_run:
                path.write_text(new_text, encoding="utf-8", newline="")

    # Rename deepest paths first so parents are still valid.
    to_rename = sorted((p for p in iter_files(ROOT)), key=lambda p: len(p.parts), reverse=True)
    for path in to_rename:
        new_name = path.name
        for rx, repl in subs:
            new_name = rx.sub(repl, new_name)
        if new_name != path.name:
            target = path.with_name(new_name)
            print(f"rename {path.relative_to(ROOT)} -> {target.relative_to(ROOT)}")
            if not args.dry_run:
                path.rename(target)

    print(f"\n{changed} file(s) edited. Delete build/ and re-configure.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
