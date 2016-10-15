--/dump NeP.DSL.Conditions['rpdeficiet']('player')
--/dump NeP.DSL.Conditions['rprint']('Hi')
--/dump NeP.DSL.Conditions['rubimarea']
--/dump NeP.DSL.Conditions['areattd']('player')
--/dump NeP.DSL.Conditions['rubimarea.enemies']('player',8)
--/dump NeP.DSL.Conditions['spell.charges']('player','Blood Boil')
--/dump NeP.DSL.Conditions['toggle']('cooldowns')
--/dump NeP.DSL.Conditions['bmup']

NeP.DSL:Register('rpdeficit', function(target)
	return (UnitPowerMax(target, SPELL_POWER_RUNIC_POWER)) - (UnitPower(target, SPELL_POWER_RUNIC_POWER))
end)

NeP.DSL:Register('energydeficit', function(target)
	return (UnitPowerMax(target, SPELL_POWER_ENERGY)) - (UnitPower(target, SPELL_POWER_ENERGY))
end)

NeP.DSL:Register('combodeficit', function(target)
	return (UnitPowerMax(target, SPELL_POWER_COMBO_POINTS)) - (UnitPower(target, SPELL_POWER_COMBO_POINTS))
end)

NeP.DSL:Register('equipped', function(target, item)
	if IsEquippedItem(item) == true then return true else return false end
end)

NeP.DSL:Register('rprint', function(text)
	print(text)
end)

NeP.DSL:Register("rubimarea.enemies", function(unit, distance)
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
	return total
end)

NeP.DSL:Register("areattd", function(target)
	local ttd = 0
	local total = 0
	for i=1,#NeP.OM['unitEnemie'] do
		local Obj = NeP.OM['unitEnemie'][i]	
		if Obj.distance <= 6 and (UnitAffectingCombat(Obj.key) or Obj.is == 'dummy') then
			if NeP.DSL:Get("deathin")(Obj.key) < 8 then
				total = total+1
				ttd = NeP.DSL:Get("deathin")(Obj.key) + ttd
			end
		end
	end
	if ttd > 0 then
		return ttd/total
	else
		return 9999999999
	end
end)
