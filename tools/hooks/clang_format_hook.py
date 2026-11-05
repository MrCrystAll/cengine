#!/usr/bin/env python3
"""Claude Code PostToolUse hook: run clang-format on a C++ file Claude just edited.

Reads the hook payload (JSON) from stdin. Formats the file in place with the repository's
.clang-format when it is a .cpp/.hpp/.h file inside the project (not in build/ or install/).
Never blocks: any problem (no clang-format, unexpected payload) exits 0 silently.
Wired in .claude/settings.json.
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

CPP_SUFFIXES = {".cpp", ".hpp", ".h", ".cc", ".cxx", ".hxx"}
SKIP_DIRS = {"build", "install", "out", ".git", "vcpkg_installed"}


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return 0

    tool_input = payload.get("tool_input") or {}
    tool_response = payload.get("tool_response") or {}
    raw = tool_input.get("file_path") or tool_response.get("filePath")
    if not raw:
        return 0

    path = Path(raw).resolve()
    root = Path(os.environ.get("CLAUDE_PROJECT_DIR") or Path(__file__).resolve().parents[2]).resolve()
    if path.suffix.lower() not in CPP_SUFFIXES or not path.is_file():
        return 0
    try:
        relative = path.relative_to(root)
    except ValueError:
        return 0  # outside the repository
    if any(part in SKIP_DIRS for part in relative.parts):
        return 0

    clang_format = shutil.which("clang-format")
    if clang_format is None:
        return 0
    subprocess.run([clang_format, "-i", "--style=file", str(path)], cwd=root, check=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
