---
name: refresh-clangd-db
description: Regenerates Unreal compile_commands.json with UBT GenerateClangDatabase and restarts clangd. Use when the user asks to 更新 Clang 数据库, 生成 compile_commands, 刷新 clangd, 或 after adding/removing C++ files or changing Build.cs.
---

# Refresh Clang Database

Regenerate this project's Clang compilation database, then restart clangd so Alt+O / F12 pick up new files.

## When to run

Agent edits to `Source/**/*.h` / `.cpp` are also refreshed by `.cursor/hooks.json` (`afterFileEdit`). Ctrl+Shift+B runs generate after a Cursor build. Opening the folder runs generate once.

When the user explicitly asks, still follow the steps below.

## Steps

1. Working directory: `E:\Dev\UE\Warrior` (the Warrior folder if this is a multi-root workspace).

2. Run (wait until it finishes; usually a few seconds):

```powershell
& "D:\Applications\UE_5.7\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe" -mode=GenerateClangDatabase -project="E:\Dev\UE\Warrior\Warrior.uproject" WarriorEditor Win64 Development -OutputDir="E:\Dev\UE\Warrior"
```

Success looks like: `ClangDatabase written to E:\Dev\UE\Warrior\compile_commands.json` and `Result: Succeeded`.

3. Confirm `compile_commands.json` exists at the project root and is non-empty.

4. Restart clangd: stop running `clangd` processes so the extension relaunches them.

```powershell
Get-Process -Name clangd -ErrorAction SilentlyContinue | Stop-Process -Force
```

5. Tell the user: if Problems / Alt+O still look stale, open a `.cpp` and run **clangd: Restart language server** (Ctrl+Shift+P). The agent cannot press that command itself.

Do not commit `compile_commands.json`. Do not run a full game build unless asked.
