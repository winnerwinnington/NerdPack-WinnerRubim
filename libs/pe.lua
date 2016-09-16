--/dump NeP.DSL.Conditions['rpdeficiet']('player')
--/dump NeP.DSL.Conditions['rprint']('Hi')
--/dump NeP.DSL.Conditions['rubimarea']
--/dump NeP.DSL.Conditions['areattd']('player')
--/dump NeP.DSL.Conditions['rubimarea.enemies']('player',8)
NeP.DSL.RegisterConditon('rpdeficiet', function(target)
	return (UnitPowerMax(target, SPELL_POWER_RUNIC_POWER)) - (UnitPower(target, SPELL_POWER_RUNIC_POWER))
end)

NeP.DSL.RegisterConditon('equipped', function(target, item)
	if IsEquippedItem(item) == true then return true else return false end
end)

NeP.DSL.RegisterConditon('rprint', function(text)
	print(text)
end)

NeP.DSL.RegisterConditon("rubimarea.enemies", function(unit, distance)
	local total = 0
	local distance = tonumber(distance)
	if UnitExists(unit) then
		for i=1, #NeP.OM['unitEnemie'] do
			local Obj = NeP.OM['unitEnemie'][i]
			if UnitExists(Obj.key) and UnitHealth(Obj.key) > 0 and not UnitIsDeadOrGhost(Obj.key)
			and (UnitAffectingCombat(Obj.key) or isDummy(Obj.key))
			and (NeP.Engine.Distance(unit, Obj.key) <= distance) then
				total = total +1
			end
		end
	end
	if total == 0 and UnitExists('target') and UnitHealth('target') > 0 and IsSpellInRange(GetSpellInfo(meeleSpell), "target") == 1 then
		total = 1
	end
	return total
end)

NeP.DSL.RegisterConditon("areattd", function(target)
	local ttd = 0
	local total = 0
	for i=1,#NeP.OM['unitEnemie'] do
		local Obj = NeP.OM['unitEnemie'][i]	
		if Obj.distance <= 6 and (UnitAffectingCombat(Obj.key) or Obj.is == 'dummy') then
			if NeP.DSL.Conditions["deathin"](Obj.key) < 8 then
				total = total+1
				ttd = NeP.DSL.Conditions["deathin"](Obj.key) + ttd
			end
		end
	end
	if ttd > 0 then
		return ttd/total
	else
		return 9999999999
	end
end)
