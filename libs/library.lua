local _, Rubim = ...

local RotationText = 0
local rotype = CreateFrame("Frame", "Rotation Indicator", UIParent)
local rottext = rotype:CreateFontString("MyrotypeText", "OVERLAY")
local OneTimeRubim = 1
local event = function()
	if OneTimeRubim == nil then
	rotype:SetWidth(240)
	rotype:SetHeight(40)
	rotype:SetPoint("CENTER") -- Whats the chat anchor?
	local tex = rotype:CreateTexture("BACKGROUND")
	tex:SetAllPoints()
	tex:SetTexture(0, 0, 0); tex:SetAlpha(0.5)
	OneTimeRubim = 1
	end

	rottext:SetFontObject(GameFontNormalSmall)
	rottext:SetJustifyH("CENTER") -- 
	rottext:SetPoint("CENTER", rotype, "CENTER", 0, 0) -- Text on center
	rottext:SetFont("Fonts\\FRIZQT__.TTF", 20)
	rottext:SetShadowOffset(1, -1)
	rottext:SetText("Hello")

	rotype:SetScript("OnUpdate", function()
	rottext:SetText("TTD: " .. RotationText)
	end)
   
	rotype:SetMovable(true)
	rotype:EnableMouse(true)
	rotype:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" and not self.isMoving then
		self:StartMoving();
		self.isMoving = true;
		end
	end)
	rotype:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" and self.isMoving then
		self:StopMovingOrSizing();
		self.isMoving = false;
	end
	end)
	rotype:SetScript("OnHide", function(self)
	if ( self.isMoving ) then
		self:StopMovingOrSizing();
		self.isMoving = false;
	end
	end)
end

rotype:SetScript("OnEvent", event)
rotype:RegisterEvent("PLAYER_LOGIN")

function Rubim.Update()
	if math.floor(NeP.DSL:Get("deathin")("target")) > 999999 then RotationText = 0
	else
		RotationText = math.floor(NeP.DSL:Get("deathin")("target"))
	end
end

function Rubim.BloodMaster()
	if NeP.DSL:Get('areattd')('player') <= 10 then
		return "burst"
	end
	
	if Rubim.Offtanking() then
		return "dps"
	end
	
	if NeP.DSL:Get('buff.duration')('player' , 'Dancing Rune Weapon') > 0 then
		return "drw"
	end
	
	return 'general'
end

function Rubim.Offtanking()
--	 local isRaid = IsInRaid() 
	 
	if isRaid == true then
	 --FIND THE OTHER TANK
		for _, Obj in pairs(NeP.OM:GetRoster()) do
			if select(1,Obj.key) ~= "player" and select(1,Obj.role) == "TANK" then
				tankKey = select(1,Obj.key)
			end
		end
		if tankKey == nil then return false end
		local aggrostatus = UnitThreatSituation(tankKey , "target")
		if aggrostatus == nil then aggrostatus = 0 end
		if UnitExists("target") == true and aggrostatus >= 2 then return true end
	end
	return false
end

function Rubim.SetText(text)
	RotationText = text
	return false
end
-- UnitGUID("target") ~= UnitGuid(Obj.key)
function Rubim.Targeting()
	local exists = UnitExists("target")
	local hp = UnitHealth("target")
	if exists == false or (exists == true and hp < 1) then
		for _, Obj in pairs(NeP.OM:GetRoster()) do
			if Obj.distance <= 10 then
				RunMacroText("/tar " .. Obj.key)
				return true
			end
		end
	end
end

function Rubim.WarriorFR()
	if select(1,NeP.CombatTracker:getDMG("player")) <= (UnitHealthMax("player") * 3) / (100) then
		return true
	else
		return false
	end
end

function Rubim.AoETaunt()
	local spell = "Dark Command"
	local spellCooldown = NeP.DSL:Get('spell.cooldown')("player", spell)
	if spellCooldown > 0 then
		return false
	end
	for _, Obj in pairs(NeP.OM:GetRoster()) do
		local Threat = UnitThreatSituation("player", Obj.key)
		if Threat ~= nil and Threat >= 0 and Threat < 3 and Obj.distance <= 30 then
			NeP:Queue(spell, Obj.key)
			return true
		end
	end
end

--START DK
--actions.generic+=/wait,sec=cooldown.apocalypse.remains,if=cooldown.apocalypse.remains<=1&cooldown.apocalypse.remains
function Rubim.Paused()
	if rubimapocalypse == false then
		return false
	elseif NeP.DSL:Get('spell.cooldown')("player", 'Apocalypse') > 0 then
		rubimapocalypse = false
		return true
	end
end

function Rubim.ShouldPause()
	if NeP.DSL:Get('spell.cooldown')("player", 'Apocalypse') <= 1 then
		rubimapocalypse = true
	end
end



function Rubim.AoEOutbreak()
	local spell = "Outbreak"
	local debuff = "Virulent Plague"
	local spellCooldown = NeP.DSL:Get('spell.cooldown')("player", spell)
	if cdtime == nil then cdtime = 0 end
	
	if spellCooldown > 0 then
		return false
	end
	
	if GetTime() - cdtime <= 1 then return false end
	
	for _, Obj in pairs(NeP.OM:GetRoster()) do	
		local _,_,_,_,_,_,debuffDuration = UnitDebuff(Obj.key, debuff, nil, 'PLAYER')
		if not debuffDuration then debuffDuration = 0 end
		if Obj.distance <= 15 and debuffDuration - GetTime() < 1.5 and GetTime() - cdtime >= 1 and UnitHealth(Obj.key) > 100 and UnitAffectingCombat(Obj.key) == true then
			cdtime = GetTime()
			NeP:Queue(spell, Obj.key)
			return true
		end
	end
end

function Rubim.TTDSpell(spell)
	print("running")
	local targetToDie = NeP.DSL:Get("deathin")("target")
	local spellCooldown = NeP.DSL:Get('spell.cooldown')("player", spell)
	print("Time to die: " .. targetToDie)
	print("CD: " .. spellCooldown)
	if targetToDie <= spellCooldown then
		return true
	else
		return false
	end
end

local ttdsomething = function()
	local spell = 7777777
	local targetToDie = NeP.DSL:Get("deathin")("target")
	local spellCooldown = NeP.DSL:Get('spell.cooldown')("player", spell)
	if targetToDie <= (spellCooldown - 8) then
		return true
	else
		return false
	end
end

--SHOULD REMOVE
function Rubim.AreaTTD()
	local ttd = 0
	local total = 0
	for _, Obj in pairs(NeP.OM:GetRoster()) do
		if Obj.distance <= 6 and (UnitAffectingCombat(Obj.key) or Obj.is == 'dummy') then
			if NeP.DSL:Get("deathin")(Obj.key) < 8 then
				total = total+1
				ttd = NeP.DSL:Get("deathin")(Obj.key) + ttd
			end
		end
	end
	if ttd > 0 and (ttd/total) <= 10 then
		return true
	else
		return false
	end
end

function Rubim.AoEMissingDebuff(spell, debuff, range)
	if spell == nil or range == nil or NeP.DSL:Get('spell.cooldown')("player", 61304) ~= 0 then return false end
	local spell = select(1,GetSpellInfo(spell))
	if not IsUsableSpell(spell) then return false end
	for _, Obj in pairs(NeP.OM:GetRoster()) do
		if Obj.distance <= range and (UnitAffectingCombat(Obj.key) or Obj.is == 'dummy') then
			local _,_,_,_,_,_,debuffDuration = UnitDebuff(Obj.key, debuff, nil, 'PLAYER')
			if not debuffDuration or debuffDuration - GetTime() < 1.5 then
--				print(Obj.name)
				if UnitCanAttack('player', Obj.key)	and NeP.Protected.Infront('player', Obj.key) then		
					NeP:Queue(spell, Obj.key)
					return true
				end
			end
		end
	end
end

function Rubim.soulGorge()
	local debuff = 'Blood Plague'
	if NeP.DSL:Get('spell.cooldown')("player", 61304) ~= 0 then return false end
	for _, Obj in pairs(NeP.OM:GetRoster()) do
		if Obj.distance <= 30 and (UnitAffectingCombat(Obj.key) or Obj.is == 'dummy') then
			local _,_,_,_,_,_,debuffDuration = UnitDebuff(Obj.key, debuff, nil, 'PLAYER')
			if not debuffDuration then debuffDuration = 0 end
			if debuffDuration - GetTime() > 1 and debuffDuration - GetTime() < 3  then
				return true
			end
		end
	end
end

function Rubim.MoonfireAOE()
	local Spell = "Moonfire"
	if not IsUsableSpell(Spell) then return false end
	
	for _, Obj in pairs(NeP.OM:GetRoster()) do
		if Obj.distance <= 5 and (UnitAffectingCombat(Obj.key) or Obj.is == 'dummy') then
			local _,_,_,_,_,_,debuffDuration = UnitDebuff(Obj.key, Spell, nil, 'PLAYER')
			if not debuffDuration or debuffDuration - GetTime() < 3 then
--				print(Obj.name)
				if UnitCanAttack('player', Obj.key)	and NeP.Protected.Infront('player', Obj.key) and IsSpellInRange(Spell, Obj.key) then		
					NeP.Protected.Cast(Spell, Obj.key)
					return true
				end
			end
		end
	end
end

function Rubim.AoETargetsM()
	if CheckMobsinMeele() >= 3 then
		return true
	else
		return false
	end
end

function Rubim.AoETargetsR()
	if CheckMobsinAoE() >= 3 then
		return true
	else
		return false
	end
end


function Rubim.AggroCheck()
	if UnitThreatSituation("player") == nil
	then
		return false
	elseif UnitThreatSituation("player") == 2	
	then
		return true
	else
		return false
	end
end

function SpellRange(spellid)
	if IsSpellInRange(GetSpellInfo(spellid), "target") == 1
	then return true else return false
	end
end

function Rubim.AoERange()
	if CheckInteractDistance("target", 3) == true
	or SpellRange(Rubim.meeleSpell) == true
	then return true else return false
	end
end

function Rubim.MeeleRange()
	if SpellRange(Rubim.meeleSpell) == true
	then return true else return false
	end
end

function Rubim.CDCheck(spellid)
	Sstart, Sduration, Senabled = GetSpellCooldown(spellid)
	Scooldown = (Sstart + Sduration - GetTime())
	if Sstart == 0
	then
		Scooldown = 0
	end
	return Scooldown
end


function Rubim.SQRuneTap()
	if SpellQueue == "Rune Tap"	then
		SpellQueue = nil
		return true 
	else return false end
end

function Rubim.StaggerValue()
    local staggerLight, _, iconLight, _, _, remainingLight, _, _, _, _, _, _, _, _, _, _, _, valueStaggerLight, _ = UnitAura("player", GetSpellInfo(124275), "", "HARMFUL")
	local staggerModerate, _, iconModerate, _, _, remainingModerate, _, _, _, _, _, _, _, _, _, _, _, valueStaggerModerate, _ = UnitAura("player", GetSpellInfo(124274), "", "HARMFUL")
	local staggerHeavy, _, iconHeavy, _, _, remainingHeavy, _, _, _, _, _, _, _, _, _, _, _, valueStaggerHeavy, _ = UnitAura("player", GetSpellInfo(124273), "", "HARMFUL")
    local staggerTotal= (remainingLight or remainingModerate or remainingHeavy or 0) * (valueStaggerLight or valueStaggerModerate or valueStaggerHeavy or 0)
    local percentOfHealth=(100/UnitHealthMax("player")*staggerTotal)
    local ticksTotal=(valueStaggerLight or valueStaggerLight or valueStaggerLight or 0)
    return percentOfHealth;
end

function Rubim.DrinkStagger()
	if UnitDebuff("player", GetSpellInfo(124273)) then
		return true
	end
	if UnitDebuff("player", GetSpellInfo(124275)) and Rubim.StaggerValue() > 85
	then
		return true
	end
end


-- Props to CML? for this code
function Rubim.noControl()
  local eventIndex = C_LossOfControl.GetNumEvents()
	while (eventIndex > 0) do
		local _, _, text = C_LossOfControl.GetEventInfo(eventIndex)
	-- Hunter
		if select(3, UnitClass("player")) == 3 then
			if text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_SNARE then
				return true
			end
		end
	-- Monk
		if select(3, UnitClass("player")) == 10 then
			if text == LOSS_OF_CONTROL_DISPLAY_STUN or text == LOSS_OF_CONTROL_DISPLAY_FEAR or text == LOSS_OF_CONTROL_DISPLAY_ROOT or text == LOSS_OF_CONTROL_DISPLAY_HORROR then
				return true
			end
		end
	eventIndex = eventIndex - 1
	end
	return false
end

function GetSpellCD(MySpell)
  if GetSpellCooldown(MySpell) == 0 then
     return 0
  else
     local Start ,CD = GetSpellCooldown(MySpell)
     local MyCD = Start + CD - GetTime()
     return MyCD
  end
end

function Rubim.KSEnergy(energycheck)
  if energycheck then
    local MyNRG = UnitPower("player", 3)
    local MyNRGregen = select(2, GetPowerRegen("player"))
    local cd = GetSpellCD(121253)
    local NRGforKS = MyNRG + (MyNRGregen * GetSpellCD(121253))
--    NOC.DEBUG(5, "NOC.KSEnergy returning: "..NRGforKS.." ("..MyNRG.."+("..MyNRGregen.."*"..cd..")")
    return NRGforKS >= energycheck
  end
  return false
end

-- Time to Die
function Rubim.round2(num, idp)
  mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Rubim.ttd(unit)
	unit = unit or "target";
	if thpcurr == nil then
		thpcurr = 0
	end
	if thpstart == nil then
		thpstart = 0
	end
	if timestart == nil then
		timestart = 0
	end
	if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
		if currtar ~= UnitGUID(unit) then
			priortar = currtar
			currtar = UnitGUID(unit)
		end
		if thpstart==0 and timestart==0 then
			thpstart = UnitHealth(unit)
			timestart = GetTime()
		else
			thpcurr = UnitHealth(unit)
			timecurr = GetTime()
			if thpcurr >= thpstart then
				thpstart = thpcurr
				timeToDie = 999
			else
				if ((timecurr - timestart)==0) or ((thpstart - thpcurr)==0) then
					timeToDie = 999
				else
					timeToDie = Rubim.round2(thpcurr/((thpstart - thpcurr) / (timecurr - timestart)),2)
				end
			end
		end
	elseif not UnitExists(unit) or currtar ~= UnitGUID(unit) then
		currtar = 0 
		priortar = 0
		thpstart = 0
		timestart = 0
		timeToDie = 9999999999999999
	end
	if timeToDie==nil then
		return 99999999999999999
	else
		return timeToDie
	end
end	

--GROUND SPELLS
function Rubim.CreateMacro()
	if select(3,UnitClass("player")) == 12 then
		CreateMacro("Infernal Strike", "ABILITY_DEMONHUNTER_INFERNALSTRIKE1", "#showtooltip Infernal Strike\n/run Rubim.GroundSpell('189110')", 1)
		CreateMacro("Sigil of Flame", "ABILITY_DEMONHUNTER_SIGILOFINQUISITION", "#showtooltip Sigil of Flame\n/run Rubim.GroundSpell('204596')", 1)
		CreateMacro("Sigil of Silence", "ABILITY_DEMONHUNTER_SIGILOFSILENCE", "#showtooltip Sigil of Silence\n/run Rubim.GroundSpell('202137')", 1)
		CreateMacro("Sigil of Misery", "ABILITY_DEMONHUNTER_SIGILOFMISERY", "#showtooltip Sigil of Misery\n/run Rubim.GroundSpell(207684)", 1)
		CreateMacro("Metamorphosis", "ABILITY_DEMONHUNTER_METAMORPHOSISDPS", "#showtooltip Metamorphosis\n/run Rubim.GroundSpell(191427)", 1)
	end
	if select(3,UnitClass("player")) == 1 then	
		CreateMacro("Heroic Leap", "ABILITY_HEROICLEAP", "#showtooltip Heroic Leap\n/run Rubim.GroundSpell(6544)", 1)
		CreateMacro("Piercing Howl", "ABILITY_HEROICLEAP", "#showtooltip Piercing Howl\n/run Rubim.QueuedSpell(12323)", 1)
		CreateMacro("Intimidating Shout", "ABILITY_HEROICLEAP", "#showtooltip Intimidating Shout\n/run Rubim.QueuedSpell(5246)", 1)
	end
	if select(3,UnitClass("player")) == 6 then
		CreateMacro("DnD", "SPELL_SHADOW_DEATHANDDECAY", "#showtooltip Death and Decay\n/run Rubim.GroundSpell(43265)", 1)
	end
end

function Rubim.CastGroundSpell()
	if not SpellIsTargeting() then return false end
	if SpellIsTargeting() then CameraOrSelectOrMoveStart() CameraOrSelectOrMoveStop() return true end  
end

function Rubim.GroundSpell(spell)
	if UnitAffectingCombat('player') == false then
		CastSpellByName(spell)
	else
		CastSpellByName(spell)
		NeP:Queue(spell)
	end
end

function Rubim.QueuedSpell(spell)
	NeP:Queue(spell)     
end

function Rubim.IG()
IgnorePainAbsorb = select(17, UnitAura("player", "Ignore Pain", nil, "HELPFUL"))

	if IgnorePainAbsorb ~= nil then
		return false
	else
		return true
	end
end

function Rubim.RuneCheck(color,number)
	
	Rune = {}
	RunePartial = {}
	
	BloodRunes = 0
	BloodPartial = 0
	UnholyRunes = 0
	UnholyPartial = 0
	FrostRunes = 0
	FrostPartial = 0
	DeathRunes = 0
	DeathPartial = 0
	
	for i=1,6 do
		RuneStart = select(1,GetRuneCooldown(i))
		RuneDuration = select(2,GetRuneCooldown(i))		
		if RuneStart > 0 then 
			Rune[i] = 0
			RunePartial[i] = 0
			RunePartial[i] = (Rune[i] + (((((RuneStart + RuneDuration - GetTime()) - RuneDuration ) * -1)) / RuneDuration))
		else
			Rune[i] = 1
		end
		
		if RunePartial[i] == nil then
			RunePartial[i] = 1
		end
		
		if RunePartial[i] ~= nil and RunePartial[i] < 0 then
			RunePartial[i] = 0
		end
		
		--BLOOD
		if GetRuneType(i) == 1 then
			BloodRunes = Rune[i] + BloodRunes
			BloodPartial = RunePartial[i] + BloodPartial
		end		
		
		--UNHOLY
		if GetRuneType(i) == 2 then
			UnholyRunes = Rune[i] + UnholyRunes
			UnholyPartial = RunePartial[i] + UnholyPartial
		end
		
		--FROST
		if GetRuneType(i) == 3 then
			FrostRunes = Rune[i] + FrostRunes
			FrostPartial = RunePartial[i] + FrostPartial
		end
		
		--DEATH
		if GetRuneType(i) == 4 then
			DeathRunes = Rune[i] + DeathRunes
			DeathPartial = RunePartial[i] + DeathPartial
		end
		
		
	end
	
	if color == "Blood" then
		if BloodPartial >= number then
			return true
		else
			return false
		end
	end
	
	if color == "Unholy" then
		if UnholyPartial >= number then
			return true
		else
			return false
		end
	end
	
	if color == "Frost" then
		if FrostPartial >= number then
			return true
		else
			return false
		end
	end	
	
	if color == "Death" then
		if DeathPartial >= number then
			return true
		else
			return false
		end
	end
	
	
	--INVERSE
	if color == "InverseBlood" then
		if BloodPartial <= number then
			return true
		else
			return false
		end
	end
	
	if color == "InverseUnholy <" then
		if UnholyPartial <= number then
			return true
		else
			return false
		end
	end
	
	if color == "InverseFrost <" then
		if FrostPartial <= number then
			return true
		else
			return false
		end
	end	
	
	if color == "InverseDeath <" then
		if DeathPartial <= number then
			return true
		else
			return false
		end
	end
	
	
end

function Rubim.RunesUnavailable(number)
    local unavailable = 0
	if number == nil then
		number = 0
	end
   --	local number2 = tonumber(number)
    for i=1,6 do
        local start, duration, runeReady = GetRuneCooldown(i);
        if not runeReady then
            unavailable = unavailable + 1
        end
    end
    if unavailable >= number then
		return true
	else
		return false
	end
end

function Rubim.IcyTalons()
	if UnitBuff("player", GetSpellInfo(194878)) == nil
	then
		ITTimer = 0
	else
		ITTimer = select(7,UnitBuff("player", GetSpellInfo(194878))) - GetTime()
	end
	if ITTimer >= Rubim.CDCheck(61304) then
		return true
	else
		return false
	end	
end

function Rubim.SR()
	if Rubim.CDCheck(130736) >= 4 then
		return true
	else
		return false
	end
end

function Rubim.DelayStagger()
	if puriTime == nil then
		puriTime = GetTime() + 5
	end
	
	if puriTime <= GetTime() then
		puriTime = nil
		return true
	end
	return false
end

function Rubim.DelayHealing()
	if healingTime == nil then
		healingTime = GetTime() + 3
	end
	
	if healingTime <= GetTime() then
		healingTime = nil
		return true
	end
	return false
end


--WARRIOR

function Rubim.PetDead()
	if UnitExists("pet") == true then
		return false
	else
		CastSpellByName(GetSpellInfo(883))
		return true
	end
end

NeP.Library:Add("Rubim", Rubim)

--CASTING SHIT
