#!/usr/bin/python3
# -*- coding: utf-8 -*-

# =============================================================================
#
#        FILE:  tree.py
#      AUTHOR:  Tan Duc Mai
#       EMAIL:  tan.duc.work@gmail.com
#     CREATED:  26-Apr-2022
# DESCRIPTION:  Demonstrates how to display a tree of files / directories.
#       USAGE:  python3 tree.py [folder name]
#      SOURCE:  https://github.com/Textualize/rich/blob/master/examples/tree.py
#
# =============================================================================

# ------------------------------- Module Imports ------------------------------
import os
import pathlib
import sys

from rich import print
from rich.filesize import decimal
from rich.markup import escape
from rich.text import Text
from rich.tree import Tree
from rich.console import Console


# ---------------------------- Function Definition ----------------------------
def walk_directory(directory: pathlib.Path, tree: Tree) -> None:
    """Recursively build a Tree with directory contents."""
    # Sort dirs first then by filename
    paths = sorted(
        pathlib.Path(directory).iterdir(),
        key=lambda path: (path.is_file(), path.name.lower()),
    )
    for path in paths:
        # Remove hidden files
        if path.name.startswith("."):
            continue
        if path.is_dir():
            style = "dim" if path.name.startswith("__") else ""
            branch = tree.add(
                f"[bold magenta]:open_file_folder: [link file://{path}]{escape(path.name)}",
                style=style,
                guide_style=style,
            )
            walk_directory(path, branch)
        else:
            text_filename = Text(path.name, "green")
            text_filename.highlight_regex(r"\..*$", "bold red")
            text_filename.stylize(f"link file://{path}")
            file_size = path.stat().st_size
            text_filename.append(f" ({decimal(file_size)})", "blue")
            icon = "🐍 " if path.suffix == ".py" else "📄 "
            tree.add(Text(icon) + text_filename)


# ------------------------------- Main Function -------------------------------
def main():
    try:
        directory = os.path.abspath(sys.argv[1])
    except IndexError:
        print("[b]Usage:[/] python tree.py <DIRECTORY>")
    else:
        tree = Tree(
            f":open_file_folder: [link file://{directory}]{directory}",
            guide_style="bold bright_blue",
        )
        try:
            walk_directory(pathlib.Path(directory), tree)
        except Exception as e:
            Console().print(e, style='red')
        else:
            print(tree)


# --------------------------- Call the Main Function --------------------------
if __name__ == '__main__':
    main()
