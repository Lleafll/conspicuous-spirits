-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Upvalues
local WeakAurasScanEvents
if IsAddOnLoaded("WeakAuras") then
	WeakAurasScanEvents = WeakAuras.ScanEvents
else
	WeakAurasScanEvents = function() end
end


-- Frames
local timerFrame = CS.frame


-- Variables
local wa_as


-- Functions
local function refreshDisplay(orbs, timers)
	local count = #timers
	wa_as.count = count
	wa_as.orbs = orbs
	wa_as.timers = timers
	WeakAurasScanEvents("WA_AUSPICIOUS_SPIRITS", count, orbs)
end

function CS:initializeWeakAuras(timers)
	timerFrame:SetWidth(0)
	timerFrame:SetHeight(0)
	
	if not _G.wa_as then _G.wa_as = {} end
	wa_as = _G.wa_as
	wa_as.count = 0
	wa_as.orbs = UnitPower("player", 13)
	wa_as.timers = {}
	function wa_as.TimeLeft(timerId) return CS:TimeLeft(timerId) end
	function CS:refreshDisplay(orbs, timers) refreshDisplay(orbs, timers) end
	function timerFrame:ShowChildren() end
	function timerFrame:HideChildren() end
end