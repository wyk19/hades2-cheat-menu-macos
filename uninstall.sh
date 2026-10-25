#!/usr/bin/env bash
# Hades II 作弊菜单（macOS）卸载脚本
# 作用：清理 modimporter 打过的补丁，并删除 Mods
set -euo pipefail

CONTENT="/Applications/Hades II.app/Contents/Resources/Content"

if [ ! -d "$CONTENT" ]; then
  echo "找不到游戏目录：$CONTENT"
  exit 1
fi

if pgrep -f "Hades II" > /dev/null 2>&1; then
  echo "游戏正在运行，请先完全退出 Hades II"
  exit 1
fi

echo "==> 清理 modimporter 补丁"
if [ -x "$CONTENT/modimporter" ]; then
  (cd "$CONTENT" && ./modimporter --clean --game Hades2 --no-input) || true
fi

echo "==> 删除 Mods"
rm -rf "$CONTENT/Mods/PonyMenu" "$CONTENT/Mods/CheatMenu" "$CONTENT/Mods/ModUtil"

echo "完成。如需彻底恢复，可用安装时生成的备份："
echo "  tar xzf ~/hades2-mod-backup/Scripts-*.tgz -C \"$CONTENT\""
