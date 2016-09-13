local exeOnLoad = function()
--	NePCR.Splash()
--m	meeleSpell = 49998
	print("|cffFFFF00 ----------------------------------------------------------------------|r")
	print("|cffFFFF00 --- |rDeath Knight |cffC41F3BBlood |r")
	print("|cffFFFF00 --- |rRecommended Talents: 1/2 - 2/1 - 3/1 - 4/2 - 5/1 - 6/3 - 7/1")
	print("|cffFFFF00 --- |rDnD usage is not optimal. Read the Readme avaiable at github.")
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

local DeathStrikeHELL = {
	{ "Death Strike" , { "player.health <= 65" , "!toggle.saveDS" }}, --DS Emergency		
	{{ --Bonestormless
		{ "Death Strike" , { "player.health <= 85" , "!toggle.saveDS" }}, --DS to Heal
		{ "Death Strike" , "player.runicpower >= 90" }, --DS for RP Dump		
	}, "!talent(7, 1)"},
	{{ --Bonestorm
		{ "Death Strike" , { "player.health <= 85" , "!toggle.saveDS" , "!toggle.bonestorm" }}, --DS to Heal
		{ "Death Strike" , { "player.health <= 85" , "!toggle.saveDS" , "toggle.bonestorm" , "player.spell(Bonestorm).cooldown >= 2" }}, --DS to Heal
		{ "Death Strike" , { "player.runicpower >= 90" , "!toggle.bonestorm" }}, --DS for RP Dump
		{ "Death Strike" , { "player.spell(Bonestorm).cooldown >= 2" , "player.runicpower >= 90" , "toggle.bonestorm" }}, --DS for RP Dump if Bonestorm is out of CD
	}, "talent(7, 1)"},
}

local Shared = {
--	{'@Rubim.CastGroundSpell()'},
}

local Survival = {
	{ "Vampiric Blood" , { "player.runicpower >= 35" , "player.health <= 85" , "player.rubimarea(7).enemies >= 1" }}, --VP with enough RP for a DS
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
	{{
		{'Death Strike' , 'player.health <= 70' },
		{'Death Strike' , 'player.runicpower >= 75'},
		{'Blood Boil'},
		{'Heart Strike' },	
	}, 'player.rubimarea(7).enemies >= 2'},
	
	{{
		{'Death Strike' , 'player.runicpower >= 75'},
		{'Marrowrend'},
		{'Death Strike'},
		{'Blood Boil'},
	}, 'player.rubimarea(7).enemies <= 1'},
}

local Util = {
	--AUTOTARGET
	{ '@Rubim.Targeting()' , '!target.alive' },
	{ "@Rubim.AoETaunt()" , "toggle.aoetaunt" },
	--BOSS
	{ '%pause' , 'player.debuff(200904)' },
	{ '%pause' , 'player.debuff(Soul Saped)' },
}

local General = {
	{{
	{"Marrowrend" , "player.buff(Bone Shield).count <= 5" },
	{"Heart Strike" , "player.buff(Bone Shield).count >= 6"},
	{"Blood Boil" , { "player.spell(Blood Boil).charges >= 2" , "player.rubimarea(8).enemies >= 1" }},
	}, "player.rubimarea(10).enemies <= 2" },
	
	{{
	{"Marrowrend" , "player.buff(Bone Shield).count <= 2" },
	{"Blood Boil" , "player.rubimarea(8).enemies >= 1"},
	{"Heart Strike" },
	}, "player.rubimarea(10).enemies >= 3" },
}


local inCombat = {
	{ Util },
	{ Interrupts, "target.interruptAt(10)" }, -- Interrupt when 40% into the cast time
	{ Cooldowns , "player.rubimarea(8).enemies >= 1" },
	{"Blood Boil", { "target.debuff(Blood Plague).duration < 1.5" , "player.rubimarea(8).enemies >= 1" }},
	{ Survival },
	{ Burst , "player.areattd <= 5"},
	{ "Bonestorm" , { "player.runicpower >= 90" , "toggle.bonestorm" , "player.areattd >= 10" }}, --Bonestorm with enough RP
	{ DeathStrikeHELL },
	{ "Death and Decay"},
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