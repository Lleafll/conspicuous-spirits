------------------------------------------------------
-- Get addon object and encounter fix module object --
------------------------------------------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end
local EF = CS:GetModule("EncounterFixes")


---------------------
-- Encounter fixes --
---------------------

-- Flamebender
EF:RegisterEncounter(1689, function()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		if spellID == 181089 then  -- "Encounter Event" (when wolves vanish)
			CS:RemoveGUID(sourceGUID)
		end
	end)
end)

-- Blast Furnace
EF:RegisterEncounter(1690, function()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		if spellID == 605 and event == "SPELL_CAST_SUCCESS" then  -- Dominate Mind
			CS:RemoveGUID(destGUID)  -- possibly replace with HideGUID
		end
	end)
end)

-- Hans'gar and Franzok
EF:RegisterEncounter(1693, function()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		local boss1GUID = UnitGUID("boss1")
		local boss2GUID = UnitGUID("boss2")
		if boss2GUID and boss1GUID then
			self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			self:RegisterEvent("UNIT_TARGETABLE_CHANGED", function()
				if not UnitExists("boss1") then
					CS:RemoveGUID(boss1GUID)
				
				elseif not UnitExists("boss2") then
					CS:RemoveGUID(boss2GUID)
				
				end
			end)
		end
	end)
end)

-- Beastlord Darmac
EF:RegisterEncounter(1694, function()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		-- check when Beastlord becomes untargetable due to mounting up
		local darmacGUID = UnitGUID("boss1")
		if darmacGUID then
			self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			self:RegisterEvent("UNIT_TARGETABLE_CHANGED", function()
				if not UnitExists("boss1") then
					CS:RemoveGUID(darmacGUID)  -- possibly replace with HideGUID
				end
			end)
		end
	end)
	-- search for overkill since there isn't always a death event for the spears
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self:CheckForOverkill)
end)

-- Blackhand
EF:RegisterEncounter(1704, function()
	-- fix for disappearing Siegemakers in P2 -> P3 transition
	local bossGUID = {}
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		for i = 1, 5 do
			local unitID = "boss"..tostring(i)
			local GUID = UnitGUID(unitID)
			-- don't overwrite with nil because INSTANCE_ENCOUNTER_ENGAGE_UNIT fires before COMBAT_LOG_EVENT_UNFILTERED
			if GUID then
				bossGUID[i] = GUID
			end
		end
	end)
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		if spellID == 177487 then  -- Shattered Floor
			for i = 1, 5 do
				if bossGUID[i] and not (self:GetNPCID(bossGUID[i]) == 77325) then
					CS:RemoveGUID(bossGUID[i])
				end
				
				--@alpha@
				print("Conspicuous Spirits Alpha Debug: Shattered Floor!")
				if bossGUID[i] and not (self:GetNPCID(bossGUID[i]) == 77325) then
					print(self:GetNPCID(bossGUID[i]))
				end
				--@end-alpha@
			
			end
			self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			
		elseif spellID == "Falling" and destGUID == UnitGUID("player") then  -- aimed at taking fall damage after jumping from balcony
		
			--@alpha@
			print("Conspicuous Spirits Alpha Debug: Taking Falling Damage!")
			--@end-alpha@
		
			CS:RemoveAllGUIDsExcept(bossGUID[1], bossGUID[2], bossGUID[3], bossGUID[4], bossGUID[5])
			
		end
	end)
end)