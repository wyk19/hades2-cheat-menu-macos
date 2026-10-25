# Hades II 作弊菜单（macOS）

把 [PonyMenu](https://github.com/PonyWarrior/PonyMenu) 的界面体系搬到 macOS 版《Hades II》上，并把原本"刷怪调试界面"风格的作弊页重做成**和祝福选择器一致**的卡片菜单。

> 适用版本：Hades II 1.143476（Steam, macOS / Apple Silicon）
> 依赖：官方 [modimporter](https://github.com/SGG-Modding/sgg-mod-modimporter)（arm64 原生，安装脚本会自动下载）

---

## 功能

作弊页共 **11 项**，布局与祝福选择器一致（卡片 + 名称 + 说明 + 右侧状态）：

| # | 功能 | 类型 | 说明 |
|---|---|---|---|
| 1 | 采集不需要工具 | 开关 | 采集点不再检查镐/铲/钓竿 |
| 2 | 必出混沌门 | 开关 | 出口必定出现混沌之门 |
| 3 | 无限重掷 | 开关 | 重掷不消耗次数 |
| 4 | 击杀掉祝福 | 开关 | 每次开启叠加 1% 击杀掉落祝福概率 |
| 5 | 不出资源房间 | 开关 | 房间奖励池剔除纯资源房间 |
| 6 | 必定英雄稀有度 | 开关 | 祝福强制 Heroic |
| 7 | 额外冲刺 | 档位 | 点一次升一档：`+1 → +2 → +3 → +4 → 关`（对应 普通/稀有/史诗/英雄 稀有度） |
| 8 | 金币 +100 | 动作 | 立即获得 100 金币 |
| 9 | 给我恢复 | 动作 | 回满生命 |
| 10 | 给我充能 | 动作 | 魔力回满 |
| 11 | 法力倾泻 | 动作 | 把当前魔力清零 |

- 开关类卡片右侧显示 **绿色「开」/ 灰色「关」**；档位类显示 `+1 / +2 / +3 / +4 / 关`。
- 悬停沿用祝福卡片的音效与放大反馈。
- 翻页复用祝福选择器的原生实现（`BoonManagerPageButtons` + `MenuLeft/MenuRight` 热键）。

## 安装（macOS）

```bash
# 1. 完全退出游戏
git clone https://github.com/wyk19/hades2-cheat-menu-macos.git
cd hades2-cheat-menu-macos
bash install.sh
```

脚本会：

1. 把 `Content/Scripts` 备份到 `~/hades2-mod-backup/`；
2. 如缺失则下载官方 `modimporter-macos.zip`（arm64）；
3. 把 `Mods/{PonyMenu,CheatMenu,ModUtil}` 复制进游戏包；
4. 运行 `modimporter --game Hades2`，把 mod 的 `Import` 行写入 `Scripts/Main.lua`、`Scripts/RoomLogic.lua`、`Scripts/ResourceData.lua`。

### 游戏内怎么打开

```
按 I 打开背包 → 切到幻驹菜单（左栏最后一个分类） → 点「额外修改内容」
```

## 卸载

```bash
bash uninstall.sh
```

或手动恢复安装时的备份：

```bash
tar xzf ~/hades2-mod-backup/Scripts-*.tgz -C "/Applications/Hades II.app/Contents/Resources/Content"
```

## 注意事项

- **每次游戏更新后需要重新运行 `install.sh`**（更新会覆盖被修补的 Lua 文件）。modimporter 会重复打补丁，脚本已做幂等处理（先删旧 Mods 再复制）。
- 开关的 **开/关状态是本 mod 自己记录的**（`SessionState.CheatToggles`），原版游戏不提供状态查询；重新读档后界面会显示"关"但游戏内补丁可能仍在，**以实际效果为准**。
- 额外冲刺的档位切换会先 `RemoveWeaponTrait("CheatExtraRush")` 再按新稀有度重加（该 trait 带 `BlockStacking`，不这样处理无法改档）。
- 仅支持 **macOS / Apple Silicon**。Windows 请直接用 [Hell2Modding](https://github.com/SGG-Modding/Hell2Modding) + 原版 [PonyMenu](https://github.com/PonyWarrior/PonyMenu)。

## 目录结构

```
Mods/
├── ModUtil/      # SGG-Modding/ModUtil，纯 Lua 的 mod 框架
├── PonyMenu/     # 界面体系（本仓库做了大量修改）
│   ├── Data/ScreenData.lua      # 菜单项顺序 / 作弊菜单数据
│   ├── Scripts/MenuScripts.lua  # 作弊菜单渲染 + 分页 + 悬停高亮
│   ├── core.lua                 # 物品名表 / 命令分发修复 / 稀有度原位修改
│   └── Text/zh-CN.lua           # 中文文案
└── CheatMenu/    # 具体作弊逻辑（_cheat.lua，原样保留）
```

## 相对上游的改动

- 修复 `mod.Command` 无法解析 `"PonyMenu.Xxx"` 这类带点函数名导致菜单崩溃的问题；
- 补上缺失的 `ExtraSelectorLoadPage`，并重做为祝福选择器同款卡片页；
- 祝福管理器改稀有度时**保持列表位置**（原实现是删除后重加，会跳到末尾）；
- 物品选择器补全 54 项中文名 + 效果描述；
- 主菜单悬停使用游戏原生的 `InventoryScreenSlotIn` 青色描边，并修复关屏后高亮残留；
- `CheatMenu` 的作弊页从"刷怪按钮"皮肤换成祝福选择器皮肤。

## 许可与致谢

本仓库包含/修改了以下第三方代码，版权归各自作者：

| 项目 | 作者 | 许可 |
|---|---|---|
| [PonyMenu](https://github.com/PonyWarrior/PonyMenu) | PonyWarrior | MIT |
| [ModUtil](https://github.com/SGG-Modding/ModUtil) | SGG-Modding | 见上游 |
| [hades2ModPonyMenu / CheatMenu](https://github.com/liwenhao0427/hades2ModPonyMenu) | liwenhao0427 | 见上游 |
| [modimporter](https://github.com/SGG-Modding/sgg-mod-modimporter) | SGG-Modding | 见上游 |

本仓库自身的修改同样以 MIT 发布。仅用于单机游戏自娱，请勿用于联机或传播游戏本体文件。
