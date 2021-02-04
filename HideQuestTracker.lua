-- This file is loaded from "Hide Quest Tracker.toc"
local HideQuestTrackerFrame = CreateFrame("Frame", "HideQuestTrackerFrame")

-- Local used variables
local expansionSL = 8
local expansionBfA = 7
local expansionLegion = 6
local expansionWoD = 5
local expansionMoP = 4
local expansionCata = 3
local expansionWotLK = 2
local expansionTBC = 1
local vanilla = 0

-- User defined variables
local showCampaignQuests = 1
local showWorldQuests = 1
local showVanilla = 0
local showTBC = 0
local showWotLK = 0
local showCata = 0
local showMoP = 0
local showWoD = 0
local showLegion = 0
local showBfA = 1
local showSL = 1
local showWQ = 0
local showCompleted = 0

 -- Display all quests as default
local sortExpansion =  {
 [vanilla] = 0,
 [expansionTBC] = 0,
 [expansionWotLK] = 0,
 [expansionCata] = 0,
 [expansionMoP] = 0,
 [expansionWoD] = 0,
 [expansionLegion] = 0,
 [expansionBfA] = 1,
 [expansionSL] = 0 
}

local Expansion = {
  [0] = "Vanilla",
  [1] = "The Burning Crusade",
  [2] = "Wrath of the Lich King",
  [3] = "Cataclysm",
  [4] = "Mist of Pandaria",
  [5] = "Warlords of Draenor",
  [6] = "Legion",
  [7] = "Battle for Azeroth",
  [8] = "Shadowlands"
}

--Register event triggers
HideQuestTrackerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
HideQuestTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
--HideQuestTrackerFrame:RegisterEvent("ADDON_LOADED")
HideQuestTrackerFrame:RegisterEvent("QUEST_WATCH_UPDATE")
HideQuestTrackerFrame:RegisterEvent("QUEST_ACCEPTED")
HideQuestTrackerFrame:RegisterEvent("QUEST_REMOVED")
HideQuestTrackerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Function we can call when a setting changes.
function HideQuestTrackerFrame:Update()

	local numEntries, _ = C_QuestLog.GetNumQuestLogEntries()
	print("Update!")
	for index = 1, numEntries do
		local info = C_QuestLog.GetInfo(index)
		local qID = info.questID
		
		if not info.isHeader then
			self:showOrHideQuest(qID)
		end
	end
	
	
end

-- Local functions
local function getQuestInfoById(questID)
	local isCompleted = C_QuestLog.IsComplete(questID)
	local isWorldQuest = C_QuestLog.IsWorldQuest(questID)

	return isCompleted, isWorldQuest
end

function HideQuestTrackerFrame:showOrHideQuest(questID)
	local isCompleted, isWorldQuest = getQuestInfoById(questID)
	
	-- HAVEN'T FOUND A WAY TO HIDE WORLD QUESTS
	-- Hide WQ if that's selected and the quest is a WQ
	if showWQ == 0 and isWorldQuest then
		C_QuestLog.RemoveWorldQuestWatch(questID)
		--C_QuestLog.RemoveQuestWatch(questID)
		print("Hide WQ: " .. C_QuestLog.GetTitleForQuestID(questID))
		
		--[[questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
		--print("QuestLogID: " .. questLogIndex)
		if questLogIndex == nil then
			return
		end
		for index = questLogIndex, 1, -1 do
			local info = C_QuestLog.GetInfo(index)
			if info.isHeader then
				print("Header: " .. info.title)
				CollapseQuestHeader(info.questID)
				--CollapseQuestHeader(0)
				--return
			end
		end]]
	end

	-- Hide completed quest if that's selected once it's been completed
	if showCompleted == 0 and isCompleted then
		print("Completed!")
		C_QuestLog.RemoveQuestWatch(questID)
		return
	end
		
	-- Check which expansion the quest comes from and hide if selected
	local questExpansion = GetQuestExpansion(questID)
	if sortExpansion[questExpansion] == 0 then
		print("Hide Expansion! " .. Expansion[questExpansion])
		C_QuestLog.RemoveQuestWatch(questID)
		return
	end
	
	-- If the quest shouldn't be hidden, show it.
	C_QuestLog.AddQuestWatch(questID)	
end

-- event handlers
HideQuestTrackerFrame:SetScript("OnEvent", function(self, event_name, ...)
	if self[event_name] then
		return self[event_name](self, event_name, ...)
	end
end);

function HideQuestTrackerFrame:PLAYER_REGEN_DISABLED(...)
 -- handle PLAYER_REGEN_DISABLED here
	--print(WatchFrame);
--	WatchFrame:Hide()
	ObjectiveTrackerFrame:Hide()
end

function HideQuestTrackerFrame:PLAYER_REGEN_ENABLED(...)
 -- handle PLAYER_REGEN_ENABLED here
	ObjectiveTrackerFrame:Show()
end

--[[function HideQuestTrackerFrame:ADDON_LOADED(event, addon)
	
	--print("HQT Loaded")
	--if not HideQuestTrackerDB or not HideQuestTrackerDB.Threshold  then
	--	HideQuestTrackerDB = {
	--		
	--	}
	--end
	--print("ADDON_LOADED!")
	--HideQuestTrackerFrame:Update()
end]]

function HideQuestTrackerFrame:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
	
	--print("HQT Loaded")
	--if not HideQuestTrackerDB or not HideQuestTrackerDB.Threshold  then
	--	HideQuestTrackerDB = {
	--		
	--	}
	--end
	if isLogin then
		print("Log in!")
		HideQuestTrackerFrame:Update()
	elseif isReload then
		print("Reload UI!")
		HideQuestTrackerFrame:Update()
	end
end

function HideQuestTrackerFrame:QUEST_WATCH_UPDATE(event, questID)
	--DebugLog("Update for quest: ", questID)
	--print(tostring(questID))
	
	--[[if questID ~= nil then
		local isCompleted, isWorldQuest = getQuestInfoById(questID)

		if removeComplete and isCompleted then
			untrackQuest(questID)
		elseif not isWorldQuest then
			trackQuest(questID, not isWorldQuest)
		end
	end]]
end

function HideQuestTrackerFrame:QUEST_ACCEPTED(event, questID)
	--print("Quest added: " .. tostring(questID))
	title = C_QuestLog.GetTitleForQuestID(questID)
	print("Quest Title: " .. title)
	print("Quest Expansion: " .. Expansion[GetQuestExpansion(questID)])
	self:showOrHideQuest(questID)
end

function HideQuestTrackerFrame:QUEST_REMOVED(event, questID)
	print("Quest removed: " .. C_QuestLog.GetTitleForQuestID(questID))
	print("Quest Expansion: " .. Expansion[GetQuestExpansion(questID)])
	--[[local numEntries, _ = C_QuestLog.GetNumQuestLogEntries()

	for index = 1, numEntries do
		local info = C_QuestLog.GetInfo(index)
		if info.isHeader then
			print("Header: " .. info.title)
		else
			print("		 - " .. info.title)
		end
	end]]
	self:showOrHideQuest(questID)
end

--[[function HideQuestTrackerFrame:OnInitialize()
	print("OnInitialize!")
		
	--Register event triggers
	
	HideQuestTrackerFrame:Update()
end]]