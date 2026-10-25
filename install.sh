#!/usr/bin/env bash
# Hades II 作弊菜单（macOS）安装脚本
# 作用：把 Mods/ 复制进游戏包，并用官方 modimporter 打补丁
set -euo pipefail

CONTENT="/Applications/Hades II.app/Contents/Resources/Content"
MODIMPORTER_VERSION="1.6.1"

if [ ! -d "$CONTENT" ]; then
  echo "找不到游戏目录：$CONTENT"
  echo "请确认 Hades II 安装在 /Applications 下"
  exit 1
fi

if pgrep -f "Hades II" > /dev/null 2>&1; then
  echo "游戏正在运行，请先完全退出 Hades II（不是回主菜单）"
  exit 1
fi

echo "==> 备份现有 Scripts"
STAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p "$HOME/hades2-mod-backup"
tar czf "$HOME/hades2-mod-backup/Scripts-$STAMP.tgz" -C "$CONTENT" Scripts
echo "    备份完成: $HOME/hades2-mod-backup/Scripts-$STAMP.tgz"

echo "==> 安装 modimporter（如缺失）"
if [ ! -x "$CONTENT/modimporter" ]; then
  TMP=$(mktemp -d)
  curl -L -o "$TMP/modimporter-macos.zip" \
    "https://github.com/SGG-Modding/sgg-mod-modimporter/releases/download/${MODIMPORTER_VERSION}/modimporter-macos.zip"
  unzip -q "$TMP/modimporter-macos.zip" -d "$TMP"
  cp "$TMP/modimporter" "$CONTENT/modimporter"
  chmod +x "$CONTENT/modimporter"
  rm -rf "$TMP"
fi

echo "==> 复制 Mods"
mkdir -p "$CONTENT/Mods"
for m in PonyMenu CheatMenu ModUtil; do
  rm -rf "$CONTENT/Mods/$m"
  cp -R "Mods/$m" "$CONTENT/Mods/$m"
done

echo "==> 运行 modimporter"
(cd "$CONTENT" && ./modimporter --game Hades2 --no-input)

echo
echo "安装完成。启动游戏后：按 I 打开背包 → 切到幻驹菜单 → 点『额外修改内容』。"
echo "卸载：bash uninstall.sh"
