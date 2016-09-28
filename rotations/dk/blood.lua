local exeOnLoad = function()
--	NePCR.Splash()
	meeleSpell = 49998
	print("|cffFFFF00 ----------------------------------------------------------------------|r")
	print("|cffFFFF00 --- |rDeath Knight |cffC41F3BBlood |r")
	print("|cffFFFF00 --- |rRecommended Talents: 1/2 - 2/1 - 3/1 - 4/2 - 5/1 - 6/3 - 7/1")
	print("|cffFFFF00 --- |rPersonal use.")
	print("|cffFFFF00 ----------------------------------------------------------------------|r")

	NeP.Interface.CreateToggle(
		'saveDS',
		'Interface\\Icons\\spell_deathknight_butcher2.png',
		'Save Death Strike',
		'BOT will Only Death Strike when RP is Capped, useful on fights were you need to cast an active mitigation.')
		
	NeP.Interface.CreateToggle(
		'bonestorm',
		'Interface\\Icons\\Ability_deathknight_boneshield.png',
		'Use Bonestorm',
		'This will pool RP to use Bonestorm.')
	
	NeP.Interface.CreateToggle(
		'aoetaunt',
		'Interface\\Icons\\spell_nature_shamanrage.png',
		'Aoe Taunt',
		'Experimental AoE Taunt.')	
	
end

local function keyPress(keypressed)

    if keypressed == 'shift' then
        return IsShiftKeyDown() and GetCurrentKeyBoardFocus() == nil
    end

    if keypressed == 'lctrl' then
        return IsLeftControlKeyDown() and GetCurrentKeyBoardFocus() == nil
    end

    if keypressed == 'lalt' then
        return IsLeftAltKeyDown() and GetCurrentKeyBoardFocus() == nil 
    end

    return false
end

local DeathStrikeHELL = {
	{ "Death Strike" , { "player.health <= 65" , "!toggle(saveDS)" }}, --DS Emergency		
	{{ --Bonestormless
		{ "Death Strike" , { "player.health <= 85" , "!toggle(saveDS)" }}, --DS to Heal
		{ "Death Strike" , "player.runicpower >= 90" }, --DS for RP Dump		
	}, "!talent(7, 1)"},
	{{ --Bonestorm
		{ "Death Strike" , { "player.health <= 85" , "!toggle(saveDS)" , "!toggle(bonestorm)" }}, --DS to Heal
		{ "Death Strike" , { "player.health <= 85" , "!toggle(saveDS)" , "toggle(bonestorm)" , "player.spell(Bonestorm).cooldown >= 2" }}, --DS to Heal
		{ "Death Strike" , { "player.runicpower >= 90" , "!toggle(bonestorm)" }}, --DS for RP Dump
		{ "Death Strike" , { "player.spell(Bonestorm).cooldown >= 2" , "player.runicpower >= 90" , "toggle(bonestorm)" }}, --DS for RP Dump if Bonestorm is out of CD
	}, "talent(7, 1)"},
}

local Shared = {
--	{ "@Rubim.SetText('OOC')" },
--	{'@Rubim.CastGroundSpell()'},
}

local Survival = {
	{ "Vampiric Blood" , { "player.runicpower >= 35" , "player.health <= 90" , "player.rubimarea(7).enemies >= 1" }}, --VP with enough RP for a DS
}

local Interrupts = {
	-- Mind freeze
	{ '47528' },
}

local Cooldowns = {
	{ "Blood Fury" },
}

local DRW = {
--	{ "@Rubim.SetText('DRW')" },
	{"Blood Boil" , { "player.spell(Blood Boil).charges >= 1.8" , "player.rubimarea(8).enemies >= 1" }},
	{'Death Strike' , 'player.runicpower >= 75'},
	{"Marrowrend" , "player.buff(Bone Shield).count <= 2" },
	{'Heart Strike' },	
	{'Death Strike' },
}

local DPS = {
--	{ "@Rubim.SetText('DPS')" },
	{'Death Strike' , 'player.runicpower >= 75'},
	{'Death Strike' , 'player.buff(Blood Shield)'},
	{"Marrowrend" , "player.buff(Bone Shield).count <= 6" },
	{'Heart Strike' },
}

local Burst = {
--  {"@Rubim.SetText('Burst')" },
	{"Marrowrend" , "player.buff(Bone Shield).count <= 2" },
	{{
		{'Death Strike' , 'player.health <= 70' },
		{'Death Strike' , 'player.runicpower >= 75'},
		{'Blood Boil'},
		{'Heart Strike' },	
	}, 'player.rubimarea(7).enemies >= 2'},
	
	{{
		{'Death Strike' , 'player.runicpower >= 75'},
		{"Marrowrend" , "player.buff(Bone Shield).count <= 2" },
		{"Heart Strike"},
		{'Death Strike'},
		{'Blood Boil'},
	}, 'player.rubimarea(7).enemies <= 1'},
}

local Util = {
	--AUTOTARGET
--	{ '@Rubim.Targeting()' , '!target.alive' },
--	{ "@Rubim.AoETaunt()" , "toggle(aoetaunt)" },
	--BOSS
	{ '%Pause' , 'player.debuff(200904).duration > 0' },
	{ '%pause' , 'player.debuff(200904).duration > 0' },
}

local Bonestorm = {
--	{ "@Rubim.SetText('Bonestorm')" },
	{ "Death Strike" , { "player.health <= 65" , "!toggle(saveDS)" }}, --DS Emergency		
	{ "Bonestorm" , { "player.runicpower >= 90" , "toggle(bonestorm)" , "player.areattd >= 10", "!toggle(saveDS)"}}, --Bonestorm with enough RP
	{ "Death Strike" , { "player.health <= 90" , "!toggle(saveDS)" , "!toggle(bonestorm)" }}, --DS to Heal
	{ "Death Strike" , { "player.health <= 90" , "!toggle(saveDS)" , "toggle(bonestorm)" , "player.spell(Bonestorm).cooldown >= 2" }}, --Saving RP
	{ "Death Strike" , { "player.runicpower >= 75" , "!toggle(bonestorm)" }}, --DS for RP Dump
	{ "Death Strike" , { "player.spell(Bonestorm).cooldown >= 2" , "player.runicpower >= 75" , "toggle(bonestorm)" }}, --DS for RP Dump if Bonestorm is on CD
}

local Bonestormless = {
	{ "Death Strike" , { "player.health <= 90" , "!toggle(saveDS)" }}, --DS to Heal
	{ "Death Strike" , "player.runicpower >= 75" }, --DS for RP Dump		
}

local General = {
	{ Bonestorm , 'talent(7, 1)' },
	{ Bonestormless , '!talent(7, 1)' },
	{{
	{"Marrowrend" , "player.buff(Bone Shield).count <= 5" },
	{"Heart Strike" , { "player.spell(Death and Decay).cooldown >= 4" , "player.buff(Bone Shield).count >= 6" }},
	{"Heart Strike" , { "player.health <= 75" , "player.buff(Bone Shield).count >= 6" }},
	{"Heart Strike" , { "player.runes >= 4.8" , "player.buff(Bone Shield).count >= 6"}},
	}, "player.area(10).enemies <= 2" },
	
	{{
	{"Marrowrend" , "player.buff(Bone Shield).count <= 2" },
	{"Blood Boil" , "player.area(8).enemies >= 1"},
	{"Heart Strike" , "player.spell(Death and Decay).cooldown >= 4.duration > 0"},
	{"Heart Strike" , { "player.health <= 75" , "player.buff(Bone Shield).count >= 6" }},
	{"Heart Strike" , "player.runes >= 4.8"},
	}, "player.area(10).enemies >= 3" },
}

local inCombat222222 = {
	{ Util },
	{ Interrupts, "target.interruptAt(30)" },
	{ Cooldowns , "player.area(8).enemies >= 1" },
	{"Blood Boil", { "target.debuff(Blood Plague).duration < 1.5" , "player.area(8).enemies >= 1" }},
	{"Blood Boil" , { "player.buff(Dancing Rune Weapon).duration > 0" ,  "player.buff(Dancing Rune Weapon).duration < 3"}},
	{"Blood Boil" , { "player.spell(Blood Boil).charges >= 1.8" , "player.area(8).enemies >= 1" }},
	{ "Vampiric Blood" , { "player.runicpower >= 35" , "player.health <= 90" , "player.area(7).enemies >= 1" , "player.runes <= 5.8"}},
	{ General },
}

local inCombat = {
	{ Util },
	{ Interrupts, "target.interruptAt(30)" },
	{ Cooldowns , "player.area(8).enemies >= 1" },
	{"Blood Boil", { "target.debuff(Blood Plague).duration < 1.5" , "player.area(8).enemies >= 1" }},
	{"Blood Boil" , { "player.buff(Dancing Rune Weapon).duration > 0" ,  "player.buff(Dancing Rune Weapon).duration < 3"}},
	{"Blood Boil" , { "player.spell(Blood Boil).charges >= 1.8" , "player.area(8).enemies >= 1" }},
	{ "Vampiric Blood" , { "player.runicpower >= 35" , "player.health <= 90" , "player.area(7).enemies >= 1" , "player.runes <= 5.8"}}, --VP with enough RP for a DS
	{ Burst , "player.blood.rotation(burst)" },
	{ DRW , "player.blood.rotation(drw)" },
	{ DPS , "player.blood.rotation(dps)" },
	{ General },
}

local inCombatOLD = {
	{ Util },
	{ Interrupts, "target.interruptAt(30)" },
	{ Cooldowns , "player.area(8).enemies >= 1" },
	{"Blood Boil", { "target.debuff(Blood Plague).duration < 1.5" , "player.area(8).enemies >= 1" }},
	{"Blood Boil" , { "player.buff(Dancing Rune Weapon).duration > 0" ,  "player.buff(Dancing Rune Weapon).duration < 3"}},
	{"Blood Boil" , { "player.spell(Blood Boil).charges >= 1.8" , "player.area(8).enemies >= 1" }},
	{ "Vampiric Blood" , { "player.runicpower >= 35" , "player.health <= 90" , "player.area(7).enemies >= 1" , "player.runes <= 5.8"}}, --VP with enough RP for a DS
	{ DRW , { "player.buff(Dancing Rune Weapon).duration > 0" , "playet.health >= 80" }},
	{ Burst , "player.areattd <= 10"},
	{DPS, (function() return keyPress('lctrl') end)},
	{ General },
}

local outCombat = {
	{Shared}
}

NeP.Engine.registerRotation(250, '[|cff'..NeP.Interface.addonColor..'Rubim (WIP) Deathknight - Blood', {
		{'%pause', 'player.channeling'},
		{Shared},
		{inCombat}
	}, outCombat, exeOnLoad)
