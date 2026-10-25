# Hades II 作弊菜单（macOS）

把 [PonyMenu](https://github.com/PonyWarrior/PonyMenu) 的界面体系搬到 macOS 版《Hades II》，并对菜单结构、卡片样式、作弊页做了大量重做。

> 适用版本：Hades II 1.143476（Steam / macOS / Apple Silicon）
> 依赖：官方 [modimporter](https://github.com/SGG-Modding/sgg-mod-modimporter)（arm64 原生，安装脚本自动下载）

---

## 菜单总览（共 30 个入口）

游戏内按 `I` 打开背包 → 切到幻驹菜单，从上到下、从左到右排列：

| # | 入口 | 类型 | 打开后能做什么 |
|---|---|---|---|
| 1 | **祝福管理器** | 面板 | 局内已有祝福的统一管理（见下节） |
| 2 | 代达罗斯之锤 | 祝福页 | 选稀有度 → 点卡片直接获得该武器强化 |
| 3–15 | 赫菲斯托斯 / 得墨忒尔 / 波塞冬 / 赫斯提亚 / 宙斯 / 阿佛洛狄忒 / 阿瑞斯 / 阿波罗 / 阿尔忒弥斯 / 赫尔墨斯 / 赫拉 / 卡俄斯 / 法术 | 祝福页 | 按神分类的祝福清单 |
| 16–24 | 阿拉克涅 / 纳西索斯 / 厄科 / 美狄亚 / 伊卡洛斯 / 喀耳刻 / 雅典娜 / 狄俄尼索斯 / 哈迪斯 | 祝福页 | NPC 系祝福 |
| 25 | **材料菜单** | 面板 | 选材料 → `+1/+10/+100/+1000` 或 `-1/-10/-100/-1000`，再点「生成材料」 |
| 26 | **额外修改内容** | 面板 | 11 项作弊开关/动作（见下节） |
| 27 | 清除所有祝福 | 动作 | 一次性移除当前所有祝福 |
| 28 | 自杀 | 动作 | 立即死亡（回三岔路口） |
| 29 | 存入套装 | 动作 | 保存当前祝福组合 |
| 30 | 加载套装 | 动作 | 载入已保存的祝福组合 |

---

## 1. 祝福管理器

针对**局内已拥有**的祝福逐一操作，两种模式：

| 模式 | 加 | 减 |
|---|---|---|
| 等级（Level） | 等级 +1（上限 100） | 等级 −1 |
| 稀有度（Rarity） | 普通 → 稀有 → 史诗 → 英雄 → 传说 | 反向降级 |

也支持"全体模式"一次处理所有可升级项，以及"删除"模式清除全部祝福。

本仓库对上游的修复：**改稀有度后保持该祝福在原位置**（原实现删掉再重加，会跳到列表末尾）。

## 2. 祝福页（23 个入口）

锤子 + 各神 + 各 NPC 各占一个入口，打开后是该分类的完整祝福清单：

- 卡片样式与祝福选择器一致：图标 + 标题 + 效果描述 + 右侧稀有度；
- 顶部可切换稀有度（普通/稀有/史诗/英雄/传奇），切换后整页卡片按该稀有度重算数值；
- 点卡片直接把该祝福加给角色（技能类会自动处理法术槽替换）；
- 卡多时用左右箭头翻页（`MenuLeft/MenuRight` 热键同样可用）。

## 3. 材料菜单

从背包的资源分类中列出所有材料，选中后用底部 `+1/+10/+100/+1000`、`-1/-10/-100/-1000` 调整数量，再点「生成材料」发放到背包。全部材料已内置中文名。

第一格是**重掷点数**（游戏里它不是资源条目，是本 mod 单独加的一项）：选中它 +N 再生成，直接把本局的重掷骰子数改成当前值 +N，HUD 立即刷新；减到 0 也不会出现负数。

## 4. 额外修改内容（11 项）

布局与祝福选择器一致：卡片 + 名称 + 说明 + 右侧状态（开关显示绿「开」/灰「关」，档位显示 `+1…+4`）。

| # | 功能 | 类型 | 说明 |
|---|---|---|---|
| 1 | 采集不需要工具 | 开关 | 采集点不再检查镐/铲/钓竿 |
| 2 | 必出混沌门 | 开关 | 出口必定出现混沌之门 |
| 3 | 无限重掷 | 开关 | 重掷不消耗次数 |
| 4 | 击杀掉祝福 | 开关 | 每次开启叠加 1% 击杀掉落祝福概率 |
| 5 | 不出资源房间 | 开关 | 房间奖励池剔除纯资源房间 |
| 6 | 必定英雄稀有度 | 开关 | 祝福强制 Heroic |
| 7 | 额外冲刺 | 档位 | 点一次升一档：`+1 → +2 → +3 → +4 → 关`（对应 普通/稀有/史诗/英雄） |
| 8 | 金币 +100 | 动作 | 立即获得 100 金币 |
| 9 | 给我恢复 | 动作 | 回满生命 |
| 10 | 给我充能 | 动作 | 魔力回满 |
| 11 | 法力倾泻 | 动作 | 把当前魔力清零 |

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
4. 运行 `modimporter --game Hades2`，把 `Import` 行写入 `Scripts/Main.lua`、`Scripts/RoomLogic.lua`、`Scripts/ResourceData.lua`。

### 游戏内怎么打开

```
按 I 打开背包 → 切到幻驹菜单（左栏最后一个分类） → 选择要用的入口
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

- **每次游戏更新后需要重新运行 `install.sh`**（更新会覆盖被修补的 Lua 文件）。脚本已做幂等处理（先删旧 Mods 再复制）。
- 开关的 **开/关状态是本 mod 自己记录的**（`SessionState.CheatToggles`），原版游戏不提供状态查询；重新读档后界面会显示"关"但游戏内补丁可能仍在，**以实际效果为准**。
- 额外冲刺的档位切换会先 `RemoveWeaponTrait("CheatExtraRush")` 再按新稀有度重加（该 trait 带 `BlockStacking`，不这样处理无法改档）。
- 仅支持 **macOS / Apple Silicon**。Windows 请直接用 [Hell2Modding](https://github.com/SGG-Modding/Hell2Modding) + 原版 [PonyMenu](https://github.com/PonyWarrior/PonyMenu)。

## 目录结构

```
Mods/
├── ModUtil/      # SGG-Modding/ModUtil，纯 Lua 的 mod 框架
├── PonyMenu/     # 界面体系（本仓库做了大量修改）
│   ├── Data/ScreenData.lua      # 30 个菜单入口 / 作弊菜单数据
│   ├── Scripts/MenuScripts.lua  # 作弊页渲染 + 分页 + 悬停高亮 + 祝福管理器
│   ├── core.lua                 # 命令分发修复 / 稀有度原位修改 / 物品名表
│   └── Text/zh-CN.lua           # 中文文案
└── CheatMenu/    # 具体作弊逻辑（_cheat.lua，原样保留）
```

## 相对上游的改动

- 修复 `mod.Command` 无法解析 `"PonyMenu.Xxx"` 这类带点函数名导致菜单崩溃的问题；
- 补上缺失的 `ExtraSelectorLoadPage`，并把作弊页从"刷怪按钮"皮肤换成祝福选择器同款卡片页（含原生分页、状态列、悬停反馈）；
- 祝福管理器改稀有度时**保持列表位置**（原实现是删除后重加，会跳到末尾）；
- 物品选择器补全 54 项中文名 + 效果描述（该入口已按需求从菜单移除，代码保留）；
- 主菜单悬停使用游戏原生的 `InventoryScreenSlotIn` 青色描边，并修复关屏后高亮残留；
- 菜单排序按使用频率重排（祝福管理器第 1、锤子第 2，命令集中在末尾）。

## 许可与致谢

本仓库包含/修改了以下第三方代码，版权归各自作者：

| 项目 | 作者 | 许可 |
|---|---|---|
| [PonyMenu](https://github.com/PonyWarrior/PonyMenu) | PonyWarrior | MIT |
| [ModUtil](https://github.com/SGG-Modding/ModUtil) | SGG-Modding | 见上游 |
| [hades2ModPonyMenu / CheatMenu](https://github.com/liwenhao0427/hades2ModPonyMenu) | liwenhao0427 | 见上游 |
| [modimporter](https://github.com/SGG-Modding/sgg-mod-modimporter) | SGG-Modding | 见上游 |

本仓库自身的修改同样以 MIT 发布。仅用于单机游戏自娱，请勿用于联机或传播游戏本体文件。
