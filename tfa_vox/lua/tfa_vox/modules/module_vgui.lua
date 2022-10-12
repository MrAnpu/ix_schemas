if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "VGUI Configurator"
MODULE.description = "Allows configuration using VGUI"
MODULE.author = "TFA"
MODULE.realm = "shared"
MODULE.activedefault = true
MODULE.options = {
	["primarycolor"] = {
		["name"] = "Accent Color",
		["description"] = "Accent color (e.g. menu bar)",
		["type"] = "color",--integer,float,boolean,string,vector,color
		["default"] = Color(3,169,244,255)
	},
	["secondarycolor"] = {
		["name"] = "Secondary Color",
		["description"] = "Secondary color (e.g. button background)",
		["type"] = "color",--integer,float,boolean,string,vector,color
		["default"] = Color(158,158,158,255)
	}
}
local Palette = {}
Palette["transparent"] = Color(255,255,255,0)
Palette["background"] = Color(255,255,255,255)
Palette["default_primary"] = Color(3,169,244,255)
Palette["dark_primary"] = Color(2,136,209,255)
Palette["light_primary"] = Color(179,229,252,255)
Palette["accent"] = Color(158,158,158,255)
Palette["divider"] = Color(182,182,182,255)
Palette["text_primary"] = Color(33,33,33,255)
Palette["text_secondary"] = Color(114,114,114,255)
Palette["text_accent_primary"] = Color(255,255,255,255)
Palette["text_accent_secondary"] = Color(255-114,255-114,255-114,255)
Palette["shadow"] = Color(0,0,0,192)

local myclass = MODULE.class or MODULE.classname or "module_vgui"

local function GetPrimaryColorOption()
	local mod = TFAVOX_Modules[myclass]
	if !mod then return Palette["default_primary"] end
	local opt = mod.options
	if !opt then return Palette["default_primary"] end

	return TFAVOX_Modules[myclass].options.primarycolor.value or Palette["default_primary"]
end

local function GetSecondaryColorOption()
	local mod = TFAVOX_Modules[myclass]
	if !mod then return Palette["accent"] end
	local opt = mod.options
	if !opt then return Palette["accent"] end

	return TFAVOX_Modules[myclass].options.secondarycolor.value or Palette["accent"]
end

local transitionfactor = 10

local dividerheight = 1
local function Material_ExpandableRow(self)
	local h = self:GetTall()
	self.Height = self.Height or h
	self.ActiveHeight = self.ActiveHeight or Height
	local targval = self.Active and self.ActiveHeight or self.Height
	if self.Active then
		h = math.Approach(h,targval,math.max( (targval-h)*RealFrameTime()*transitionfactor, (targval)*RealFrameTime()*0.75, 1 ) )
	else
		h = math.Approach(h,targval,math.min( (targval-h)*RealFrameTime()*transitionfactor, (targval)*RealFrameTime()*0.75, -1 ) )
	end
	--[[
	if math.abs( targval -h )<targval*0.1 then
		h = math.Approach(h,targval,(targval)*RealFrameTime()*0.5)
	end
	]]--
	self:SetHeight(h)
end

local function Material_SlidingContentPanel(self)
	local par = self:GetParent()
	if IsValid(par) then
		self:SetSize( par:GetWide(), par:GetTall()-(idealbarheight or par.idealbarheight) )
	end

	local x,y = self:GetPos()
	local w,h = self:GetWide(),self:GetTall()

	local targx = (par.activepanel==self) and 0 or w

	x = math.Approach(x,targx,(targx-x)*RealFrameTime()*transitionfactor)

	if IsValid(par.activepanel) and (par.activepanel!=self) then
		local ap = par.activepanel
		local apx,apy = ap:GetPos()
		local apw,aph = ap:GetWide(),ap:GetTall()

		x = apx + apw

		if (par.activepanel!=self) and math.abs(x)>= w*0.99 then
			self:SetVisible(false)
		end

		self:SetPos(x,y)
	else
		self:SetPos(x,y)
	end
end

local function Material_SpinIcon(self)
	if self.icon then
		local targval = self:IsHovered() and 15 or 0
		self.icon.Rotation = math.Approach(self.icon.Rotation,targval,(targval-self.icon.Rotation)*RealFrameTime()*transitionfactor)
	end
end

local function Material_PanelDraw_Basic(self,w,h)
	--[[
	if !self.hasinitmaterial then
		self.hasinitmaterial = true
		self:SetExpensiveShadow(self.Elevation or 3, Palette["shadow"])
	end
	]]--
	self.Elevation = self.Elevation or 3
	draw.NoTexture()
	draw.RoundedBox(0,0+self.Elevation,0+self.Elevation,w,h,Palette["shadow"])
	draw.RoundedBox(0,0,0,w,h,self.Color or color_white)

end

local circlemat96
local circlemat64

local function Material_PanelDraw_Circle(self,w,h)
	if !circlemat96 then
		circlemat96 = Material("md_icons48/flatcircle_2x.png")
	end
	if !circlemat64 then
		circlemat64 = Material("md_icons32/flatcircle_2x.png")
	end
	local radius = math.floor( ( w / 2 ) / 8 ) * 8
	self.Elevation = self.Elevation or 3
	draw.NoTexture()

	local xx = w/2-radius
	local yy = h/2-radius
	surface.SetMaterial( ( radius%16 == 0 ) and circlemat64 or circlemat96 )
	surface.SetDrawColor( Palette["shadow"] )
	surface.DrawTexturedRect( xx + self.Elevation,yy +self.Elevation, radius*2, radius*2 )
	surface.SetDrawColor( self.Color or color_white )
	surface.DrawTexturedRect( xx,yy, radius*2, radius*2 )

end

local function Material_DImage_Icon(self,w,h)

	local imageszx = math.Round( w * ( self.Scale or 2/3 ) / 16 ) * 16
	local imageszy = math.Round( h * ( self.Scale or 2/3 ) / 16 ) * 16

	if imageszx>imageszy then imageszx = imageszy else imageszy = imageszx end

	if !self.cachedimages then self.cachedimages = {} end

	local myimg = self.Image or self:GetImage()

	if !self.cachedimages[myimg] then self.cachedimages[myimg] = Material(myimg,"noclamp smooth") end
	if self.cachedimages[myimg] then
		surface.SetDrawColor( self.ImageColor or self.Color or self:GetImageColor() )
		surface.SetMaterial( self.cachedimages[myimg] )
		local x,y,x0,y0 = w/2,h/2,0,0
		local rot = self.Rotation or 0

		local c = math.cos( math.rad( rot ) )
		local s = math.sin( math.rad( rot ) )

		local newx = y0 * s - x0 * c
		local newy = y0 * c + x0 * s

		surface.DrawTexturedRectRotated( x + newx, y + newy, imageszx, imageszy, rot )
	end

end

local function Material_ProcessVBar( vbar )

	if IsValid(vbar) then
		--[[
		function vbar:OnCursorMoved( x, y )

			if ( !self.Enabled ) then return end
			if ( !self.Dragging ) then return end

			local x = 0
			local y = gui.MouseY()
			local x, y = self:ScreenToLocal( x, y )

			-- Uck.
			y = y - self.btnUp:GetTall()
			y = y - self.HoldPos

			local TrackSize = self:GetTall() - self.btnGrip:GetTall()

			y = math.Clamp( ( y ) / TrackSize , 0, 1)

			self:SetScroll( y * self.CanvasSize - self:GetWide() )

		end
		function vbar:PerformLayout()

			local Wide = self:GetWide()
			local Scroll = self:GetScroll() / self.CanvasSize
			local BarSize = math.max( self:BarScale() * ( self:GetTall() - ( Wide * 2 ) ), 10 )
			local Track = self:GetTall() - BarSize
			Track = Track + 1

			Scroll = Scroll * Track

			self.btnGrip:SetPos( 0, Scroll )
			self.btnGrip:SetSize( Wide, BarSize+Wide )

			self.btnUp:SetSize(0,0)
			self.btnDown:SetSize(0,0)
		end
		]]--

		function vbar:PerformLayout()

			local Wide = self:GetWide()
			local Scroll = self:GetScroll() / self.CanvasSize
			local BarSize = math.max( self:BarScale() * ( self:GetTall() - ( Wide * 2 ) ), 10 )
			local Track = self:GetTall() - ( Wide * 2 ) - BarSize
			Track = Track + 1

			self.MyWide = Wide
			self.MyBarSize = BarSize

			Scroll = Scroll * Track

			self.MyScroll = Scroll

			self.btnGrip:SetPos( 0, Wide + Scroll )
			self.btnGrip:SetSize( Wide, BarSize )

			self.btnUp:SetPos( 0, 0, Wide, Wide )
			self.btnUp:SetSize( Wide, Wide )

			self.btnUp:SetVisible(false)

			self.btnDown:SetPos( 0, self:GetTall() - Wide, Wide, Wide )
			self.btnDown:SetSize( Wide, Wide )

			self.btnDown:SetVisible(false)

		end

		function vbar.btnUp:Paint()

		end
		function vbar.btnDown:Paint()

		end
		function vbar.btnGrip:Paint()

		end
		function vbar:Paint(w,h)
			self.MyWide = self.MyWide or self:GetWide()
			self.MyBarSize = self.MyBarSize or 64
			self.MyScroll = self.MyScroll or 0
			local x,y
			x=0
			y=self.MyScroll
			draw.NoTexture()
			draw.RoundedBox(0,x,y,self.MyWide,self.MyBarSize+self.MyWide*2,self.btnGrip.Color or color_white)
		end
		vbar.btnGrip.Color = GetSecondaryColorOption()
		vbar.btnGrip.Paint = Material_PanelDraw_Basic
	end

end



local function Material_DrawTextEntry(self,w,h)
	draw.RoundedBox(0,0,h-dividerheight*2,w,dividerheight*2,self.EntryColor or self.Color)
	if self.DrawTextEntryText then
		self:DrawTextEntryText( self.m_colText, self.m_colHighlight, self.m_colCursor )
	else
		draw.SimpleText( self:GetValue(), self.m_FontName or "DermaDefault", 0, h, self.m_colText or color_white, TEXT_ALIGN_LEFt, TEXT_ALIGN_TOP )
	end
end


if CLIENT then

	local Material_Icons = {
		["back"] = "md_icons48/arrow-left-white.png",
		["reset"] = "md_icons48/reset-white.png",
		["edit"] = "md_icons48/ic_mode_edit_white_48dp_1x.png",
		["menu"] = "md_icons48/menu-white.png",
		["details"] = "md_icons48/details-white.png",
		["check"] = "md_icons48/check.png",
		["x"] = "md_icons96/x.png"
	}

	surface.CreateFont( "TFAVOX_Material_Large", {
		font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 32,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	surface.CreateFont( "TFAVOX_Material_Default", {
		font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 24,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	surface.CreateFont( "TFAVOX_Material_Small", {
		font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 16,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	surface.CreateFont( "TFAVOX_Material_Tiny", {
		font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		extended = false,
		size = 12,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

	local Frame

	local SideBarItems = {
		{ ['text'] = "Close", ['font'] = "TFAVOX_Material_Default", ['color'] = Palette["background"], ['textcolor'] = Palette["text_primary"], ['func'] = function(self)
			if IsValid(Frame) then Frame:Remove() end
		end },
		{ ['text'] = "Reset", ['font'] = "TFAVOX_Material_Default", ['color'] = Palette["background"], ['textcolor'] = Palette["text_primary"], ['func'] = function(self)
			net.Start("tfa_vox_requestreset")
			net.SendToServer()
		end }

		--[[,
		{ ['text'] = "Focus Selector Panel", ['font'] = "TFAVOX_Material_Default", ['color'] = Palette["background"], ['textcolor'] = Palette["text_primary"], ['func'] = function(self)
			if IsValid(Frame) then
				local rootpanel = Frame.root
				if IsValid(rootpanel) then
					if rootpanel.selectorpanel and !rootpanel.selectorpanel.Active then
						rootpanel:SetFocusedPanel( rootpanel.selectorpanel )
					end
				end
			end
		end }	,
		{ ['text'] = "Focus Config Panel", ['font'] = "TFAVOX_Material_Default", ['color'] = Palette["background"], ['textcolor'] = Palette["text_primary"], ['func'] = function(self)
			if IsValid(Frame) then
				local rootpanel = Frame.root
				if IsValid(rootpanel) then
					if rootpanel.configpanel and !rootpanel.configpanel.Active then
						rootpanel:SetFocusedPanel( rootpanel.configpanel )
					end
				end
			end
		end }	]]--

	}

	concommand.Add("tfa_vox_vgui_open",function()

		local scrw,scrh = ScrW(),ScrH()
		local rootw,rooth = math.Round( math.min(scrw,scrh*1.5) / 4 ) * 4,math.Round( scrh*0.75 / 4 ) * 4

		local idealbarheight = math.max( math.Round( math.min(rooth*0.15,64) / 24 ) * 24, 24 )

		local sidebarwidth = math.Round( math.max( rootw/8, rooth/4) / 4 ) * 4

		if IsValid(Frame) then Frame:Remove() end

		--[[ *Frame* Work ]]--

		Frame = vgui.Create( "DFrame" )
		Frame:SetPos( scrw/2-rootw/2, scrh/2-rooth/2 )
		Frame:SetSize( rootw, rooth )
		Frame:SetTitle( "" )
		Frame:SetVisible( true )
		Frame:SetDraggable( true )
		Frame:ShowCloseButton( false )
		Frame:SetSizable( true )
		Frame:MakePopup()
		Frame.Elevation = 3
		Frame:SetZPos( -15 )
		Frame.Color = Palette["transparent"]
		Frame.Paint = Material_PanelDraw_Basic

		Frame:DockPadding(1,1,1,1)
		Frame:DockMargin(0,0,0,0)

		local rootpanel = vgui.Create( "DPanel", Frame )
		rootpanel:Dock(FILL)
		rootpanel:SetZPos( -14 )
		rootpanel.Color = Palette["background"]
		rootpanel.Elevation = 0
		rootpanel.Paint = Material_PanelDraw_Basic
		rootpanel.idealbarheight = idealbarheight

		function rootpanel:SetFocusedPanel( p )
			if self.activepanel != p then
				if IsValid(self.activepanel) then
					self.activepanel:SetVisible(true)
					self.activepanel:Think()
					local px,py = self.activepanel:GetPos()
					self.activepanel:SetPos(0,py)
				end
				if IsValid(p) then
					local px,py = p:GetPos()
					p:SetPos(-self:GetWide(),py)
					self.activepanel = p
					p:SetVisible(true)
					p:Think()
				end
			end
		end

		Frame.root = rootpanel

		--[[ Sidebar ]]--

		local sidebar = vgui.Create( "DPanel", rootpanel )
		sidebar = sidebar
		sidebar:SetPos(-sidebarwidth,idealbarheight)
		sidebar:SetSize(sidebarwidth,rooth-idealbarheight)
		sidebar:SetZPos( 1 )
		sidebar.Color = Palette["background"]
		sidebar.Elevation = 6
		sidebar.SlideStatus = 0
		sidebar.Active = false
		sidebar.Items = {}
		sidebar.Think = function( self )
			self:SetPos( ( 1 - self.SlideStatus ) * (-sidebarwidth), idealbarheight )
			local activenum = self.Active and 1 or 0
			self.SlideStatus = math.Approach( self.SlideStatus, activenum, RealFrameTime()*( activenum - self.SlideStatus )*5 )
			self:SetSize( sidebarwidth, rootpanel:GetTall()-idealbarheight )
			if self.SlideStatus<0.05 and !self.Active then
				self:SetVisible(false)
			end
		end
		sidebar.Paint = Material_PanelDraw_Basic
		function sidebar:SetActive( isactive )
			self:SetVisible(true)
			if isactive==nil then
				self.Active = !self.Active
			else
				self.Active = isactive and true or false
			end
			local shadowpanel = shadowpanel or self.shadowpanel
			if IsValid( shadowpanel ) then
				shadowpanel.Active = self.Active
				shadowpanel:SetVisible(self:IsVisible())
			end
		end

		local sidebaritemheight = math.max( 24, math.min( sidebar:GetTall() / #SideBarItems - dividerheight * #SideBarItems, idealbarheight) )

		for k,v in ipairs(SideBarItems) do
			local item = vgui.Create( "DButton", sidebar )
			item:Dock(TOP)
			item:SetHeight(sidebaritemheight)
			item:SetText(v.text or "Sample Text")
			item.Color = v.Color or Palette["background"]
			item:SetTextColor( v.TextColor or Palette["text_primary"] )
			item:SetFont( v.Font or "TFAVOX_Material_Default" )
			item.Paint = Material_PanelDraw_Basic
			item.clickyfunc = v.func
			item.DoClick = function( self )
				sidebar:SetActive(false)
				if self.clickyfunc then self.clickyfunc() end
			end
			table.insert(sidebar.Items, item)
			--if k<#SideBarItems then
				local divider = vgui.Create( "DPanel", sidebar )
				divider:Dock(TOP)
				divider:SetHeight(dividerheight)
				divider.Color = Palette["divider"]
				divider.Paint = Material_PanelDraw_Basic
				table.insert(sidebar.Items, divider)
			--end
		end

		rootpanel.Sidebar = sidebar

		local shadowpanel = vgui.Create( "DButton", rootpanel )
		shadowpanel:SetPos(0,idealbarheight)
		shadowpanel:SetSize(rootw,rooth-idealbarheight)
		shadowpanel:SetZPos( 0 )
		shadowpanel:SetText("")
		shadowpanel.MainColor = Palette["shadow"]
		shadowpanel.Opacity = 0
		shadowpanel.Active = false
		shadowpanel.Think = function(self)
			self:SetSize( rootpanel:GetWide(), rootpanel:GetTall()-idealbarheight )
			local activenum = self.Active and 1 or 0
			self.Opacity = math.Approach( self.Opacity, activenum, RealFrameTime()*( activenum - self.Opacity )*5 )
			if self.Opacity<0.05 and !self.Active then
				self:SetVisible(false)
			end
		end
		shadowpanel.Paint = function(self,w,h)
			draw.NoTexture()
			draw.RoundedBox(0,0,0,w,h,ColorAlpha(self.MainColor,self.MainColor.a * self.Opacity))
		end
		shadowpanel.DoClick = function(self)
			if IsValid(rootpanel.Sidebar) then
				rootpanel.Sidebar.Active = false
			end
			self.Active = false
		end
		shadowpanel.OnCursorEntered = function(self)
			self:SetCursor("arrow")
		end
		sidebar.shadowpanel = shadowpanel

		--[[ Menu Bar ]]--

		local menubar = vgui.Create( "DPanel", rootpanel )
		menubar:Dock(TOP)
		menubar:SetHeight(idealbarheight)
		menubar:SetZPos( -10 )
		menubar.Color = GetPrimaryColorOption()
		menubar.Elevation = 3
		menubar.Paint = Material_PanelDraw_Basic

		local mainmenubutton = vgui.Create( "DButton", menubar )
		mainmenubutton:Dock(LEFT)
		mainmenubutton:SetWidth( idealbarheight )
		mainmenubutton:SetText("")
		mainmenubutton:SetZPos( -9 )
		mainmenubutton.Elevation = 3
		mainmenubutton.Color = Palette["text_accent_primary"]
		mainmenubutton.Paint = function(self,w,h)
			self.Scale = 2/3
			self.Image = (rootpanel.activepanel == rootpanel.selectorpanel) and Material_Icons["menu"] or Material_Icons["back"]
			self.ImageColor = self.Color
			self.Rotation = 0
			Material_DImage_Icon(self,w,h)
		end
		mainmenubutton.DoClick = function( self )
			if rootpanel.activepanel == rootpanel.selectorpanel then
				sidebar:SetActive()
			else
				rootpanel:SetFocusedPanel(rootpanel.selectorpanel)
			end
		end

		local maintitletext = "TFA-VOX Configurator"
		local maintitle = vgui.Create( "DLabel", menubar )
		maintitle:Dock(LEFT)
		maintitle:SetFont("TFAVOX_Material_Large")
		maintitle:SetText(maintitletext)
		maintitle:SetTextColor(Palette["text_accent_primary"])
		maintitle:SizeToContents()
		function maintitle:Think()
			local txt = self:GetText()
			local targettxt = (rootpanel.activepanel == rootpanel.configpanel) and rootpanel.configpanel.Name or maintitletext
			if txt!=targettxt then
				self:SetText(targettxt)
				self:SizeToContentsX()
			end
		end

		--[[ Selection Panel ]]--

		local selectorpanel = vgui.Create( "DScrollPanel", rootpanel)
		selectorpanel:SetPos(0,idealbarheight)
		selectorpanel:SetSize(rootw,rooth-idealbarheight)
		selectorpanel:SetZPos( -10 )
		selectorpanel.Color = Palette["background"]
		selectorpanel.Paint = Material_PanelDraw_Basic
		selectorpanel:SetVisible(true)
		local vbar = selectorpanel:GetVBar()
		Material_ProcessVBar( vbar )

		selectorpanel.SlideRight = false
		selectorpanel.Think = Material_SlidingContentPanel
		selectorpanel.rows = {}
		function selectorpanel:FocusRow(row,focus)
			for k,v in pairs(self.rows) do if IsValid(v) then v.Active = false end end
			row.Active = focus
			if focus==nil then row.Active = true end
			row:Think()
		end
		rootpanel.selectorpanel = selectorpanel
		rootpanel.activepanel = selectorpanel

		--[[
		for i=1,20 do
			local row = vgui.Create( "DButton", selectorpanel)
			row:Dock(TOP)
			row:SetHeight(idealbarheight)
			row:SetText("Row "..i)
			row:SetFont("TFAVOX_Material_Large")
			row:SetTextColor(Palette["text_primary"])
			row.Color = Palette["background"]
			row.Paint = Material_PanelDraw_Basic
		end
		]]--

		local keys = table.GetKeys( TFAVOX_Modules )

		table.sort(keys,function(a,b)
			return (TFAVOX_Modules[a].name or TFAVOX_Modules[a].class or a )<(TFAVOX_Modules[b].name or TFAVOX_Modules[b].class or b)
		end)

		for i,k in ipairs(keys) do
			v = TFAVOX_Modules[k]
			local row = vgui.Create( "DPanel", selectorpanel)
			row:SetZPos( -9 )
			row:Dock(TOP)
			row:SetHeight(idealbarheight)
			row.Color = Palette["background"]
			row.Paint = Material_PanelDraw_Basic
			row:DockPadding(idealbarheight,0,idealbarheight,0)
			row.ModClass = v.class
			row.Active = false
			row.ActiveHeight = idealbarheight * 4
			--[[
			row.OnMousePressed = function( self )
				selectorpanel:FocusRow(self,!self.Active)
			end
			]]--
			row.Think = Material_ExpandableRow
			--row:SetTooltip( v.description )
			table.insert(selectorpanel.rows,row)

			local rowtitle = vgui.Create( "DLabel", row )
			rowtitle:SetZPos( -8 )
			rowtitle:Dock(LEFT)
			rowtitle:SetFont("TFAVOX_Material_Large")
			rowtitle:SetText( v.name or v.class or "" )
			rowtitle:SetTextColor(Palette["text_primary"])
			rowtitle:SizeToContents()

			local rowdescription = vgui.Create( "DLabel", row )
			rowdescription:SetZPos( -8 )
			--rowdescription:DockMargin( idealbarheight/4, 0, idealbarheight/4, 0)
			--rowdescription:Dock(LEFT)
			local rtx,rty = rowtitle:GetPos()
			rowdescription:SetFont("TFAVOX_Material_Small")
			rowdescription:SetText( v.description or "" )
			rowdescription:SetTextColor(Palette["text_primary"])
			rowdescription:SizeToContents()
			rowdescription:SetPos(rtx + rowtitle:GetWide() + idealbarheight + idealbarheight / 4, rty + rowtitle:GetTall() )
			--rowtitle:SetTooltip( v.description )

			if i<#keys then
				local divider = vgui.Create( "DPanel", selectorpanel )
				divider:SetZPos( -9 )
				divider:Dock(TOP)
				divider:SetHeight(dividerheight)
				divider.Color = Palette["divider"]
				divider.Paint = Material_PanelDraw_Basic
			end

			local editbutton = vgui.Create( "DButton", row )
			editbutton:Dock(RIGHT)
			editbutton:SetZPos( -5 )
			editbutton:SetWidth( idealbarheight )
			editbutton:SetText("")
			editbutton:SetFont("TFAVOX_Material_Large")
			editbutton:SetTextColor(Palette["text_primary"])
			editbutton.Color = GetSecondaryColorOption()
			editbutton.Elevation = 0
			editbutton.Paint = Material_PanelDraw_Circle
			editbutton.Think = Material_SpinIcon
			editbutton.DoClick = function(self)
				rootpanel:SetFocusedPanel( rootpanel.configpanel )
				rootpanel.configpanel:Populate( row.ModClass )
			end
			--editbutton:SetTooltip( "Edit this mod's configuration" )

			local editbuttonicon = vgui.Create("DImage",editbutton)
			editbuttonicon:SetZPos( -4 )
			editbuttonicon:Dock(FILL)
			editbuttonicon:SetImage(Material_Icons["edit"])
			editbuttonicon.Scale = 0.5
			editbuttonicon.Rotation = 0
			editbuttonicon.Paint = Material_DImage_Icon
			editbutton.icon = editbuttonicon
			--editbuttonicon:SetTooltip( "Edit this mod's configuration" )

			local togglebutton = vgui.Create( "DButton", row )
			togglebutton:Dock(RIGHT)
			togglebutton:SetZPos( -5 )
			togglebutton:SetWidth( idealbarheight )
			togglebutton:SetText("")
			togglebutton:SetFont("TFAVOX_Material_Large")
			togglebutton:SetTextColor(Palette["text_primary"])
			togglebutton.Color = GetSecondaryColorOption()
			togglebutton.Elevation = 0
			togglebutton.ImageColor = Palette["text_accent_primary"]
			togglebutton.classwatch = v.class or k
			togglebutton.Think = function(self,w,h)
				local actv = TFAVOX_Modules[self.classwatch].active
				self.Scale = ( actv ) and 2/3 or 1/2
				self.Image = ( actv ) and Material_Icons["check"] or Material_Icons["x"]
				self.RotationStatic = self.RotationStatic or 0
				if actv then
					self.RotationStatic = math.Approach(self.RotationStatic,0,(0-self.RotationStatic)*RealFrameTime()*transitionfactor*2)
				else
					self.RotationStatic = math.Approach(self.RotationStatic,90,(90-self.RotationStatic)*RealFrameTime()*transitionfactor)
				end
				self.RotationHover = self.RotationHover or 0
				local targval = self:IsHovered() and 15 or 0
				self.RotationHover = math.Approach(self.RotationHover,targval,(targval-self.RotationHover)*RealFrameTime()*transitionfactor)
				self.Rotation = self.RotationStatic + self.RotationHover
			end
			togglebutton.Paint = function(self,w,h)
				Material_PanelDraw_Circle(self,w,h)
				Material_DImage_Icon(self,w,h)
			end
			togglebutton.DoClick = function(self)
				--print("requesting " .. self.classwatch .. " as " .. (  (!TFAVOX_Modules[self.classwatch].active) and "true" or "false" ) )
				TFAVOX_Modules_SetStatus( self.classwatch, !TFAVOX_Modules[self.classwatch].active , true )
			end


		end

		--[[ Configuration Panel ]]--

		local configpanel = vgui.Create( "DScrollPanel", rootpanel)
		configpanel.Name = ""
		configpanel:SetPos(0,idealbarheight)
		configpanel:SetSize(rootw,rooth-idealbarheight)
		configpanel:SetZPos( -10 )
		configpanel.Color = Palette["background"]
		configpanel.Paint = Material_PanelDraw_Basic
		configpanel:SetVisible(false)
		configpanel.rows = {}
		configpanel.Think = Material_SlidingContentPanel
		function configpanel:Rebuild()
			local vbar = configpanel:GetVBar()
			Material_ProcessVBar( vbar )

			self:GetCanvas():SizeToChildren( false, true )

			-- Although this behaviour isn't exactly implied, center vertically too
			if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then

				self:GetCanvas():SetPos( 0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5 )

			end

			for k,v in pairs(self.rows) do
				if IsValid(v) then
					if IsValid(v.header) then v.header:SetSize(self:GetCanvas():GetWide(),v.header:GetTall()) end
					if IsValid(v.content) then v.content:SetSize(self:GetCanvas():GetWide(),v.content:GetTall()) end
				end
			end

		end
		function configpanel:FocusRow(row,focus)
			for k,v in pairs(self.rows) do if IsValid(v) then v.Active = false end end
			row.Active = focus
			if focus==nil then row.Active = true end
			row:Think()
		end

		function configpanel:Populate( modulename )
			self:Clear()
			configpanel.rows = {}
			self.Name = ""
			local mod = TFAVOX_Modules[ modulename ]
			if mod then
				self.Name = mod.name or mod.class
				local opts = mod.options
				if opts then
					local keys = table.GetKeys( opts )

					table.sort(keys,function(a,b)
						return (opts[a].name or opts[a].class)<(opts[b].name or opts[b].class)
					end)

					for i,k in ipairs(keys) do
						v = opts[k]

						local configpiece

						local row = vgui.Create( "DPanel", configpanel)
						row:SetZPos( -9 )
						row:Dock(TOP)
						row.Height = idealbarheight
						row:SetHeight(row.Height)
						row.Color = Palette["background"]
						row.Paint = Material_PanelDraw_Basic
						row:DockPadding(idealbarheight,0,idealbarheight,0)
						row.Active = false
						row.OnMousePressed = function( self )
							configpanel:FocusRow(self,!self.Active)
						end
						row.Think = Material_ExpandableRow
						--row:SetTooltip( v.description )

						table.insert(configpanel.rows,row)

						local rowheader = vgui.Create( "DPanel", row)
						rowheader:SetPos(0,0)
						rowheader:SetSize(configpanel:GetWide(),row.Height)
						rowheader:DockPadding(idealbarheight,0,idealbarheight,0)
						rowheader.OnMousePressed = function( self )
							configpanel:FocusRow(row,!row.Active)
						end
						rowheader.Paint = function(self,w,h) end
						--rowheader:SetTooltip( v.description )

						row.header = rowheader

						local rowtitle = vgui.Create( "DLabel", rowheader )
						rowtitle:SetZPos( -8 )
						rowtitle:Dock(LEFT)
						rowtitle:SetFont("TFAVOX_Material_Large")
						rowtitle:SetText( v.name or v.class )
						rowtitle:SetTextColor(Palette["text_primary"])
						rowtitle:SizeToContents()

						local rowdescription = vgui.Create( "DLabel", row )
						rowdescription:SetZPos( -8 )
						--rowdescription:DockMargin( idealbarheight/4, 0, idealbarheight/4, 0)
						--rowdescription:Dock(LEFT)
						local rtx,rty = rowtitle:GetPos()
						rowdescription:SetFont("TFAVOX_Material_Small")
						rowdescription:SetText( v.description or "" )
						rowdescription:SetTextColor(Palette["text_primary"])
						rowdescription:SizeToContents()
						rowdescription:SetPos(rtx + rowtitle:GetWide() + idealbarheight + idealbarheight / 4, rty + rowtitle:GetTall() )
						--rowtitle:SetTooltip( v.description )

						--if i<#keys then
							local divider = vgui.Create( "DPanel", configpanel )
							divider:SetZPos( -9 )
							divider:Dock(TOP)
							divider:SetHeight(dividerheight)
							divider.Color = Palette["divider"]
							divider.Paint = Material_PanelDraw_Basic
						--end

						local resetbutton = vgui.Create( "DButton", rowheader )
						resetbutton:Dock(RIGHT)
						resetbutton:SetZPos( -5 )
						resetbutton:SetWidth( idealbarheight )
						resetbutton:SetText("")
						resetbutton:SetFont("TFAVOX_Material_Large")
						resetbutton:SetTextColor(Palette["text_primary"])
						resetbutton.Color = GetSecondaryColorOption()
						resetbutton.Elevation = 0
						resetbutton.Paint = Material_PanelDraw_Circle
						resetbutton.Think = Material_SpinIcon
						resetbutton.opt = v
						resetbutton.OnMousePressed = function( self )
							TFAVOX_Modules_SetModuleOption( mod, k, resetbutton.opt.default or resetbutton.opt.value , true )
							TFAVOX_Modules_SetModuleOption( mod, k, resetbutton.opt.default or resetbutton.opt.value )
							if configpiece then
								configpiece:ReadValue()
							end
						end

						local resetbuttonicon = vgui.Create("DImage",resetbutton)
						resetbuttonicon:SetZPos( -4 )
						resetbuttonicon:Dock(FILL)
						resetbuttonicon:SetImage(Material_Icons["reset"])
						resetbuttonicon.Scale = 0.5
						resetbuttonicon.Rotation = 0
						resetbuttonicon.Paint = Material_DImage_Icon
						resetbutton.icon = resetbuttonicon

						local editbutton = vgui.Create( "DButton", rowheader )
						editbutton:Dock(RIGHT)
						editbutton:SetZPos( -5 )
						editbutton:SetWidth( idealbarheight )
						editbutton:SetText("")
						editbutton:SetFont("TFAVOX_Material_Large")
						editbutton:SetTextColor(Palette["text_primary"])
						editbutton.Color = GetSecondaryColorOption()
						editbutton.Elevation = 0
						editbutton.Paint = Material_PanelDraw_Circle
						editbutton.Think = Material_SpinIcon
						editbutton.OnMousePressed = function( self )
							configpanel:FocusRow(row,!row.Active)
						end

						local editbuttonicon = vgui.Create("DImage",editbutton)
						editbuttonicon:SetZPos( -4 )
						editbuttonicon:Dock(FILL)
						editbuttonicon:SetImage(Material_Icons["details"])
						editbuttonicon.Scale = 0.5
						editbuttonicon.Rotation = 0
						editbuttonicon.Paint = Material_DImage_Icon
						editbutton.icon = editbuttonicon


						local rowcontent = vgui.Create( "DPanel", row)
						rowcontent:SetPos(0,rowheader:GetTall() )
						rowcontent:SetSize(configpanel:GetWide(),1080)
						rowcontent:DockPadding(idealbarheight,0,idealbarheight,0)
						rowcontent.OnMousePressed = function( self )
							configpanel:FocusRow(row,!row.Active)
						end
						rowcontent.Color = Palette["divider"]
						rowcontent.Paint = function(self,w,h)
							draw.NoTexture()
							draw.RoundedBox(0,0,1,w,dividerheight,self.Color)
						end
						--rowcontent:SetTooltip( v.description )

						row.content = rowcontent

						--[[Fill Configurable Options]]--

						local contenth = 0

						if v.type == "int" or v.type == "integer" or v.type == "double" or v.type == "float" then
							configpiece = vgui.Create("DNumSlider",rowcontent)
							configpiece:Dock(TOP)
							if v.type=="int" or v.type=="integer" then
								configpiece:SetText("Whole Number: ")
								configpiece:SetDecimals(0)
							else
								configpiece:SetText("Decimal Number: ")
								configpiece:SetDecimals(2)
							end
							configpiece:SetMin(v.min)
							configpiece:SetMax(v.max)
							configpiece:SetValue( v.value or v.default )
							configpiece:SizeToContents()
							configpiece.Label:SetFont("TFAVOX_Material_Default")
							configpiece.Label:SetTextColor(Palette["text_primary"])

							configpiece:GetTextArea():SetFont("TFAVOX_Material_Small")
							configpiece:GetTextArea():SetTextColor(Palette["text_primary"])
							configpiece:GetTextArea().Color = GetPrimaryColorOption()
							configpiece:GetTextArea().PaintOver = Material_DrawTextEntry
							configpiece:GetTextArea():SetDrawBackground(false)
							configpiece:GetTextArea():SetDrawBorder(false)

							configpiece.OnValueChanged = function(self)
								TFAVOX_Modules_SetModuleOption( mod, k, self:GetValue() , true )
							end

							configpiece.ReadValue = function(self)
								configpiece:SetValue( self.opt.value or self.opt.default )
							end
						end

						if v.type == "string"  then
							configpiece = vgui.Create("DPanel",rowcontent)
							configpiece:Dock(TOP)
							configpiece.Label = vgui.Create("DLabel",configpiece)
							configpiece.Label:Dock(LEFT)
							configpiece.Label:SetText("Text String: ")
							configpiece.Label:SetFont("TFAVOX_Material_Default")
							configpiece.Label:SetTextColor(Palette["text_primary"])
							configpiece.Label:SizeToContents()
							configpiece:SizeToContents()

							configpiece.Entry = vgui.Create("DTextEntry",configpiece)
							configpiece.Entry:Dock(FILL)
							configpiece.Entry:SizeToContents()
							configpiece.Entry:SetHeight(configpiece:GetTall())
							configpiece.Entry:SetValue( v.value or v.default )
							configpiece.Entry:SetFont("TFAVOX_Material_Small")
							configpiece.Entry:SetTextColor(Palette["text_primary"])
							configpiece.Entry.m_Background = false
							configpiece.Entry.Color = GetPrimaryColorOption()
							configpiece.Entry.PaintOver = Material_DrawTextEntry
							configpiece.Entry:SetDrawBackground(false)
							configpiece.Entry:SetDrawBorder(false)
							configpiece.Entry.m_bUpdateOnType = true
							if configpiece.Entry.UpdateOnType then configpiece.Entry:UpdateOnType(true) end
							configpiece.Entry.Think = function(self)
								local ntext = self:GetValue()
								self.OldText = self.OldText or ntext
								if self.OldText != ntext then
									TFAVOX_Modules_SetModuleOption( mod, k, ntext or "" , true )
								end
								self.OldText = ntext
							end

							configpiece.OnMousePressed = function( self )
								configpanel:FocusRow(row,!row.Active)
							end
							configpiece.Paint = function(self,w,h) end

							configpiece.ReadValue = function(self)
								configpiece.Entry:SetValue( self.opt.value or self.opt.default )
							end
						end

						if v.type == "color"  then
							configpiece = vgui.Create("DPanel",rowcontent)
							configpiece:SetHeight( idealbarheight * 6 )
							configpiece:Dock(TOP)
							configpiece.Label = vgui.Create("DLabel",configpiece)
							configpiece.Label:Dock(LEFT)
							configpiece.Label:SetText("Color: ")
							configpiece.Label:SetFont("TFAVOX_Material_Default")
							configpiece.Label:SetTextColor(Palette["text_primary"])
							configpiece.Label:SizeToContents()

							configpiece.Mixer = vgui.Create("DColorMixer",configpiece)
							configpiece.Mixer:Dock(FILL)
							configpiece.Mixer:SetColor( v.value or v.default )
							configpiece.Mixer:SetPalette( true )
							configpiece.Mixer:SetAlphaBar( true )
							configpiece.Mixer:SetWangs( true )

							configpiece.Mixer.txtR:SetFont("TFAVOX_Material_Tiny")
							configpiece.Mixer.txtR:SetTextColor(Palette["text_primary"])
							configpiece.Mixer.txtR.Color = GetPrimaryColorOption()
							configpiece.Mixer.txtR.PaintOver = Material_DrawTextEntry
							configpiece.Mixer.txtR:SetDrawBackground(false)
							configpiece.Mixer.txtR:SetDrawBorder(false)
							configpiece.Mixer.txtG:SetFont("TFAVOX_Material_Tiny")
							configpiece.Mixer.txtG:SetTextColor(Palette["text_primary"])
							configpiece.Mixer.txtG.Color = GetPrimaryColorOption()
							configpiece.Mixer.txtG.PaintOver = Material_DrawTextEntry
							configpiece.Mixer.txtG:SetDrawBackground(false)
							configpiece.Mixer.txtG:SetDrawBorder(false)
							configpiece.Mixer.txtB:SetFont("TFAVOX_Material_Tiny")
							configpiece.Mixer.txtB:SetTextColor(Palette["text_primary"])
							configpiece.Mixer.txtB.Color = GetPrimaryColorOption()
							configpiece.Mixer.txtB.PaintOver = Material_DrawTextEntry
							configpiece.Mixer.txtB:SetDrawBackground(false)
							configpiece.Mixer.txtB:SetDrawBorder(false)
							configpiece.Mixer.txtA:SetFont("TFAVOX_Material_Tiny")
							configpiece.Mixer.txtA:SetTextColor(Palette["text_primary"])
							configpiece.Mixer.txtA.Color = GetPrimaryColorOption()
							configpiece.Mixer.txtA.PaintOver = Material_DrawTextEntry
							configpiece.Mixer.txtA:SetDrawBackground(false)
							configpiece.Mixer.txtA:SetDrawBorder(false)

							function configpiece.Mixer:Think()
								local newcol = self:GetColor()
								self.oldcol = self.oldcol or newcol
								if self.oldcol != newcol then
									TFAVOX_Modules_SetModuleOption( mod, k, Color(newcol.r or 255,newcol.g or 255,newcol.b or 255,newcol.a or 255) , true )
								end
								self.oldcol = newcol
							end

							configpiece:SizeToContents()
							configpiece.Paint = function(self,w,h) end

							configpiece.ReadValue = function(self)
								configpiece.Mixer:SetColor( self.opt.value or self.opt.default )
							end
						end

						if v.type == "vector"  then
							configpiece = vgui.Create("DPanel",rowcontent)
							configpiece:Dock(TOP)
							configpiece.Label = vgui.Create("DLabel",configpiece)
							configpiece.Label:Dock(LEFT)
							configpiece.Label:SetText("Vector: ")
							configpiece.Label:SetFont("TFAVOX_Material_Default")
							configpiece.Label:SetTextColor(Palette["text_primary"])
							configpiece.Label:SizeToContents()
							configpiece:SizeToContents()

							function configpiece:Update()
								timer.Simple(0,function()
									local vec = Vector()
									if IsValid(self.Entry_X) then
										local val = self.Entry_X:GetValue()
										if val then
											local num = tonumber(val)
											if num then vec.x = num end
										end
									end
									if IsValid(self.Entry_Y) then
										local val = self.Entry_Y:GetValue()
										if val then
											local num = tonumber(val)
											if num then vec.y = num end
										end
									end
									if IsValid(self.Entry_Z) then
										local val = self.Entry_Z:GetValue()
										if val then
											local num = tonumber(val)
											if num then vec.z = num end
										end
									end

									TFAVOX_Modules_SetModuleOption( mod, k, vec , true )
								end)
							end

							configpiece.Entry_X = vgui.Create("DTextEntry",configpiece)
							configpiece.Entry_X:DockMargin(idealbarheight/8,0,idealbarheight/8,0)
							configpiece.Entry_X:Dock(LEFT)
							configpiece.Entry_X:SetWidth(idealbarheight)
							configpiece.Entry_X:SetHeight(configpiece:GetTall())
							configpiece.Entry_X:SetValue( ( v.value or v.default ).x )
							configpiece.Entry_X:SetFont("TFAVOX_Material_Small")
							configpiece.Entry_X:SetTextColor(Palette["text_primary"])
							configpiece.Entry_X.m_Background = false
							configpiece.Entry_X.Color = GetPrimaryColorOption()
							configpiece.m_bNumeric = true
							configpiece.Entry_X.PaintOver = Material_DrawTextEntry
							configpiece.Entry_X:SetDrawBackground(false)
							configpiece.Entry_X:SetDrawBorder(false)
							configpiece.Entry_X.m_bUpdateOnType = true
							if configpiece.Entry_X.UpdateOnType then configpiece.Entry_X:UpdateOnType(true) end

							configpiece.Entry_X.Think = function(self)
								local ntext = self:GetValue()
								self.OldText = self.OldText or ntext
								if self.OldText != ntext then
									configpiece:Update()
								end
								self.OldText = ntext
							end

							configpiece.Entry_Y = vgui.Create("DTextEntry",configpiece)
							configpiece.Entry_Y:DockMargin(idealbarheight/8,0,idealbarheight/8,0)
							configpiece.Entry_Y:Dock(LEFT)
							configpiece.Entry_Y:SetWidth(idealbarheight)
							configpiece.Entry_Y:SetHeight(configpiece:GetTall())
							configpiece.Entry_Y:SetValue( ( v.value or v.default ).y )
							configpiece.Entry_Y:SetFont("TFAVOX_Material_Small")
							configpiece.Entry_Y:SetTextColor(Palette["text_primary"])
							configpiece.Entry_Y.m_Background = false
							configpiece.Entry_Y.Color = GetPrimaryColorOption()
							configpiece.m_bNumeric = true
							configpiece.Entry_Y.PaintOver = Material_DrawTextEntry
							configpiece.Entry_Y:SetDrawBackground(false)
							configpiece.Entry_Y:SetDrawBorder(false)
							configpiece.Entry_Y.m_bUpdateOnType = true
							if configpiece.Entry_Y.UpdateOnType then configpiece.Entry_Y:UpdateOnType(true) end

							configpiece.Entry_Y.Think = function(self)
								local ntext = self:GetValue()
								self.OldText = self.OldText or ntext
								if self.OldText != ntext then
									configpiece:Update()
								end
								self.OldText = ntext
							end

							configpiece.Entry_Z = vgui.Create("DTextEntry",configpiece)
							configpiece.Entry_Z:DockMargin(idealbarheight/8,0,idealbarheight/8,0)
							configpiece.Entry_Z:Dock(LEFT)
							configpiece.Entry_Z:SetWidth(idealbarheight)
							configpiece.Entry_Z:SetHeight(configpiece:GetTall())
							configpiece.Entry_Z:SetValue( ( v.value or v.default ).z )
							configpiece.Entry_Z:SetFont("TFAVOX_Material_Small")
							configpiece.Entry_Z:SetTextColor(Palette["text_primary"])
							configpiece.Entry_Z.m_Background = false
							configpiece.Entry_Z.Color = GetPrimaryColorOption()
							configpiece.m_bNumeric = true
							configpiece.Entry_Z.PaintOver = Material_DrawTextEntry
							configpiece.Entry_Z:SetDrawBackground(false)
							configpiece.Entry_Z:SetDrawBorder(false)
							configpiece.Entry_Z.m_bUpdateOnType = true
							if configpiece.Entry_Z.UpdateOnType then configpiece.Entry_Z:UpdateOnType(true) end

							configpiece.Entry_Z.Think = function(self)
								local ntext = self:GetValue()
								self.OldText = self.OldText or ntext
								if self.OldText != ntext then
									configpiece:Update()
								end
								self.OldText = ntext
							end

							configpiece.OnMousePressed = function( self )
								configpanel:FocusRow(row,!row.Active)
							end
							configpiece.Paint = function(self,w,h) end

							configpiece.ReadValue = function(self)
								configpiece.Entry_X:SetValue( self.opt.value.x or self.opt.default.x or 0 )
								configpiece.Entry_Y:SetValue( self.opt.value.y or self.opt.default.y or 0 )
								configpiece.Entry_Z:SetValue( self.opt.value.z or self.opt.default.z or 0 )
							end
						end

						if v.type == "bool" or v.type=="boolean"  then

							configpiece = vgui.Create("DPanel",rowcontent)
							configpiece:Dock(TOP)
							configpiece.Label = vgui.Create("DLabel",configpiece)
							configpiece.Label:Dock(LEFT)
							configpiece.Label:SetText("True/False: ")
							configpiece.Label:SetFont("TFAVOX_Material_Default")
							configpiece.Label:SetTextColor(Palette["text_primary"])
							configpiece.Label:SizeToContents()
							configpiece:SizeToContents()

							configpiece.Check = vgui.Create("DCheckBox",configpiece)
							configpiece.Check:Dock(LEFT)
							configpiece.Check:SetWidth( configpiece:GetTall() )

							if v.value==nil then
								configpiece.Check:SetValue( v.default )
								configpiece.Check.checky = v.default
							else
								configpiece.Check:SetValue( v.value )
								configpiece.Check.checky = v.value
							end

							configpiece.Check.OnChange = function(self, checked)
								self.checky = checked
								TFAVOX_Modules_SetModuleOption( mod, k, checked , true )
							end
							configpiece.Check.Paint = function(self,w,h)
								draw.NoTexture()
								draw.RoundedBox(0,0,0,w,h,GetSecondaryColorOption())
								draw.RoundedBox(0,dividerheight,dividerheight,w-dividerheight*2,h-dividerheight*2,self.checky and GetPrimaryColorOption() or Palette["background"])
							end


							configpiece.OnMousePressed = function( self )
								configpanel:FocusRow(row,!row.Active)
							end
							configpiece.Paint = function(self,w,h) end

							configpiece.ReadValue = function(self)
								configpiece.Check:SetValue( self.opt.value or self.opt.default )
							end
						end

						if configpiece then

							configpiece.opt = v

							local paddingv = idealbarheight/8
							configpiece:DockMargin(0,paddingv,0,paddingv)
							contenth = contenth + configpiece:GetTall()+paddingv*2
						end

						--[[Finalize Row]]--

						rowcontent:SetTall(contenth)

						row.ActiveHeight = rowheader:GetTall() + rowcontent:GetTall()

					end
				end
			end
		end

		rootpanel.configpanel = configpanel


	end)

end
