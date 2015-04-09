local addon, shared = ...

-- CONFIGURATION OPTIONS
-- Change TEXTSIZE to change the size things are rendered at.
local TEXTSIZE = 14

local IX_AGO = 1
local IX_SUF = 2
local IX_MIS = 3
local IX_DIS = 4

local LINK_AGO = "AFD386B0E4862D1CF"
local LINK_SUF = "AFA54F750B5F4BDB5"
local LINK_MIS = "AFDF7D1D76BA58F3C"
local LINK_DIS = "AFB13399A8E5E730D"

local BUFF_AGO	= "BFA6FB1BAE463D82B"
local BUFF_SUF	= "BFD2398235B465FED"
local BUFF_MIS	= "BFF27EA366EA0638D"
local BUFF_DIS	= "BFC515C3AB0F59096"

local LINK_DATA = {
	[LINK_AGO] = {t="Agony", u=false},
	[LINK_SUF] = {t="Suffering", u=false},
	[LINK_MIS] = {t="Misery", u=false},
	[LINK_DIS] = {t="Distress", u=false},
	[BUFF_AGO] = IX_AGO,
	[BUFF_SUF] = IX_SUF,
	[BUFF_MIS] = IX_MIS,
	[BUFF_DIS] = IX_DIS,
}

local ACTIVE_LINK = {
	{i=0, a=0, b=0, n="", s=0, c=nil},
	{i=0, a=0, b=0, n="", s=0, c=nil},
	{i=0, a=0, b=0, n="", s=0, c=nil},
	{i=0, a=0, b=0, n="", s=0, c=nil}
}

local FOUL_GROWTH = {
	["AFB64930878FEFA00"] = true,
	["AFE19AC5ADB6FEDD1"] = true,
	["AFCB4D4F5212D57AF"] = true,
	["AFE5F688FDEF4BF92"] = true,
	["AFF1319A491537D2D"] = true,
	["AFCA567E54BC4C224"] = true,
	["AFD83EA3B9B4CA086"] = true,
	["AFC373AEA3323BA8A"] = true,
	["AFA0F50296B2E2B53"] = true,
	["AFF11B93C945DA1A9"] = true,
}

local LINK_TARGET = {}
local playerNames = {}
	
local link_avail = 0

local _up_last = 0
local _up_crnt = 0
	
local fx_height = 0
local fx_width = 0

local SILENT=		99
local RELEASE=		90
local TESTING=		20
local WDOGYIELD=	15
local FUNCTIONRUN=	10
local STATUSUPDT=	8
local INFORMATION=	5
local DETAIL=		1

local activeBuffID = {}

---------------------
-- Variables
---------------------

_DefilerFG = {}
local DFG = _DefilerFG
local UIx = { fl = {} }

DFG.UI = UIx

local default_settings = {
	x = 500, y = 600, active = true, health = false
	}

local function MergeTable(o,n)
	for k,v in pairs(n) do
		if type(v) == "table" then
			if o[k] == nil then
				o[k] = {}
			end
	 	 	if type(o[k]) == 'table' then
	 			MergeTable(o[k], n[k])
	 	 	end
		else
			if o[k] == nil then
				o[k] = v
			end
		end
	end
end

function DFG.BuildUI()
	UIx.context = UI.CreateContext(addon.identifier)
	UIx.frame = UI.CreateFrame("Frame", "UIx.frame", UIx.context)
	UIx.frame:SetLayer(1)
	UIx.frame:SetVisible(false)
	
	UIx.fx_ago_icon = UI.CreateFrame("Texture", "UI.fx_ago_icon", UIx.frame)
	UIx.fx_ago_icon:SetVisible(false)
	LINK_DATA[LINK_AGO].f = UIx.fx_ago_icon
	UIx.fx_ago_icon:SetTexture("Rift", "ability_icons\\defiler_link_of_agony_a.dds")
	UIx.fx_ago_icon:SetLayer(5)	
	UIx.fx_ago_name = UI.CreateFrame("Text", "UI.fx_ago_name", UIx.fx_ago_icon)
	UIx.fx_ago_name:SetPoint("TOPLEFT", UIx.fx_ago_icon, "TOPRIGHT", 2, 0)
	UIx.fx_ago_name:SetFontSize(TEXTSIZE)
	UIx.fx_ago_name:SetText("somelongname@")
	fx_height = UIx.fx_ago_name:GetHeight()
	fx_width = fx_height * 5
	UIx.fx_ago_name:SetWidth(fx_width)
	UIx.fx_ago_name:SetLayer(5)
	UIx.fx_ago_icon:SetWidth(fx_height)
	UIx.fx_ago_icon:SetHeight(fx_height)
	UIx.fx_ago_hbar = UI.CreateFrame("Frame", "UIx.fx_ago_hbar", UIx.fx_ago_icon)
	UIx.fx_ago_hbar:SetPoint("TOPLEFT", UIx.fx_ago_icon, "TOPRIGHT", 2, 0)
	UIx.fx_ago_hbar:SetHeight(fx_height)
	UIx.fx_ago_hbar:SetBackgroundColor(0,0.25,0,1)
	UIx.fx_ago_hbar:SetWidth(0)
	UIx.fx_ago_hbar:SetLayer(3)
	
	UIx.fx_ago_cp = {}
	
	UIx.fx_ago_cp[1] = UI.CreateFrame("Texture", "UIx.fx_ago_cp1", UIx.fx_ago_icon)
	UIx.fx_ago_cp[1]:SetPoint("TOPLEFT", UIx.fx_ago_name, "TOPRIGHT", 2, 0)
	UIx.fx_ago_cp[1]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_ago_cp[1]:SetVisible(false)
	UIx.fx_ago_cp[1]:SetHeight(fx_height)
	UIx.fx_ago_cp[1]:SetWidth(fx_height)
	UIx.fx_ago_cp[1]:SetLayer(5)

	UIx.fx_ago_cp[2] = UI.CreateFrame("Texture", "UIx.fx_ago_cp2", UIx.fx_ago_icon)
	UIx.fx_ago_cp[2]:SetPoint("TOPLEFT", UIx.fx_ago_cp[1], "TOPRIGHT", 0, 0)
	UIx.fx_ago_cp[2]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_ago_cp[2]:SetVisible(false)
	UIx.fx_ago_cp[2]:SetHeight(fx_height)
	UIx.fx_ago_cp[2]:SetWidth(fx_height)
	UIx.fx_ago_cp[2]:SetLayer(5)
	
	UIx.fx_ago_cp[3] = UI.CreateFrame("Texture", "UIx.fx_ago_cp3", UIx.fx_ago_icon)
	UIx.fx_ago_cp[3]:SetPoint("TOPLEFT", UIx.fx_ago_cp[2], "TOPRIGHT", 0, 0)
	UIx.fx_ago_cp[3]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_ago_cp[3]:SetVisible(false)
	UIx.fx_ago_cp[3]:SetHeight(fx_height)
	UIx.fx_ago_cp[3]:SetWidth(fx_height)	
	UIx.fx_ago_cp[3]:SetLayer(5)
	
	UIx.fl[IX_AGO] = { i=UIx.fx_ago_icon, n=UIx.fx_ago_name, c=UIx.fx_ago_cp, h=UIx.fx_ago_hbar }

	UIx.fx_suf_icon = UI.CreateFrame("Texture", "UI.fx_suf_icon", UIx.frame)
	UIx.fx_suf_icon:SetVisible(false)
	LINK_DATA[LINK_SUF].f = UIx.fx_suf_icon
	UIx.fx_suf_icon:SetTexture("Rift", "ability_icons\\defiler_link_of_suffering.dds")
	UIx.fx_suf_icon:SetLayer(5)
	UIx.fx_suf_name = UI.CreateFrame("Text", "UI.fx_suf_name", UIx.fx_suf_icon)
	UIx.fx_suf_name:SetPoint("TOPLEFT", UIx.fx_suf_icon, "TOPRIGHT", 2, 0)
	UIx.fx_suf_name:SetFontSize(TEXTSIZE)
	UIx.fx_suf_name:SetText("somelongname@")
	UIx.fx_suf_name:SetWidth(fx_width)
	UIx.fx_suf_name:SetLayer(5)
	UIx.fx_suf_icon:SetWidth(fx_height)
	UIx.fx_suf_icon:SetHeight(fx_height)
	UIx.fx_suf_hbar = UI.CreateFrame("Frame", "UIx.fx_suf_hbar", UIx.fx_suf_icon)
	UIx.fx_suf_hbar:SetPoint("TOPLEFT", UIx.fx_suf_icon, "TOPRIGHT", 2, 0)
	UIx.fx_suf_hbar:SetHeight(fx_height)
	UIx.fx_suf_hbar:SetBackgroundColor(0,0.25,0,1)
	UIx.fx_suf_hbar:SetWidth(0)
	UIx.fx_suf_hbar:SetLayer(3)

	UIx.fx_suf_cp = {}
	
	UIx.fx_suf_cp[1] = UI.CreateFrame("Texture", "UIx.fx_suf_cp1", UIx.fx_suf_icon)
	UIx.fx_suf_cp[1]:SetPoint("TOPLEFT", UIx.fx_suf_name, "TOPRIGHT", 2, 0)
	UIx.fx_suf_cp[1]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_suf_cp[1]:SetVisible(false)
	UIx.fx_suf_cp[1]:SetHeight(fx_height)
	UIx.fx_suf_cp[1]:SetWidth(fx_height)
	UIx.fx_suf_cp[1]:SetLayer(5)

	UIx.fx_suf_cp[2] = UI.CreateFrame("Texture", "UIx.fx_suf_cp2", UIx.fx_suf_icon)
	UIx.fx_suf_cp[2]:SetPoint("TOPLEFT", UIx.fx_suf_cp[1], "TOPRIGHT", 0, 0)
	UIx.fx_suf_cp[2]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_suf_cp[2]:SetVisible(false)
	UIx.fx_suf_cp[2]:SetHeight(fx_height)
	UIx.fx_suf_cp[2]:SetWidth(fx_height)
	UIx.fx_suf_cp[2]:SetLayer(5)

	UIx.fx_suf_cp[3] = UI.CreateFrame("Texture", "UIx.fx_suf_cp3", UIx.fx_suf_icon)
	UIx.fx_suf_cp[3]:SetPoint("TOPLEFT", UIx.fx_suf_cp[2], "TOPRIGHT", 0, 0)
	UIx.fx_suf_cp[3]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_suf_cp[3]:SetVisible(false)
	UIx.fx_suf_cp[3]:SetHeight(fx_height)
	UIx.fx_suf_cp[3]:SetWidth(fx_height)
	UIx.fx_suf_cp[3]:SetLayer(5)
	
	UIx.fl[IX_SUF] = { i=UIx.fx_suf_icon, n=UIx.fx_suf_name, c=UIx.fx_suf_cp, h=UIx.fx_suf_hbar }
	
	UIx.fx_mis_icon = UI.CreateFrame("Texture", "UI.fx_mis_icon", UIx.frame)
	UIx.fx_mis_icon:SetVisible(false)
	LINK_DATA[LINK_MIS].f = UIx.fx_mis_icon
	UIx.fx_mis_icon:SetTexture("Rift", "ability_icons\\defiler_link_of_misery_a.dds")
	UIx.fx_mis_icon:SetLayer(5)
	UIx.fx_mis_name = UI.CreateFrame("Text", "UI.fx_mis_name", UIx.fx_mis_icon)
	UIx.fx_mis_name:SetPoint("TOPLEFT", UIx.fx_mis_icon, "TOPRIGHT", 2, 0)
	UIx.fx_mis_name:SetFontSize(TEXTSIZE)
	UIx.fx_mis_name:SetText("somelongname@")
	UIx.fx_mis_name:SetWidth(fx_width)
	UIx.fx_mis_name:SetLayer(5)
	UIx.fx_mis_icon:SetWidth(fx_height)
	UIx.fx_mis_icon:SetHeight(fx_height)
	UIx.fx_mis_hbar = UI.CreateFrame("Frame", "UIx.fx_mis_hbar", UIx.fx_mis_icon)
	UIx.fx_mis_hbar:SetPoint("TOPLEFT", UIx.fx_mis_icon, "TOPRIGHT", 2, 0)
	UIx.fx_mis_hbar:SetHeight(fx_height)
	UIx.fx_mis_hbar:SetBackgroundColor(0,0.25,0,1)
	UIx.fx_mis_hbar:SetWidth(0)
	UIx.fx_mis_hbar:SetLayer(3)

	UIx.fx_mis_cp = {}
	
	UIx.fx_mis_cp[1] = UI.CreateFrame("Texture", "UIx.fx_mis_cp1", UIx.fx_mis_icon)
	UIx.fx_mis_cp[1]:SetPoint("TOPLEFT", UIx.fx_mis_name, "TOPRIGHT", 2, 0)
	UIx.fx_mis_cp[1]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_mis_cp[1]:SetVisible(false)
	UIx.fx_mis_cp[1]:SetHeight(fx_height)
	UIx.fx_mis_cp[1]:SetWidth(fx_height)
	UIx.fx_mis_cp[1]:SetLayer(5)

	UIx.fx_mis_cp[2] = UI.CreateFrame("Texture", "UIx.fx_mis_cp2", UIx.fx_mis_icon)
	UIx.fx_mis_cp[2]:SetPoint("TOPLEFT", UIx.fx_mis_cp[1], "TOPRIGHT", 0, 0)
	UIx.fx_mis_cp[2]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_mis_cp[2]:SetVisible(false)
	UIx.fx_mis_cp[2]:SetHeight(fx_height)
	UIx.fx_mis_cp[2]:SetWidth(fx_height)
	UIx.fx_mis_cp[2]:SetLayer(5)

	UIx.fx_mis_cp[3] = UI.CreateFrame("Texture", "UIx.fx_mis_cp3", UIx.fx_mis_icon)
	UIx.fx_mis_cp[3]:SetPoint("TOPLEFT", UIx.fx_mis_cp[2], "TOPRIGHT", 0, 0)
	UIx.fx_mis_cp[3]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_mis_cp[3]:SetVisible(false)
	UIx.fx_mis_cp[3]:SetHeight(fx_height)
	UIx.fx_mis_cp[3]:SetWidth(fx_height)	
	UIx.fx_mis_cp[3]:SetLayer(5)

	UIx.fl[IX_MIS] = { i=UIx.fx_mis_icon, n=UIx.fx_mis_name, c=UIx.fx_mis_cp, h=UIx.fx_mis_hbar }
	
	UIx.fx_dis_icon = UI.CreateFrame("Texture", "UI.fx_dis_icon", UIx.frame)
	UIx.fx_dis_icon:SetVisible(false)
	LINK_DATA[LINK_DIS].f = UIx.fx_dis_icon
	UIx.fx_dis_icon:SetTexture("Rift", "ability_icons\\defiler_link_of_distress.dds")
	UIx.fx_dis_icon:SetLayer(5)
	UIx.fx_dis_name = UI.CreateFrame("Text", "UI.fx_dis_name", UIx.fx_dis_icon)
	UIx.fx_dis_name:SetPoint("TOPLEFT", UIx.fx_dis_icon, "TOPRIGHT", 2, 0)
	UIx.fx_dis_name:SetFontSize(TEXTSIZE)
	UIx.fx_dis_name:SetText("somelongname@")
	UIx.fx_dis_name:SetWidth(fx_width)
	UIx.fx_dis_name:SetLayer(5)
	UIx.fx_dis_icon:SetWidth(fx_height)
	UIx.fx_dis_icon:SetHeight(fx_height)
	UIx.fx_dis_hbar = UI.CreateFrame("Frame", "UIx.fx_dis_hbar", UIx.fx_dis_icon)
	UIx.fx_dis_hbar:SetPoint("TOPLEFT", UIx.fx_dis_icon, "TOPRIGHT", 2, 0)
	UIx.fx_dis_hbar:SetHeight(fx_height)
	UIx.fx_dis_hbar:SetBackgroundColor(0,0.25,0,1)
	UIx.fx_dis_hbar:SetWidth(0)
	UIx.fx_dis_hbar:SetLayer(3)
	
	UIx.fx_dis_cp = {}
	
	UIx.fx_dis_cp[1] = UI.CreateFrame("Texture", "UIx.fx_dis_cp1", UIx.fx_dis_icon)
	UIx.fx_dis_cp[1]:SetPoint("TOPLEFT", UIx.fx_dis_name, "TOPRIGHT", 2, 0)
	UIx.fx_dis_cp[1]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_dis_cp[1]:SetVisible(false)
	UIx.fx_dis_cp[1]:SetHeight(fx_height)
	UIx.fx_dis_cp[1]:SetWidth(fx_height)
	UIx.fx_dis_cp[1]:SetLayer(5)

	UIx.fx_dis_cp[2] = UI.CreateFrame("Texture", "UIx.fx_dis_cp2", UIx.fx_dis_icon)
	UIx.fx_dis_cp[2]:SetPoint("TOPLEFT", UIx.fx_dis_cp[1], "TOPRIGHT", 0, 0)
	UIx.fx_dis_cp[2]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_dis_cp[2]:SetVisible(false)
	UIx.fx_dis_cp[2]:SetHeight(fx_height)
	UIx.fx_dis_cp[2]:SetWidth(fx_height)
	UIx.fx_dis_cp[2]:SetLayer(5)

	UIx.fx_dis_cp[3] = UI.CreateFrame("Texture", "UIx.fx_dis_cp3", UIx.fx_dis_icon)
	UIx.fx_dis_cp[3]:SetPoint("TOPLEFT", UIx.fx_dis_cp[2], "TOPRIGHT", 0, 0)
	UIx.fx_dis_cp[3]:SetTexture("Rift", "ability_icons\\defiler_foul_growth_b.dds")
	UIx.fx_dis_cp[3]:SetVisible(false)
	UIx.fx_dis_cp[3]:SetHeight(fx_height)
	UIx.fx_dis_cp[3]:SetWidth(fx_height)	
	UIx.fx_dis_cp[3]:SetLayer(5)

	UIx.fl[IX_DIS] = { i=UIx.fx_dis_icon, n=UIx.fx_dis_name, c=UIx.fx_dis_cp, h=UIx.fx_dis_hbar }

	UIx.fx_dis_icon:SetPoint("BOTTOMLEFT", UIx.frame, "BOTTOMLEFT", 2,-2)
	UIx.fx_mis_icon:SetPoint("BOTTOMLEFT", UIx.fx_dis_icon, "TOPLEFT", 0,-2)
	UIx.fx_suf_icon:SetPoint("BOTTOMLEFT", UIx.fx_mis_icon, "TOPLEFT", 0,-2)
	UIx.fx_ago_icon:SetPoint("BOTTOMLEFT", UIx.fx_suf_icon, "TOPLEFT", 0,-2)
	
	UIx.frame:SetWidth((fx_height*9)+8)
	UIx.frame:SetBackgroundColor(0.2, 0.2, 0.2, 0.3)

	UIx.frame:EventAttach(Event.UI.Input.Mouse.Left.Down, function(self, h)
		self.MouseDown = true
		local mouseData = Inspect.Mouse()
		self.sx = mouseData.x - UIx.frame:GetLeft()
		self.sy = mouseData.y - UIx.frame:GetTop()
	end, "Event.UI.Input.Mouse.Left.Down", 0)

	UIx.frame:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function(self, h)
		if self.MouseDown then
			local nx, ny
			local mouseData = Inspect.Mouse()
			nx = mouseData.x - self.sx
			ny = mouseData.y - self.sy
			UIx.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", nx,ny)
		end
	end, "Event.UI.Input.Mouse.Cursor.Move")
	
	UIx.frame:EventAttach(Event.UI.Input.Mouse.Left.Up, function(self, h)
		if self.MouseDown then
			self.MouseDown = false
		end
		DefilerFG_Settings.x = UIx.frame:GetLeft()
		DefilerFG_Settings.y = UIx.frame:GetTop()
	end, "Event.UI.Input.Mouse.Left.Up", 0)
	
end

function DFG.SetupEvents()
	if DefilerFG_Settings.active then
		Command.Event.Attach(Event.Buff.Add, DFG.Event_Buff_Add, "Event.Buff.Add")
		Command.Event.Attach(Event.Buff.Remove, DFG.Event_Buff_Remove, "Event.Buff.Remove")
		if DefilerFG_Settings.health then
			Command.Event.Attach(Event.Unit.Detail.Health, DFG.Event_Unit_Detail_Health, "Event.Unit.Detail.Health")
		end
	else
		Command.Event.Detach(Event.Buff.Add, nil, nil, nil, addon.identifier)
		Command.Event.Detach(Event.Buff.Remove, nil, nil, nil, addon.identifier)
		if DefilerFG_Settings.health then
			Command.Event.Detach(Event.Unit.Detail.Health, nil, nil, nil, addon.identifier)
		end
	end
	print(string.format("DefilerFG: ACTIVE=%s, HEALTH=%s", tostring(DefilerFG_Settings.active), tostring(DefilerFG_Settings.health)))
	DFG.SetFrameHeight()
end

function DFG.Event_Addon_SavedVariables_Load_End(h,a)
	if a == addon.identifier then
		if DefilerFG_Settings == nil then
			DefilerFG_Settings = {}
		end		
		MergeTable(DefilerFG_Settings, default_settings)
		UIx.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", DefilerFG_Settings.x, DefilerFG_Settings.y)
		DFG.SetupEvents()
	end
end

function DFG.Event_Buff_Remove(h,u,t)
	if LINK_TARGET[u] then
		local update = false
		for k,v in pairs(t) do
			if activeBuffID[k] then
				local lid = LINK_TARGET[u]
				if ACTIVE_LINK[lid].b == k then
					ACTIVE_LINK[lid].a = 0
					activeBuffID[k] = nil
					LINK_TARGET[u] = nil
					update = true
				elseif ACTIVE_LINK[lid].fb == k then
					ACTIVE_LINK[lid].s = 0
					activeBuffID[k] = nil
					update = true
				end
			end			
		end
		if update then
			DFG.UpdateStatus()
		end		
	end
end

function DFG.Event_Buff_Add(h,u,t)
	local bd = Inspect.Buff.Detail(u,t)
	local update = false
	for k,v in pairs(bd) do
		if v.caster == DFG.playerID then
			local lnkbuff = LINK_DATA[v.type]
			if lnkbuff then
				activeBuffID[k] = true
				ACTIVE_LINK[lnkbuff].i = u
				ACTIVE_LINK[lnkbuff].a = 1
				ACTIVE_LINK[lnkbuff].b = k
				ACTIVE_LINK[lnkbuff].fb = nil
				ACTIVE_LINK[lnkbuff].s = 0
				LINK_TARGET[u] = lnkbuff
				if playerNames[u] == nil then
					local pd = Inspect.Unit.Detail(u)
					if pd then
						playerNames[u] = pd.name
					end
				end
				if DefilerFG_Settings.active and DefilerFG_Settings.health then
					DFG.Event_Unit_Detail_Health(0,{[u] = true})
				end
				update = true
			elseif FOUL_GROWTH[v.abilityNew] then
				local lid = LINK_TARGET[u]
				if lid then
					ACTIVE_LINK[lid].s = v.stack or 1
					ACTIVE_LINK[lid].fb = k
					activeBuffID[k] = true
					if playerNames[u] == nil then
						local pd = Inspect.Unit.Detail(u)
						if pd then
							playerNames[u] = pd.name
						end
					end
					update = true
				end
			end		
		end
	end
	if update then
		DFG.UpdateStatus()
	end
end

function DFG.UpdateStatus()
	for k,v in pairs(ACTIVE_LINK) do
		if v.a == 1 then
			UIx.fl[k].n:SetText(playerNames[v.i] or v.i)
			UIx.fl[k].n:SetVisible(true)
			if v.s == 0 then
				UIx.fl[k].c[1]:SetVisible(false)
				UIx.fl[k].c[2]:SetVisible(false)
				UIx.fl[k].c[3]:SetVisible(false)
			elseif v.s == 1 then
				UIx.fl[k].c[1]:SetVisible(true)
				UIx.fl[k].c[2]:SetVisible(false)
				UIx.fl[k].c[3]:SetVisible(false)
			elseif v.s == 2 then
				UIx.fl[k].c[1]:SetVisible(true)
				UIx.fl[k].c[2]:SetVisible(true)
				UIx.fl[k].c[3]:SetVisible(false)
			elseif v.s == 3 then
				UIx.fl[k].c[1]:SetVisible(true)
				UIx.fl[k].c[2]:SetVisible(true)
				UIx.fl[k].c[3]:SetVisible(true)
			end
		elseif v.a == 0 then
			UIx.fl[k].c[1]:SetVisible(false)
			UIx.fl[k].c[2]:SetVisible(false)
			UIx.fl[k].c[3]:SetVisible(false)
			UIx.fl[k].n:SetVisible(false)
			ACTIVE_LINK[k].a = -1
		end
	end
end

function DFG.SetFrameHeight()
	local link_avail = 0
	for k,v in pairs(LINK_DATA) do
		if type(v) == "table" then
			if v.u == true then
				link_avail = link_avail+1
				v.f:SetVisible(true)
			else
				v.f:SetVisible(false)
			end
		end
	end
	if link_avail > 0 and DefilerFG_Settings.active then
		UIx.frame:SetHeight(((fx_height+2)*link_avail)+2)
		UIx.frame:SetVisible(true)
	else
		UIx.frame:SetVisible(false)
	end
end

function DFG.Event_Ability_New_Remove(h,t)
	local _abChange = false
	for k,v in pairs(t) do
		if LINK_DATA[k] then
			LINK_DATA[k].u = false
			--print(string.format("LOSE> %s", LINK_DATA[k].t))
			_abChange = true
		end
	end
	if _abChange then
		DFG.SetFrameHeight()
	end
end

function DFG.Event_Ability_New_Add(h,t)
	local _abChange = false
	for k,v in pairs(t) do
		if LINK_DATA[k] then
			--print(string.format("GAIN> %s", LINK_DATA[k].t))
			LINK_DATA[k].u = true
			_abChange = true
		end
	end
	if _abChange then
		DFG.SetFrameHeight()
	end
end

function DFG.Event_Unit_Detail_Health(h,u)
	for k,v in pairs(u) do
		if LINK_TARGET[k] then
			local pd = Inspect.Unit.Detail(k)
			if pd and pd.health and pd.healthMax then
				UIx.fl[LINK_TARGET[k]].h:SetWidth(math.floor((pd.health/pd.healthMax) * fx_width))
			else
				UIx.fl[LINK_TARGET[k]].h:SetWidth(0)
			end
		end
	end
end

function DFG.Command_Slash_Register(h, args)
	local r = {}
	local numargs = 0
	for token in string.gmatch(args, "[^%s]+") do
		numargs=numargs+1
		r[numargs] = token
	end

	if numargs > 0 then
		if r[1] == "active" then
			DefilerFG_Settings.active = not DefilerFG_Settings.active
			DFG.SetupEvents()
		elseif r[1] == "health" then
			DefilerFG_Settings.health = not DefilerFG_Settings.health
			if DefilerFG_Settings.active then
				if DefilerFG_Settings.health then
					Command.Event.Attach(Event.Unit.Detail.Health, DFG.Event_Unit_Detail_Health, "Event.Unit.Detail.Health")
				else
					Command.Event.Detach(Event.Unit.Detail.Health, nil, nil, nil, addon.identifier)
				end
			end
			print(string.format("DefilerFG: ACTIVE=%s, HEALTH=%s", tostring(DefilerFG_Settings.active), tostring(DefilerFG_Settings.health)))		
		elseif r[1] == "spy" then
			local pid = Inspect.Unit.Lookup("player.target")
			if pid ~= nil then
				DFG.playerID = Inspect.Unit.Lookup("player.target")
				DFG.Event_Ability_New_Add(0, {[LINK_AGO]=true, [LINK_SUF]=true,[LINK_MIS]=true,[LINK_DIS]=true})
			else
				print("Unable to set spy target")
			end
		else
			print("USAGE:")
			print("/dfg active - Toggles active status")
			print("/dfg health - Toggles health tracking when in active status")
		end
	end
end
		
DFG.BuildUI()

UIx.fx_ago_name:SetText("")
UIx.fx_suf_name:SetText("")
UIx.fx_mis_name:SetText("")
UIx.fx_dis_name:SetText("")

DFG.playerID = Inspect.Unit.Lookup("player")

Command.Event.Attach(Event.Addon.SavedVariables.Load.End, DFG.Event_Addon_SavedVariables_Load_End, "Event.Addon.SavedVariables.Load.End")
Command.Event.Attach(Event.Ability.New.Add, DFG.Event_Ability_New_Add, "Event.Ability.New.Add")
Command.Event.Attach(Event.Ability.New.Remove, DFG.Event_Ability_New_Remove, "Event.Ability.New.Add")
Command.Event.Attach(Command.Slash.Register("dfg"), DFG.Command_Slash_Register, "Command.Slash.Register")
