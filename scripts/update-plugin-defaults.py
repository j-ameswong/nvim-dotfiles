"""Snapshot the installed plugins' default/configuration sources at lockfile commits.

Run after :Lazy update. The script refuses to snapshot a checkout that differs
from lazy-lock.json, so the reference beside each plugin spec stays accurate.
"""

import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLUGINS = Path.home() / ".local/share/nvim/lazy"
LOCK = json.loads((ROOT / "lazy-lock.json").read_text())
SOURCES = {
    "blink.cmp": ["lua/blink/cmp/config"],
    "bufferline.nvim": ["lua/bufferline/config.lua"],
    "diffview.nvim": ["lua/diffview/config.lua"],
    "fidget.nvim": ["lua/fidget.lua", "lua/fidget/options.lua", "lua/fidget/progress.lua", "lua/fidget/progress/display.lua", "lua/fidget/progress/lsp.lua", "lua/fidget/notification.lua", "lua/fidget/notification/view.lua", "lua/fidget/notification/window.lua", "lua/fidget/logger.lua"],
    "flash.nvim": ["lua/flash/config.lua"],
    "fzf-lua": ["lua/fzf-lua/defaults.lua"],
    "gitsigns.nvim": ["lua/gitsigns/config.lua"],
    "image.nvim": ["lua/image/init.lua", "lua/image/integrations"],
    "indent-blankline.nvim": ["lua/ibl/config.lua"],
    "kotlin.nvim": ["doc/kotlin.nvim.txt"],
    "lazy.nvim": ["lua/lazy/core/config.lua"],
    "llama.vim": ["doc/llama.txt"],
    "luarocks.nvim": ["README.md"],
    "markview.nvim": ["lua/markview/config", "lua/markview/spec.lua"],
    "mason.nvim": ["lua/mason/settings.lua"],
    "mason-lspconfig.nvim": ["lua/mason-lspconfig/settings.lua"],
    "mini.bufremove": ["lua/mini/bufremove.lua"],
    "mini.indentscope": ["lua/mini/indentscope.lua"],
    "neo-tree.nvim": ["lua/neo-tree/defaults.lua"],
    "neoformat": ["doc/neoformat.txt"],
    "nvim-autopairs": ["lua/nvim-autopairs.lua"],
    "nvim-highlight-colors": ["lua/nvim-highlight-colors/init.lua"],
    "nvim-java": ["lua/java/config.lua", "README.md"],
    "nvim-spectre": ["lua/spectre/config.lua"],
    "nvim-surround": ["lua/nvim-surround/config.lua"],
    "nvim-treesitter": ["lua/nvim-treesitter/config.lua", "README.md"],
    "onedark.nvim": ["lua/onedark/init.lua", "README.md"],
    "rustaceanvim": ["lua/rustaceanvim/config"],
    "ts-autotag.nvim": ["lua/ts-autotag/config.lua"],
    "undotree": ["lua/undotree/config.lua"],
    "vim-fugitive": ["doc/fugitive.txt"],
    "vimtex": ["doc/vimtex.txt"],
}
CONFIG_SOURCES = {
    "appearance/bufferline": ["bufferline.nvim"],
    "appearance/fidget": ["fidget.nvim"],
    "appearance/highlightcolors": ["nvim-highlight-colors"],
    "appearance/image": ["image.nvim"],
    "appearance/indent": ["indent-blankline.nvim", "mini.indentscope"],
    "appearance/markview": ["markview.nvim"],
    "appearance/onedark": ["onedark.nvim"],
    "editing/autopairs": ["nvim-autopairs"],
    "editing/bufremove": ["mini.bufremove"],
    "editing/flash": ["flash.nvim"],
    "editing/neoformat": ["neoformat"],
    "editing/spectre": ["nvim-spectre"],
    "editing/surround": ["nvim-surround"],
    "editing/ts-auto": ["ts-autotag.nvim"],
    "editing/undotree": ["undotree"],
    "git/diffview": ["diffview.nvim"],
    "git/fugitive": ["vim-fugitive"],
    "git/gitsigns": ["gitsigns.nvim"],
    "infrastructure/llama": ["llama.vim"],
    "infrastructure/luarocks": ["luarocks.nvim"],
    "language/blink": ["blink.cmp"],
    "language/kotlin": ["kotlin.nvim"],
    "language/mason": ["mason.nvim", "mason-lspconfig.nvim", "nvim-java"],
    "language/rust": ["rustaceanvim"],
    "language/treesitter": ["nvim-treesitter"],
    "language/vimtex": ["vimtex"],
    "navigation/fzf": ["fzf-lua"],
    "navigation/neotree": ["neo-tree.nvim"],
}


def files_for(repo: Path, entries: list[str]):
    for entry in entries:
        path = repo / entry
        if path.is_dir():
            yield from sorted(path.rglob("*.lua"))
        elif path.is_file():
            yield path
        else:
            raise FileNotFoundError(path)


def main():
    output = ROOT / "plugin-defaults"
    output.mkdir(exist_ok=True)
    for name, entries in SOURCES.items():
        if name not in LOCK:
            continue
        repo = PLUGINS / name
        commit = subprocess.check_output(["git", "-C", str(repo), "rev-parse", "HEAD"], text=True).strip()
        if commit != LOCK[name]["commit"]:
            raise RuntimeError(f"{name}: checkout {commit} does not match lazy-lock.json")
        sections = [
            f"# {name} defaults and configuration source\n",
            f"Commit: `{commit}`\n",
            "These are the upstream configuration sources at the locked commit. "
            "Defaults defined in code are reproduced verbatim; documentation is included "
            "for plugins whose settings are not expressed as one Lua table.\n",
        ]
        for path in files_for(repo, entries):
            relative = path.relative_to(repo)
            contents = path.read_text(errors="replace")
            longest_run = max((len(run) for run in re.findall(r"`+", contents)), default=0)
            fence = "`" * max(3, longest_run + 1)
            language = "lua" if path.suffix == ".lua" else "text"
            sections.append(f"## {relative}\n\n{fence}{language}\n{contents}\n{fence}\n")
        for license_file in sorted(repo.iterdir()):
            if license_file.is_file() and ("license" in license_file.name.lower() or "copying" in license_file.name.lower()):
                license_text = license_file.read_text(errors="replace")
                sections.append(f"## {license_file.name}\n\n```text\n{license_text}\n```\n")
        (output / f"{name}.md").write_text("\n".join(sections))

    for config, names in CONFIG_SOURCES.items():
        path = ROOT / "lua/plugins" / f"{config}.lua"
        body = path.read_text()
        body = "\n".join(line for line in body.splitlines() if not line.startswith("-- Locked defaults: ")) + "\n"
        headers = [f"-- Locked defaults: ../../../plugin-defaults/{name}.md @ {LOCK[name]['commit']}" for name in names]
        path.write_text("\n".join(headers) + "\n" + body)


if __name__ == "__main__":
    main()
