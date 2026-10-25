local mod = PonyMenu

if not mod.Config.Enabled then return end

local function setupMainData()
	mod.CurrentLocale = GetLanguage()
	mod.Locale = setmetatable({}, {
		__index = function(_, k)
			return mod.GetLanguageString(k)
		end
	})

	mod.BoonData = {
		DiyTraitData = {},
		ZeusUpgrade = {},
		PoseidonUpgrade = {},
		AphroditeUpgrade = {},
		AresUpgrade = {},
		ApolloUpgrade = {},
		DemeterUpgrade = {},
		HephaestusUpgrade = {},
		HestiaUpgrade = {},
		ArtemisUpgrade = {},
		HermesUpgrade = {},
		HeraUpgrade = {},
		TrialUpgrade = {},
		SpellDrop = {},
		WeaponUpgrade = {},
		NPC_Arachne_01 = {},
		NPC_Narcissus_01 = {},
		NPC_Echo_01 = {},
		NPC_LordHades_01 = {},
		NPC_Medea_01 = {},
		NPC_Icarus_01 = {},
		NPC_Circe_01 = {},
		NPC_Athena_01 = {},
		NPC_Dionysus_01 = {}
	}

	mod.ConsumableData = {
		-- "HealDrop",
		-- "RoomMoneyDrop",
		-- "MaxHealthDrop",
		-- "MaxManaDrop",
		-- "TalentDrop",
		-- "RerollDrop",
		-- "LastStandDrop",
		-- "MinorDodgeDrop",
		-- "MinorDamageBoost",
		-- "HitShieldDrop",
		-- "ArmorBoost",
		-- "FireBoost",
		-- "AirBoost",
		-- "EarthBoost",
		-- "WaterBoost",
		-- "ElementalBoost",
		-- "MinorExDamageBoost",
	}
end

function mod.UpdateScreenData()
	if mod.CurrentLocale ~= GetLanguage() then
		mod.CurrentLocale = GetLanguage()
		mod.setupScreenData()
		mod.setupCommandData()
	end
end

-- Is it possible this could be done with ModUtil.Path.Context.Wrap?
ModUtil.Path.Override("InventoryScreenDisplayCategory", function(screen, categoryIndex, args)
	args = args or {}
	local components = screen.Components

	-- Cleanup prev category
	local prevCategory = screen.ItemCategories[screen.ActiveCategoryIndex]
	--Mod start
	if prevCategory == nil then
		prevCategory = screen.ItemCategories[1]
	end
	-- Mod end
	if prevCategory.CloseFunctionName ~= nil then
		CallFunctionName( prevCategory.CloseFunctionName, screen )
	else
		for i, resourceName in ipairs( prevCategory ) do
			local resourceComponent = components[resourceName]
			if resourceComponent ~= nil then
				if resourceComponent.NewIcon ~= nil then
					Destroy({ Id = resourceComponent.NewIcon.Id })
				end
				-- Mod start
				if resourceComponent.Highlight ~= nil then
					Destroy({ Id = resourceComponent.Highlight.Id })
				end
				-- Mod end
				Destroy({ Id = resourceComponent.Id })
			end
		end
	end

	ModifyTextBox({ Id = components.InfoBoxName.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDescription.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDetails.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxFlavor.Id, FadeTarget = 0.0, })
	if screen.Components["Category"..prevCategory.Name] ~= nil then
		StopAnimation({ DestinationId = screen.Components["Category"..prevCategory.Name].Id, Name = "InventoryTabHighlightActiveCategory" })
	end

	local category = screen.ItemCategories[categoryIndex]
	if category.Locked then
		return
	end
	local slotName = category.Name

	-- Highlight new category
	CreateAnimation({ DestinationId = screen.Components["Category"..slotName].Id, Name = "InventoryTabHighlightActiveCategory", Group = "Combat_Menu_TraitTray" })
	ModifyTextBox({ Id = screen.Components.CategoryTitleText.Id, Text = category.Name })

	local newButtonKey = "NewIcon"..slotName
	if components[newButtonKey] ~= nil then
		Destroy({ Id = components[newButtonKey].Id })
	end

	--Mod Start
	if category.Name == "PONYMENU" or category.Name == "Pony Menu" then
		ModifyTextBox({ Id = screen.Components.CategoryTitleText.Id, Text = mod.Locale.PonyMenuCategoryTitle })
	else
		ModifyTextBox({ Id = screen.Components.CategoryTitleText.Id, Text = category.Name })
	end
	--Mod end

	screen.ActiveCategoryIndex = categoryIndex

	screen.CloseAnimation = category.CloseAnimation
	if args.FirstOpen then
		SetAnimation({ DestinationId = components.Background.Id, Name = category.OpenAnimation })
	else
		local fromMap = screen.TransitionAnimationMap[prevCategory.CloseAnimation]
		-- Mod start
		local transitionAnimationName
		if fromMap ~= nil then
			transitionAnimationName = fromMap[category.CloseAnimation]
		end
		-- Mod end
		if transitionAnimationName ~= nil then
			SetAnimation({ DestinationId = components.Background.Id, Name = transitionAnimationName })
		end
	end

	if category.GamepadNavigation ~= nil then
		SetGamepadNavigation( category )
	else
		SetGamepadNavigation( screen )
	end

	if category.OpenFunctionName ~= nil then
		CallFunctionName( category.OpenFunctionName, screen )
		return
	end

	if screen.Args.PlantTarget ~= nil and GameState.WorldUpgrades.WorldUpgradeGardenMultiPlant then
		components.PinButton.OnPressedFunctionName = "GardenMultiPlantSeed"
	end

	local resourceLocation = { X = screen.GridStartX, Y = screen.GridStartY }
	local columnNum = 1
	-- Mod start
	if category.Name ~= "PONYMENU" and category.Name ~= "Pony Menu" then
		for i, resourceName in ipairs( category ) do

			local resourceData = ResourceData[resourceName]
			if CanShowResourceInInventory( resourceData, screen.Args or { } ) then

				local textLines = nil
				local canBeGifted = false
				local canBePlanted = false
				if screen.Args.PlantTarget ~= nil then
					if GardenData.Seeds[resourceName] then
						canBePlanted = true
					end
				elseif screen.Args.GiftTarget ~= nil then
					if screen.Args.GiftTarget.UnlimitedGifts ~= nil and screen.Args.GiftTarget.UnlimitedGifts[resourceName] then
						canBeGifted = true
					else
						local spending = {}
						spending[resourceName] = 1
						textLines = GetRandomEligibleTextLines( screen.Args.GiftTarget, screen.Args.GiftTarget.GiftTextLineSets, GetNarrativeDataValue( screen.Args.GiftTarget, "GiftTextLinePriorities" ), { Spending = spending } )
						if textLines ~= nil then
							canBeGifted = true
						end
					end
				end

				local alpha = nil
				local alphaTarget = nil
				local alphaTargetDuration = nil
				if args.FirstOpen then
					alpha = 0.0
					alphaTarget = 1.0
					alphaTargetDuration	= 0.6
				end
				local button = CreateScreenComponent({ Name = "ButtonInventoryItem",
													   Scale = resourceData.IconScale or 1.0,
													   Sound = "/SFX/Menu Sounds/IrisMenuBack",
													   Group = "Combat_Menu_Overlay",
													   X = resourceLocation.X,
													   Y = resourceLocation.Y,
													   Alpha = 0.0,
													   AlphaTarget = 1.0,
													   AlphaTargetDuration	= 0.6,
				})

				button.Screen = screen
				button.ResourceData = resourceData
				components[resourceName] = button
				SetAnimation({ DestinationId = button.Id, Name = resourceData.IconPath or resourceData.Icon })

				local buttonHighlight = CreateScreenComponent({ Name = "BlankObstacle",
																Group = "Combat_Menu_Overlay_Additive",
																X = resourceLocation.X,
																Y = resourceLocation.Y,
																Alpha = 0.0,
																AlphaTarget = 1.0,
																AlphaTargetDuration	= 0.6,
				})
				components[resourceName.."Highlight"] = buttonHighlight
				button.Highlight = buttonHighlight

				if canBePlanted then
					if HasResource( resourceName, 1 ) then
						button.ContextualAction = "Menu_Plant"
						button.OnPressedFunctionName = "GardenPlantSeed"

						if GameState.WorldUpgrades.WorldUpgradeGardenMultiPlant then
							local numEmptyPlots = 0
							for id, plot in pairs( GameState.GardenPlots ) do
								if plot.SeedName == nil then
									numEmptyPlots = numEmptyPlots + 1
								end
							end
							if numEmptyPlots > 1 and HasResource( resourceName, 2 ) then
								button.PinContextualAction = "Menu_MultiPlant"
								button.PlantAmount = math.min( numEmptyPlots, GameState.Resources[resourceName] )
							end
						end

						if #GardenData.Seeds[resourceName].RandomOutcomes == 1 then
							local growsIntoName = GetFirstKey( GardenData.Seeds[resourceName].RandomOutcomes[1].AddResources )
							local amountNeededByPins = GetResourceAmountNeededByPins( growsIntoName )
							if amountNeededByPins > 0 then
								local pinAnimation = "StoreItemPin"
								if HasResource( growsIntoName, amountNeededByPins ) then
									pinAnimation = "StoreItemPin_Complete"
								end
								button.PinIcon = CreateScreenComponent({
									Name = "BlankObstacle",
									Group = "Combat_Menu_Overlay",
									Scale = screen.SeedPinIconScale,
									X = resourceLocation.X + screen.SeedPinIconOffsetX,
									Y = resourceLocation.Y + screen.SeedPinIconOffsetY,
									Animation = pinAnimation,
								})
								components[resourceName.."PinIcon"] = button.PinIcon
							end
						end
					else
						SetColor({ Id = button.Id, Color = Color.Black })
						button.MouseOverText = "InventoryScreen_SeedNotAvailable"
					end
				elseif canBeGifted then
					if HasResource( resourceName, 1 ) then
						button.ContextualAction = "Menu_Gift"
						button.OnPressedFunctionName = "GiveSelectedGift"
						button.TextLines = textLines
					else
						SetColor({ Id = button.Id, Color = Color.Black })
						button.MouseOverText = "InventoryScreen_GiftNotAvailable"
					end
				elseif screen.Args.PlantTarget ~= nil then
					SetColor({ Id = button.Id, Color = Color.Black })
					button.MouseOverText = "InventoryScreen_SeedNotWanted"
				elseif screen.Args.GiftTarget ~= nil then
					SetColor({ Id = button.Id, Color = Color.Black })
					button.MouseOverText = "InventoryScreen_GiftNotWanted"
				end

				CreateTextBoxWithScreenFormat( screen, button, "ResourceCountFormat", { Text = GameState.Resources[resourceName] or 0 } )

				button.MouseOverSound = "/SFX/Menu Sounds/DialoguePanelOutMenu"
				button.OnMouseOverFunctionName = "MouseOverResourceItem"
				button.OnMouseOffFunctionName = "MouseOffResourceItem"

				button.Viewable = not screen.Args.CategoryLocked or button.OnPressedFunctionName ~= nil
				if button.Viewable then
					-- highlight the initial selection, or the last resource you collected
					if resourceName == args.InitialSelection then
						screen.CursorStartX = resourceLocation.X
						screen.CursorStartY = resourceLocation.Y
					elseif resourceName == GameState.UnviewedLastResourceGained then
						UnviewedLastResourceGainedPresentation( screen, button )
						GameState.UnviewedLastResourceGained = nil
						screen.CursorStartX = resourceLocation.X
						screen.CursorStartY = resourceLocation.Y
					end

					-- mark unviewed resources as "new"
					if not GameState.ResourcesViewed[resourceName] then
						local newIcon = CreateScreenComponent({ Name = "BlankObstacle", Animation = "MusicPlayerNewTrack", Group = screen.ComponentData.DefaultGroup, Scale = screen.NewItemStarScale, })
						if args.FirstOpen then
							SetAlpha({ Id = newIcon.Id, Fraction = 0.0 })
							SetAlpha({ Id = newIcon.Id, Fraction = 1.0, Duration = 0.6 })
						end
						Attach({ Id = newIcon.Id, DestinationId = button.Id, OffsetX = screen.NewItemStarOffsetX, OffsetY = screen.NewItemStarOffsetY })
						button.NewIcon = newIcon
						components["NewIcon"..resourceName] = newIcon
					end
				end

				if columnNum < screen.GridWidth then
					columnNum = columnNum + 1
					resourceLocation.X = resourceLocation.X + screen.GridSpacingX
				else
					resourceLocation.Y = resourceLocation.Y + screen.GridSpacingY
					resourceLocation.X = screen.GridStartX
					columnNum = 1
				end
			end

		end
	else
		-- Pony Menu
		for index, k in ipairs(mod.CommandData) do
			-- for the clean up to work
			table.insert(category, index)

			local itemData = mod.CommandData[index]
			local button = CreateScreenComponent({
				Name = "ButtonInventoryItem",
				Scale = itemData.IconScale or 1.0,
				Sound = "/SFX/Menu Sounds/GodBoonMenuClose",
				Group = "Combat_Menu_Overlay",
				X = resourceLocation.X,
				Y = resourceLocation.Y + 10,
			})
			AttachLua({ Id = button.Id, Table = button })
			button.Screen = screen
			button.ItemData = itemData
			button.GridX = resourceLocation.X
			button.GridY = resourceLocation.Y + 10
			button.GridScale = itemData.IconScale or 1.0
			components[index] = button
			SetAnimation({ DestinationId = button.Id, Name = itemData.IconPath or itemData.Icon })

			-- CreateTextBoxWithScreenFormat( screen, button, "ResourceCountFormat", { Text = itemData.Name or "WIP" } )

			button.MouseOverSound = "/SFX/Menu Sounds/DialoguePanelOutMenu"
			button.OnMouseOverFunctionName = mod.mouseOverCommandItem
			button.OnMouseOffFunctionName = mod.mouseOffCommandItem
			button.OnPressedFunctionName = mod.Command

			if columnNum < screen.GridWidth then
				columnNum = columnNum + 1
				resourceLocation.X = resourceLocation.X + screen.GridSpacingX
			else
				resourceLocation.Y = resourceLocation.Y + screen.GridSpacingY
				resourceLocation.X = screen.GridStartX
				columnNum = 1
			end
		end
	end
	-- Mod end
end, mod)

function mod.mouseOverCommandItem(button)
	local screen = button.Screen
	if screen.Closing then
		return
	end

	GenericMouseOverPresentation(button)

	local components = screen.Components

	-- HERMES: 主菜单（幻驹菜单）的高亮。原来的 "InventorySlotHighlight" 组件在游戏里
	-- 根本不存在（Content 全文 0 处定义），所以从来没有光。这里照抄游戏背包的做法：
	-- 在同一个坐标放一个 BlankObstacle，播放 InventoryScreenSlotIn 动画。
	local buttonHighlight = CreateScreenComponent({
		Name = "BlankObstacle",
		Group = "Combat_Menu_Overlay_Additive",
		X = button.GridX,
		Y = button.GridY,
		Scale = button.GridScale or 1.0,
		Alpha = 0.0,
		AlphaTarget = 1.0,
		AlphaTargetDuration = 0.15,
	})
	SetAnimation({ DestinationId = buttonHighlight.Id, Name = "InventoryScreenSlotIn" })
	components.InventorySlotHighlight = buttonHighlight
	button.HighlightId = buttonHighlight.Id
	mod.ActiveHighlights = mod.ActiveHighlights or { }
	table.insert( mod.ActiveHighlights, buttonHighlight.Id )
	ModifyTextBox({
		Id = components.InfoBoxName.Id,
		Text = button.ItemData.Name,
		UseDescription = false,
		FadeTarget = 1.0,
		ScaleTarget = 0.8
	})
	ModifyTextBox({
		Id = components.InfoBoxDescription.Id,
		Text = button.ItemData.Description or " ",
		UseDescription = false,
		FadeTarget = 1.0,
	})

	SetScale({ Id = button.Id, Fraction = (button.ItemData.IconScale or 1.0) * screen.IconMouseOverScale, Duration = 0.1, EaseIn = 0.9, EaseOut = 1.0, SkipGeometryUpdate = true })
	--StopFlashing({ Id = button.Id })
	UpdateResourceInteractionText(screen, button)
end

function mod.mouseOffCommandItem(button)
	if button.HighlightId ~= nil then
		local highlightId = button.HighlightId
		SetAnimation({ DestinationId = highlightId, Name = "InventoryScreenSlotOut" })
		thread( function( )
			wait( 0.2 )
			Destroy({ Id = highlightId })
		end )
	end
	local components = button.Screen.Components
	components.InventorySlotHighlight = nil
	ModifyTextBox({ Id = components.InfoBoxName.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDescription.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDetails.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxFlavor.Id, FadeTarget = 0.0, })
	SetScale({ Id = button.Id, Fraction = button.ItemData.IconScale or 1.0, Duration = 0.1, SkipGeometryUpdate = true })
	StopFlashing({ Id = button.Id })
	UpdateResourceInteractionText(button.Screen)
end

-- HERMES: 悬停高亮的登记表。屏幕被直接关掉时 mouseOff 不会触发，
-- 高亮组件会残留在屏幕上（就是你看到左上角那些青色框）。
mod.ActiveHighlights = mod.ActiveHighlights or { }

function mod.ClearHighlights( )
	for _, highlightId in ipairs( mod.ActiveHighlights ) do
		pcall( Destroy, { Id = highlightId } )
	end
	mod.ActiveHighlights = { }
end

local function HermesResolvePath( path )
	local node = _G
	for part in string.gmatch( tostring( path ), "[^%.]+" ) do
		if type( node ) ~= "table" then return nil end
		node = node[ part ]
	end
	return node
end

-- HERMES FIX: the fork's "extra cheats" tab pointed at a function that did not exist.
-- Route that tab to the bundled CheatMenu screen.
function mod.ExtraSelectorLoadPage( screen )
	if type( openCheatScreen ) == "function" then
		thread( function( )
			wait( 0.15 )
			openCheatScreen( )
		end )
	else
		DebugPrint({ Text = "PonyMenu: CheatMenu (openCheatScreen) not loaded", LogOnly = true })
	end
end

function mod.Command(screen, button)
	local command = button.ItemData
	if command.Type == "Boon" then
		mod.OpenBoonSelector(screen, button)
	elseif command.Type == "Command" then
		CloseInventoryScreen(screen, screen.ComponentData.ActionBar.Children.CloseButton)
		local fn = HermesResolvePath( command.Function )
		if type( fn ) == "function" then
			local ok, err = pcall( fn, screen, button )
			if not ok then
				DebugPrint({ Text = "PonyMenu: command '" .. tostring( command.Function ) .. "' failed: " .. tostring( err ), LogOnly = true })
			end
		else
			DebugPrint({ Text = "PonyMenu: missing command '" .. tostring( command.Function ) .. "'", LogOnly = true })
		end
	end
end

-- HERMES FIX: 改稀有度时保持该祝福在 CurrentRun.Hero.Traits 里的原位置。
-- 游戏原做法是 RemoveWeaponTrait + AddTraitToHero，AddTraitData 用 table.insert 追加，
-- 所以被改的祝福会跳到列表最后。这里先记下索引，重加后再挪回原位。
function mod.SetTraitRarityInPlace( traitName, rarity )
	local traits = CurrentRun and CurrentRun.Hero and CurrentRun.Hero.Traits
	if traits == nil then return end

	local index = nil
	local stackNum = nil
	for i, trait in ipairs( traits ) do
		if trait.Name == traitName then
			index = i
			stackNum = trait.StackNum
			break
		end
	end
	if index == nil then return end

	RemoveWeaponTrait( traitName )
	AddTraitToHero({
		TraitData = GetProcessedTraitData({
			Unit = CurrentRun.Hero,
			TraitName = traitName,
			Rarity = rarity,
			StackNum = stackNum
		}),
		SkipNewTraitHighlight = true,
		SkipQuestStatusCheck = true,
		SkipActivatedTraitUpdate = true,
		SkipAddToHUD = true
	})

	local newIndex = nil
	for i, trait in ipairs( traits ) do
		if trait.Name == traitName then
			newIndex = i
			break
		end
	end
	if newIndex ~= nil and newIndex ~= index then
		local moved = table.remove( traits, newIndex )
		table.insert( traits, index, moved )
	end
end

-- HERMES: 调试/追踪通道（先写日志，io 可用时同时写文件）
function mod.Trace( msg )
	msg = tostring( msg )
	DebugPrint({ Text = "[PonyMenu] " .. msg, LogOnly = true })
	if io ~= nil and io.open ~= nil then
		local ok = pcall( function( )
			local f = io.open( "/tmp/hermes_ponymenu.log", "a" )
			if f then
				f:write( msg .. "\n" )
				f:close( )
			end
		end )
	end
end

-- HERMES ADD: 物品选择器的中文名 + 效果描述。
-- 游戏数据里消耗品只有 UseText（一段带占位符的效果句），没有"名字"字段，
-- 所以这里给常用物品补一张表，其余按数值字段自动生成描述。
mod.ConsumableInfo = {
	HealDrop = { Name = "疗伤药", Desc = "恢复 25 点生命" },
	HealDropMinor = { Name = "小疗伤药", Desc = "恢复 10 点生命" },
	HealDropSuperMinor = { Name = "微效疗伤药", Desc = "恢复 1 点生命" },
	HealDropMajor = { Name = "强效疗伤药", Desc = "恢复 50 点生命" },
	RoomRewardHealDrop = { Name = "疗伤药", Desc = "恢复 40% 生命" },
	HealBigDrop = { Name = "大疗伤药", Desc = "恢复 60% 生命" },
	RoomRewardConsolationPrize = { Name = "安慰奖", Desc = "恢复 1 点生命" },
	BloodDrop = { Name = "黑血", Desc = "提高移动速度" },
	ManaDropMinor = { Name = "魔力", Desc = "恢复 20 点魔力" },
	ManaDropMinorPoseidon = { Name = "魔力（波塞冬）", Desc = "恢复 20 点魔力" },
	ManaDropMinorHound = { Name = "魔力（猎犬）", Desc = "恢复 100 点魔力" },
	ManaDropZeus = { Name = "魔力（宙斯）", Desc = "恢复魔力" },
	PowerDrinkDrop = { Name = "力量药剂", Desc = "短时间内强化攻击" },
	RoomMoneyDrop = { Name = "金币", Desc = "获得 100 枚金币" },
	RoomMoneyBigDrop = { Name = "大堆金币", Desc = "获得 200 枚金币" },
	RoomMoneyTripleDrop = { Name = "超级金币堆", Desc = "获得 300 枚金币" },
	RoomMoneySmallDrop = { Name = "一小袋金币", Desc = "获得 50 枚金币" },
	RoomMoneyTinyDrop = { Name = "零钱", Desc = "获得 20 枚金币" },
	MedeaMoneyTinyDrop = { Name = "美狄亚的零钱", Desc = "获得金币" },
	LobAmmoPack = { Name = "弹药包", Desc = "补充 1 发弹药" },
	MaxHealthDrop = { Name = "生命上限提升", Desc = "生命上限 +25" },
	MaxHealthDropSmall = { Name = "生命上限提升（小）", Desc = "生命上限 +5" },
	MaxHealthDropBig = { Name = "生命上限提升（大）", Desc = "生命上限 +50" },
	EmptyMaxHealthDrop = { Name = "生命上限提升", Desc = "生命上限提升" },
	EmptyMaxHealthSmallDrop = { Name = "生命上限提升（小）", Desc = "生命上限提升" },
	MaxManaDrop = { Name = "魔力上限提升", Desc = "魔力上限 +30" },
	MaxManaDropSmall = { Name = "魔力上限提升（小）", Desc = "魔力上限提升" },
	MaxManaDropBig = { Name = "魔力上限提升（大）", Desc = "魔力上限提升" },
	TalentDrop = { Name = "天赋点", Desc = "获得 3 点天赋点" },
	MinorTalentDrop = { Name = "天赋点（少）", Desc = "获得少量天赋点" },
	TalentBigDrop = { Name = "天赋点（多）", Desc = "获得 5 点天赋点" },
	RerollDrop = { Name = "重掷次数", Desc = "重掷次数 +1" },
	LastStandDrop = { Name = "复生次数", Desc = "复生次数 +1" },
	LastStandShopItem = { Name = "复生次数（商店）", Desc = "复生次数 +1" },
	ArmorBoost = { Name = "护甲", Desc = "护甲 +20" },
	ArmorBigBoost = { Name = "护甲（大）", Desc = "护甲 +40" },
	FireBoost = { Name = "火元素强化", Desc = "本场战斗元素强化" },
	AirBoost = { Name = "风元素强化", Desc = "本场战斗元素强化" },
	EarthBoost = { Name = "土元素强化", Desc = "本场战斗元素强化" },
	WaterBoost = { Name = "水元素强化", Desc = "本场战斗元素强化" },
	ElementalBoost = { Name = "元素强化", Desc = "本场战斗元素强化" },
	WeaponUpgradeDrop = { Name = "武器强化", Desc = "强化当前武器" },
	ShopHermesUpgrade = { Name = "赫尔墨斯强化", Desc = "获得赫尔墨斯强化" },
	RandomLoot = { Name = "随机奖励", Desc = "随机掉落一个奖励" },
	BoostedRandomLoot = { Name = "强化随机奖励", Desc = "随机掉落一个更好的奖励" },
	StoreRewardRandomStack = { Name = "随机石榴", Desc = "升级一个随机祝福" },
	-- 第二批发现在列表里仍显示英文的条目
	BlindBoxLoot = { Name = "盲盒", Desc = "开启后随机获得一个祝福（125 金币）" },
	ArmorBoostStore = { Name = "护甲强化（商店）", Desc = "护甲 +20" },
	ChaosWeaponUpgrade = { Name = "混沌武器强化", Desc = "随机获得 2 个武器强化（混沌铁砧）" },
	EmptyMaxHealthShopItem = { Name = "生命上限提升（商店）", Desc = "提升生命上限" },
	LimitedSwapTraitDrop = { Name = "祝福交换次数", Desc = "获得 1 次祝福交换机会" },
	LimitedManaRegenDrop = { Name = "魔力再生（有限）", Desc = "获得有限的魔力再生" },
	DamageSelfDrop = { Name = "卖血换钱", Desc = "消耗 10-30 点生命换取金币" },
	HealDropRange = { Name = "疗伤药（按比例）", Desc = "按比例恢复生命" },
}

function mod.PrettifyKey( key )
	local spaced = tostring( key ):gsub( "(%l)(%u)", "%1 %2" )
	return spaced
end

function mod.GetConsumableName( key )
	local info = mod.ConsumableInfo[ key ]
	if info ~= nil and info.Name ~= nil then
		return info.Name
	end
	return mod.PrettifyKey( key )
end

function mod.GetConsumableDesc( key, data )
	local info = mod.ConsumableInfo[ key ]
	if info ~= nil and info.Desc ~= nil then
		return info.Desc
	end
	local parts = { }
	if data ~= nil then
		if data.HealFixed ~= nil then table.insert( parts, "恢复 " .. tostring( data.HealFixed ) .. " 点生命" ) end
		if data.HealFraction ~= nil and type( data.HealFraction ) == "number" then
			table.insert( parts, "恢复 " .. tostring( math.floor( data.HealFraction * 100 ) ) .. "% 生命" )
		end
		if data.AddMana ~= nil then table.insert( parts, "恢复 " .. tostring( data.AddMana ) .. " 点魔力" ) end
		if data.DropMoney ~= nil then table.insert( parts, "获得 " .. tostring( data.DropMoney ) .. " 枚金币" ) end
		if data.AddMaxHealth ~= nil then table.insert( parts, "生命上限 +" .. tostring( data.AddMaxHealth ) ) end
		if data.AddMaxMana ~= nil then table.insert( parts, "魔力上限 +" .. tostring( data.AddMaxMana ) ) end
		if data.AddTalentPoints ~= nil then table.insert( parts, "天赋点 +" .. tostring( data.AddTalentPoints ) ) end
		if data.AddRerolls ~= nil then table.insert( parts, "重掷次数 +" .. tostring( data.AddRerolls ) ) end
		if data.AddAmmo ~= nil then table.insert( parts, "弹药 +" .. tostring( data.AddAmmo ) ) end
		if data.AddArmor ~= nil then table.insert( parts, "护甲 +" .. tostring( data.AddArmor ) ) end
		if data.SpeedBonus ~= nil then table.insert( parts, "移动速度 +" .. tostring( math.floor( data.SpeedBonus * 100 ) ) .. "%" ) end
	end
	if #parts == 0 then
		return "该物品没有可显示的数据说明"
	end
	return table.concat( parts, "，" )
end

function mod.MouseOverConsumableItem( button )
	local screen = button.Screen
	if screen == nil or screen.Closing then return end
	local nameAnchor = screen.Components.ConsumableInfoName
	local descAnchor = screen.Components.ConsumableInfoDesc
	if nameAnchor ~= nil then
		ModifyTextBox({ Id = nameAnchor.Id, Text = mod.GetConsumableName( button.ItemKey ), FadeTarget = 1.0 })
	end
	if descAnchor ~= nil then
		ModifyTextBox({ Id = descAnchor.Id, Text = mod.GetConsumableDesc( button.ItemKey, button.Consumable ), FadeTarget = 1.0 })
	end
end

function mod.MouseOffConsumableItem( button )
	local screen = button.Screen
	if screen == nil then return end
	local nameAnchor = screen.Components.ConsumableInfoName
	local descAnchor = screen.Components.ConsumableInfoDesc
	if nameAnchor ~= nil then ModifyTextBox({ Id = nameAnchor.Id, Text = "" }) end
	if descAnchor ~= nil then ModifyTextBox({ Id = descAnchor.Id, Text = "" }) end
end

function mod.PopulateBoonData(upgradeName)
	local godName = string.gsub(upgradeName, 'Upgrade', '')
	local index = 0

	if LootSetData[godName] ~= nil and LootSetData[godName][upgradeName].WeaponUpgrades ~= nil then
		for k, v in pairs(LootSetData[godName][upgradeName].WeaponUpgrades) do
			index = index + 1
			mod.BoonData[upgradeName][index] = v
		end
	end

	if LootSetData[godName] ~= nil and LootSetData[godName][upgradeName].Traits ~= nil then
		for k, v in pairs(LootSetData[godName][upgradeName].Traits) do
			index = index + 1
			mod.BoonData[upgradeName][index] = v
		end
	end

	if mod.BoonData[upgradeName] == nil or IsEmpty(mod.BoonData[upgradeName]) then
		if upgradeName == "SpellDrop" then
			for k, v in pairs(QuestData.QuestDarkSorceries.CompleteGameStateRequirements[1].HasAll) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "WeaponUpgrade" then
			local wp = GetEquippedWeapon()
			for k, v in pairs(LootSetData.Loot[upgradeName].Traits) do
				local boon = TraitData[v]
				if boon.CodexWeapon == GetEquippedWeapon() then
					index = index + 1
					mod.BoonData.WeaponUpgrade[index] = v
				end
			end
		elseif upgradeName == "TrialUpgrade" then
			for k, v in pairs(LootSetData.Chaos.TrialUpgrade.PermanentTraits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Arachne_01" then
			for k, v in pairs(PresetEventArgs.ArachneCostumeChoices.UpgradeOptions) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v.ItemName
			end
		elseif upgradeName == "ArtemisUpgrade" then
			for k, v in pairs(UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Narcissus_01" then
			for k, v in pairs(UnitSetData.NPC_Narcissus.NPC_Narcissus_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Echo_01" then
			for k, v in pairs(UnitSetData.NPC_Echo.NPC_Echo_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_LordHades_01" then
			for k, v in pairs(UnitSetData.NPC_Hades.NPC_Hades_Field_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Medea_01" then
			for k, v in pairs(UnitSetData.NPC_Medea.NPC_Medea_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Icarus_01" then
			for k, v in pairs(UnitSetData.NPC_Icarus.NPC_Icarus_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Circe_01" then
			for k, v in pairs(UnitSetData.NPC_Circe.NPC_Circe_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Athena_01" then
			for k, v in pairs(UnitSetData.NPC_Athena.NPC_Athena_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Dionysus_01" then
			for k, v in pairs(UnitSetData.NPC_Dionysus.NPC_Dionysus_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "DiyTraitData" then
			for k, v in pairs(DiyTraitData) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		end
	end
end

function mod.GetLootColor(upgradeName)
	local godName = string.gsub(upgradeName, 'Upgrade', '')
	local color = Color.Black
	if mod.Config.ColorblindMode == true then
		return color
	end
	if LootSetData[godName] ~= nil then
		color = LootSetData[godName][upgradeName].LootColor
	elseif upgradeName == "SpellDrop" then
		color = LootSetData.Selene[upgradeName].LootColor
	elseif upgradeName == "WeaponUpgrade" then
		color = LootSetData.Loot[upgradeName].LootColor
	elseif upgradeName == "NPC_Arachne_01" then
		color = Color.ArachneVoice
	elseif upgradeName == "ArtemisUpgrade" then
		color = UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.LootColor
	elseif upgradeName == "NPC_Echo_01" then
		color = Color.EchoVoice
	elseif upgradeName == "NPC_Narcissus_01" then
		color = Color.NarcissusVoice
	elseif upgradeName == "NPC_LordHades_01" then
		color = UnitSetData.NPC_Hades.NPC_Hades_Field_01.LootColor
	elseif upgradeName == "NPC_Medea_01" then
		color = Color.MedeaVoice
	elseif upgradeName == "NPC_Icarus_01" then
		color = Color.IcarusVoice
	elseif upgradeName == "NPC_Circe_01" then
		color = Color.CirceVoice
	elseif upgradeName == "NPC_Athena_01" then
		color = Color.AthenaVoice
	elseif upgradeName == "NPC_Dionysus_01" then
		color = Color.DionysusVoice
	elseif upgradeName == "DiyTraitData" then
		color = Color.ArachneVoice
	end
	return color
end

function mod.GetLootColorFromTrait(traitName)
	local color = Color.Red
	return color
	--if mod.Config.ColorblindMode == true then
	--	return color
	--end
	--for upgradeName, boonData in pairs(mod.BoonData) do
	--	if ArrayContains(boonData, traitName) then
	--		color = mod.GetLootColor(upgradeName)
	--	end
	--end
	--return color
end

function mod.RemoveAllTraits()
	for i, traitData in pairs(CurrentRun.Hero.Traits) do
		RemoveTrait(CurrentRun.Hero, traitData.Name)
	end
end

function mod.RemoveAllBoons()
	for i, traitData in pairs(CurrentRun.Hero.Traits) do
		-- Only remove boons
		if traitData.RarityLevels ~= nil and traitData.Slot ~= "Keepsake" and traitData.Slot ~= "Aspect" and traitData.UpgradeResourceCost == nil then
			RemoveTrait(CurrentRun.Hero, traitData.Name)
		end
	end
end

function mod.ReloadEquipment()
	EquipWeaponUpgrade(CurrentRun.Hero, { SkipNewTraitHighlight = true, SkipUIUpdate = true })
	EquipKeepsake(CurrentRun.Hero, GameState.LastAwardTrait, { FromLoot = true, SkipNewTraitHighlight = true, AddToCache = true })
	EquipFamiliar(nil, { Unit = CurrentRun.Hero, FamiliarName = GameState.EquippedFamiliar })
	EquipMetaUpgrades(CurrentRun.Hero, { SkipNewTraitHighlight = true })
end

function mod.ClearAllBoons()
	mod.RemoveAllBoons()
	-- mod.ReloadEquipment()
	-- ClearUpgrades()
end

function mod.IsBoonTrait(traitName)
	for i, lootset in pairs(LootSetData) do
		for k, loot in pairs(lootset) do
			if loot.Icon == "BoonSymbolHermes" and loot.TraitIndex[traitName] then
				return true
			elseif loot.Icon == "BoonSymbolChaos" and Contains(loot.PermanentTraits, traitName) then
				return true
			elseif loot.Icon == "BoonSymbolChaos" and Contains(loot.TemporaryTraits, traitName) then
				return true
			elseif loot.Icon == "WeaponUpgradeSymbol" and loot.TraitIndex[traitName] then
				return true
			end
		end
	end
end
function mod.CreateNewCustomRun(room)
	local prevRun = CurrentRun
	local args = args or {}

	SetupRunData()
	ResetUI()

	--CurrentRun = {}
	RunStateInit()

	if args.RunOverrides ~= nil then
		OverwriteTableKeys(CurrentRun, args.RunOverrides)
	end

	for name, value in pairs(GameState.ShrineUpgrades) do
		ShrineUpgradeExtractValues(name)
	end

	CurrentRun.ActiveBounty = args.ActiveBounty
	CurrentRun.ForceNextEncounterData = args.Encounter

	CurrentRun.Hero = CreateNewHero(prevRun, args)

	if GameState.WorldUpgrades.WorldUpgradeUnusedWeaponBonus ~= nil then
		if prevRun ~= nil and prevRun.BonusUnusedWeaponName ~= nil and CurrentRun.Hero.Weapons[prevRun.BonusUnusedWeaponName] then
			if GameState.WorldUpgrades.WorldUpgradeUnusedWeaponBonusT2 then
				AddTrait(CurrentRun.Hero, "UnusedWeaponBonusTrait2")
			else
				AddTrait(CurrentRun.Hero, "UnusedWeaponBonusTrait")
			end
		end
	end

	local bountyData = BountyData[args.ActiveBounty]
	if bountyData ~= nil and bountyData.StartingTraits ~= nil then
		LoadActiveBountyPackages()
		for i, traitData in ipairs(bountyData.StartingTraits) do
			AddTrait(CurrentRun.Hero, traitData.Name, traitData.Rarity, { FromLoot = true })
		end
	end

	mod.LoadState(true)
	UpdateRunHistoryCache(CurrentRun)

	CurrentRun.BonusUnusedWeaponName = GetRandomUnequippedWeapon()
	CurrentRun.ActiveBiomeTimer = GetNumShrineUpgrades("BiomeSpeedShrineUpgrade") > 0
	CurrentRun.NumRerolls = GetTotalHeroTraitValue("RerollCount")
	CurrentRun.NumTalentPoints = GetTotalHeroTraitValue("TalentPointCount")
	CurrentRun.ActiveBountyClears = GameState.PackagedBountyClears[CurrentRun.ActiveBounty] or 0
	CurrentRun.ActiveBountyAttempts = GameState.PackagedBountyAttempts[CurrentRun.ActiveBounty] or 0
	CurrentRun.SpellCharge = 5000

	if ConfigOptionCache.EasyMode then
		CurrentRun.EasyModeLevel = GameState.EasyModeLevel
	end

	InitHeroLastStands(CurrentRun.Hero)
	InitializeRewardStores(CurrentRun)

	CurrentRun.CurrentRoom = CreateRoom(room, args)

	AddResource("Money", CalculateStartingMoney(), "RunStart")

	return CurrentRun
end

-- 直接进入指定房间 Boss战用
function mod.StartNewCustomRun(room)
	AddInputBlock({ Name = "StartOver" })

	for index, familiarName in ipairs(FamiliarOrderData) do
		local familiarData = FamiliarData[familiarName]
		local familiar = familiarData.Unit
		if familiar then
			CleanupEnemy(familiar)
			familiarData.Unit = nil
		end
	end

	local currentRun = CurrentRun

	CurrentRun.EndingRoomName = CurrentRun.CurrentRoom.Name
	table.insert( GameState.RunHistory, CurrentRun )
	GameState.CompletedRunsCache = TableLength( GameState.RunHistory )
	CurrentRun.CurrentRoom = nil
	PrevRun = CurrentRun
	--CurrentRun = nil

	CurrentHubRoom = nil
	PreviousDeathAreaRoom = nil

	HideCombatUI("StartOver")

	currentRun = mod.CreateNewCustomRun(room)
	StopMusicianMusic({ Duration = 1.0 })
	ResetObjectives()

	SetConfigOption({ Name = "FlipMapThings", Value = false })
	SetConfigOption({ Name = "BlockGameplayTimer", Value = false })

	AddTimerBlock(currentRun, "StartOver")

	ValidateCheckpoint({ Value = true })

	UnblockCombatUI("StartOver")
	WaitForSpeechFinished()
	RemoveInputBlock({ Name = "StartOver" })
	RemoveTimerBlock(currentRun, "StartOver")

	AddInputBlock({ Name = "MapLoad" })
	AddTimerBlock(CurrentRun, "MapLoad")

	LoadMap({ Name = currentRun.CurrentRoom.Name, ResetBinks = true })
end


function mod.KillPlayer()
	CurrentRun.Hero.IsDead = false
	Kill(CurrentRun.Hero)
end

function mod.SaveState()
	if CurrentRun.Hero.Traits ~= nil then
		local wp = GetEquippedWeapon()
		local aspect = GameState.LastWeaponUpgradeName[wp]
		local aspectLevel = GetWeaponUpgradeLevel(aspect)
		mod.Data.SavedState = {
			Traits = {},
			MetaUpgrades = {},
			Weapon = wp,
			Aspect = { Name = aspect, Rarity = TraitRarityData.WeaponRarityUpgradeOrder[aspectLevel] },
			Keepsake = GameState.LastAwardTrait,
			Assist = GameState.LastAssistTrait,
			Familiar = GameState.EquippedFamiliar,
		}
		for i, traitData in pairs(CurrentRun.Hero.Traits) do
			if
				not traitData.MetaUpgrade
				and traitData.Name ~= mod.Data.SavedState.Weapon
				and traitData.Name ~= mod.Data.SavedState.Aspect.Name
				and traitData.Name ~= mod.Data.SavedState.Keepsake
				and traitData.Name ~= mod.Data.SavedState.Assist
				and traitData.Name ~= mod.Data.SavedState.Familiar
			then
				if traitData.Slot and traitData.Slot == "Spell" then
					mod.Data.SavedState.Hex = traitData.Name
				else
					table.insert(mod.Data.SavedState.Traits, { Name = traitData.Name, Rarity = traitData.Rarity, StackNum = traitData.StackNum })
				end
			elseif traitData.MetaUpgrade then


				table.insert(mod.Data.SavedState.MetaUpgrades, {
					TraitName = traitData.Name,
					Rarity = traitData.Rarity,
					CustomMultiplier = traitData.CustomMultiplier,
					SourceName = traitData.Name
				})
			end
		end
		SaveCheckpoint({ DevSaveName = CreateDevSaveName(CurrentRun) })
		PlaySound({ Name = "/SFX/WrathEndingWarning", Id = CurrentRun.Hero.ObjectId })
		thread(InCombatTextArgs,
			{
				TargetId = CurrentRun.Hero.ObjectId,
				Text = mod.Locale.SaveStateSaved,
				SkipRise = false,
				SkipFlash = false,
				Duration = 1.5,
				ShadowScaleX = 1.5,
			})
	end
end

function mod.LoadState(newRun)
	if mod.Data.SavedState ~= nil then
		if newRun == nil then
			mod.RemoveAllTraits()
			ClearUpgrades()
		end
		if GameState.LastAwardTrait == "ReincarnationKeepsake" then
			RemoveLastStand(CurrentRun.Hero, "ReincarnationKeepsake")
			CurrentRun.Hero.MaxLastStands = CurrentRun.Hero.MaxLastStands - 1
		end
		EquipPlayerWeapon(WeaponData[mod.Data.SavedState.Weapon], { LoadPackages = true })
		if mod.Data.SavedState.Keepsake ~= nil then
			EquipKeepsake(CurrentRun.Hero, mod.Data.SavedState.Keepsake, { FromLoot = true, SkipNewTraitHighlight = true })
		end
		if mod.Data.SavedState.Assist ~= nil then
			EquipAssist(CurrentRun.Hero, mod.Data.SavedState.Assist, { SkipNewTraitHighlight = true })
		end
		if mod.Data.SavedState.Familiar ~= nil then
			EquipFamiliar(nil, { Unit = CurrentRun.Hero, FamiliarName = mod.Data.SavedState.Familiar, SkipNewTraitHighlight = true })
		end
		if mod.Data.SavedState.Aspect.Name ~= nil then
			AddTraitToHero({
				TraitName = mod.Data.SavedState.Aspect.Name,
				Rarity = mod.Data.SavedState.Aspect.Rarity,
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
			})
		end
		for _, traitData in pairs(mod.Data.SavedState.Traits) do
			AddTraitToHero({
				TraitData = GetProcessedTraitData({
					Unit = CurrentRun.Hero,
					TraitName = traitData.Name,
					Rarity = traitData.Rarity,
					StackNum = traitData.StackNum
				}),
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
			})
		end
		if mod.Data.SavedState.Hex ~= nil then
			AddTraitToHero({
				TraitName = mod.Data.SavedState.Hex,
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
			})
			-- CurrentRun.Hero.SlottedSpell = DeepCopyTable(SpellData[mod.Data.SavedState.Hex])
			-- CurrentRun.Hero.SlottedSpell.Talents = DeepCopyTable(CreateTalentTree(SpellData[mod.Data.SavedState.Hex]))
		end
		for _, traitData in pairs(mod.Data.SavedState.MetaUpgrades) do
			AddTraitToHero({
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
				TraitName = traitData.TraitName,
				Rarity = traitData.Rarity,
				CustomMultiplier = traitData.CustomMultiplier,
				SourceName = traitData.SourceName,
			})
		end
		if newRun == nil then
			PlaySound({ Name = "/SFX/WrathEndingWarning", Id = CurrentRun.Hero.ObjectId })
			thread(InCombatTextArgs,
				{
					TargetId = CurrentRun.Hero.ObjectId,
					Text = mod.Locale.SaveStateLoaded,
					SkipRise = false,
					SkipFlash = false,
					Duration = 1.5,
					ShadowScaleX = 1.5,
				})
		end
	end
end

function mod.GoToTrainingRoom()
	local prevRun = CurrentRun
	CurrentRun.Hero = CreateNewHero(prevRun)
	CurrentRun.Hero.IsDead = true
	LoadMap({ Name = "Hub_PreRun", ResetBinks = true })
end

function mod.PopulateConsumableData()
	local consumableData = DeepCopyTable(ConsumableData)
	consumableData["BaseConsumable"] = nil
	consumableData["BaseMetaRoomReward"] = nil
	consumableData["BaseResource"] = nil
	consumableData["BaseSuperResource"] = nil
	consumableData["BaseWellShopConsumable"] = nil
	consumableData["Tier1Consumable"] = nil
	consumableData["RandomStoreItem"] = nil

	for key, consumable in pairs(consumableData) do
		consumable.key = key
		if consumable.AddResources then
			consumableData[key] = nil
		else
			if consumable.Cost then
				consumable.Cost = 0
			end
			if consumable.ResourceCosts then
				consumable.ResourceCosts = {
					Money = 0
				}
			end
			if consumable.PurchaseRequirements then
				consumable.PurchaseRequirements = nil
			end
			if consumable.HealFraction and type(consumable.HealFraction) == "table" then
				consumable.HealFraction = RandomFloat(consumable.HealFraction.BaseMin, consumable.HealFraction.BaseMax)
			end
			if consumable.HealthCost and type(consumable.HealthCost) == "table" then
				consumable.HealthCost = RandomInt(consumable.HealthCost.BaseMin, consumable.HealthCost.BaseMax)
			end
		end
	end

	mod.ConsumableData = consumableData
end

ModUtil.Path.Wrap("CheckBounties", function(base, source, args)
	if source.KillHeroOnCompletion then
		mod.KillPlayer()
		return true
	else
		return base(source, args)
	end
end)

ModUtil.LoadOnce(function()
	for key, value in pairs(mod.BoonData) do
		mod.PopulateBoonData(key)
	end
	mod.PopulateConsumableData()
end)

mod.Internal = ModUtil.UpValues(function()
	return setupMainData, mod.mouseOverCommandItem, mod.mouseOffCommandItem
end)

setupMainData()
