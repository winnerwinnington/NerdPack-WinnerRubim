local exeOnLoad = function()
--	NePCR.Splash()
	meeleSpell = 49998
	print("Meele Spell: ".. GetSpellInfo(meeleSpell) .. "(" .. meeleSpell .. ")")

	NeP.Interface.CreateToggle(
		'saveDS',
		'Interface\\Icons\\spell_deathknight_butcher2.png',
		'Save a Death Strike',
		'Saving Runic.')
		
	NeP.Interface.CreateToggle(
		'bonestorm',
		'Interface\\Icons\\Ability_deathknight_boneshield.png',
		'Use Bonestorm',
		'Pool RP.')
	
	NeP.Interface.CreateToggle(
		'aoetaunt',
		'Interface\\Icons\\spell_nature_shamanrage.png',
		'Aoe Taunt',
		'Aoe Taunt.')	
	
end

local DeathStrikeHELL = {
	{ "Death Strike" , { "player.health <= 50" , "!toggle.saveDS" }}, --DS Emergency		
	{{ --Bonestormless
		{ "Death Strike" , { "player.health <= 85" , "!toggle.saveDS" }}, --DS to Heal
		{ "Death Strike" , "player.runicpower >= 90" }, --DS for RP Dump		
	}, "!talent(7, 1)"},
	{{ --Bonestormless
		{ "Death Strike" , { "player.health <= 85" , "!toggle.saveDS" }}, --DS to Heal
		{ "Death Strike" , "player.runicpower >= 90" }, --DS for RP Dump		
	}, "@Rubim.AreaTTD()"},
	{{ --Bonestorm
		{ "Death Strike" , { "player.health <= 85" , "!toggle.saveDS" , "!toggle.bonestorm" }}, --DS to Heal
		{ "Death Strike" , { "player.health <= 85" , "!toggle.saveDS" , "toggle.bonestorm" , "player.spell(Bonestorm).cooldown >= 2" }}, --DS to Heal
		{ "Death Strike" , { "player.runicpower >= 90" , "!toggle.bonestorm" }}, --DS for RP Dump
		{ "Death Strike" , { "player.spell(Bonestorm).cooldown >= 2" , "player.runicpower >= 90" , "toggle.bonestorm" }}, --DS for RP Dump if Bonestorm is out of CD
	}, "talent(7, 1)"},
}

local Shared = {
	{'@Rubim.CastGroundSpell()'},
}

local Survival = {
	{ "Vampiric Blood" , { "player.runicpower >= 35" , "player.health <= 85" , "@Rubim.MeeleRange" }}, --VP with enough RP for a DS
	{ '#5512', 'player.health < 70'}, --Healthstone
}

local Interrupts = {
	-- Mind freeze
	{ '47528' },
}

local Cooldowns = {
	{ "Blood Fury" },
}

local Burst = {
	{"Marrowrend" , "player.buff(Bone Shield).count <= 2" },
	{"Heart Strike"},
	{"Blood Boil" , "player.rarea(8).enemies >= 1" },
}

local Util = {
	--AUTOTARGET
	{ '@Rubim.Targeting()' , '!target.alive' },
	
	--BOSS
	{ '%pause' , 'player.debuff(200904)' },
	{ '%pause' , 'player.debuff(Soul Saped)' },
	
	--
}


local inCombat = {
	{ Util },
	{ "@Rubim.AoETaunt()" , "toggle.aoetaunt" },
	{ Interrupts, "target.interruptAt(10)" }, -- Interrupt when 40% into the cast time
	{ Cooldowns , "player.rarea(8).enemies >= 1" },
	{ Survival },
	{ "Bonestorm" , { "player.runicpower >= 90" , "toggle.bonestorm" }}, --Bonestorm with enough RP
	{ DeathStrikeHELL },
	{"Blood Boil", { "target.debuff(Blood Plague).duration < 1.5" , "player.rarea(8).enemies >= 1" }},
	{ Burst , "@Rubim.AreaTTD()"},
	
	{{
	{"Marrowrend" , "player.buff(Bone Shield).count <= 5" },
	{"Heart Strike" , "player.buff(Bone Shield).count >= 6"},
	{"Blood Boil" , { "player.spell(Blood Boil).charges >= 2" , "player.rarea(8).enemies >= 1" }},
	}, "player.rarea(10).enemies <= 2" },
	
	{{
	{"Marrowrend" , "player.buff(Bone Shield).count <= 2" },
	{"Blood Boil" , "player.rarea(8).enemies >= 1"},
	{"Heart Strike" },
	}, "player.rarea(10).enemies >= 3" },
}

local outCombat = {
	{Shared}
}

NeP.Engine.registerRotation(250, '[|cff'..NeP.Interface.addonColor..'Rubim (WIP) Deathknight - Blood', {
		{'%pause', 'player.channeling'},
		{Shared},
		{inCombat}
	}, outCombat, exeOnLoad)