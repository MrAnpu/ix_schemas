if !MODULE then TFAVOX_Modules_Initialize() return end

MODULE.name = "Callouts"
MODULE.description = "Radial callout menu system"
MODULE.author = "TFA"
MODULE.realm = "shared"

if SERVER then
	util.AddNetworkString("tfavox_network_callouts")
	util.AddNetworkString("tfavox_network_callouts_reqdata")

	local function NetworkCallouts(ply)
		if IsValid(ply) then
			net.Start("tfavox_network_callouts")
			if ply.TFAVOX_Sounds and ply.TFAVOX_Sounds.callouts then
				net.WriteTable( ply.TFAVOX_Sounds.callouts )
			else
				net.WriteTable( {} )
			end
			net.Send(ply)
		end
	end

	hook.Add("TFAVOX_InitializePlayer","TFAVOX_Callouts",function(ply)

		if IsValid(ply) and SERVER then
			local mdtbl = TFAVOX_Models[ply:GetModel()]
			if mdtbl and mdtbl.callouts then

				ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

				ply.TFAVOX_Sounds['callouts'] = TFAVOX_FullCopy( mdtbl.callouts )
			end
		end

	end)

	hook.Add("TFAVOX_InitializePlayerDone","TFAVOX_Callouts_InitPlyPost",function(ply)

		NetworkCallouts(ply)

	end)

	net.Receive("tfavox_network_callouts_reqdata",function(len,ply)
		NetworkCallouts(ply)
	end)

	net.Receive("tfavox_network_callouts",function(len,ply)
		local snd = net.ReadString()
		if IsValid(ply) and TFAVOX_IsValid(ply) and ply:Alive() and ply.TFAVOX_Sounds and snd and string.len(snd)>0 then
			local sndtbl = ply.TFAVOX_Sounds.callouts
			if sndtbl then
				TFAVOX_PlayVoicePriority( ply, sndtbl[snd], 10, false )
			end
		end
	end)
end

if CLIENT then

	local myclass = MODULE and MODULE.class or "callouts"
	local padding = 10
	local basecol = Color(64,64,64,64)
	local circlebordercol = Color(255,255,255,64)
	local linebordercol = Color(255,255,255,64)
	local textcol = Color(255,255,255,192)
	local textspacing = 0.6

	local function CreateWheelFont()
		surface.CreateFont( "TFAVOX_Callout_Radial", {
			font = "Roboto",
			size = 12 * (ScrH() / 480),
			weight = 750,
			extended = true
		} )
	end
	CreateWheelFont()
	hook.Add("OnScreenSizeChanged", "TFAVOX_Callouts_Radial_CWF", CreateWheelFont)

	net.Receive("tfavox_network_callouts",function()
		local ply = LocalPlayer()
		if IsValid(ply) then
			ply.TFAVOX_Sounds = ply.TFAVOX_Sounds or {}

			local rectbl = net.ReadTable() or {}

			ply.ClientCallouts = TFAVOX_FullCopy( rectbl )
		end
	end)

	local open

	local function drawFilledCircle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 ) -- This is need for non absolute segment counts
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end

	local function DrawMenu()

		local ply = LocalPlayer()

		if !IsValid(ply) then return end
		if !ply:Alive() then return end
		if !ply.ClientCallouts then return end

		local calloutsounds = ply.ClientCallouts
		local calloutkeys = table.GetKeys(calloutsounds)

		table.sort(calloutkeys,function(a,b)
			local val1 = calloutsounds[a].name or tostring(a)
			local val2 = calloutsounds[b].name or tostring(b)
			return val1<val2
		end)

		if open then
			local scrw,scrh = ScrW(),ScrH()
			local count = math.max( #calloutkeys, 3 )
			local arcdegrees = ( 360/count ) - padding
			local radius = scrh * 0.375
			local innerradius = radius / 8
			local d = 360

			local cursorx,cursory = input.GetCursorPos()

			local mouseangle = math.deg( math.atan2( cursorx-scrw/2, cursory-scrh/2 ) )
			local mousedist = math.sqrt( math.pow(cursorx-scrw/2,2) + math.pow(cursory-scrh/2,2) )

			mouseangle = mouseangle - 90

			if mouseangle<-180 then mouseangle = mouseangle + 360 end
			if mouseangle>180 then mouseangle = mouseangle - 360 end

			input.SetCursorPos( math.cos( math.rad(mouseangle) ) * math.min( mousedist, radius ) + scrw/2, -math.sin( math.rad(mouseangle) ) *  math.min( mousedist, radius ) + scrh/2 )

			draw.NoTexture()
			surface.SetDrawColor( basecol )
			drawFilledCircle( scrw/2, scrh/2, radius, 64)
			surface.DrawCircle( scrw/2, scrh/2, innerradius, circlebordercol )
			surface.DrawCircle( scrw/2, scrh/2, radius, circlebordercol )

			local textareawidth = math.abs(  math.sin( math.rad( arcdegrees ) ) ) * radius * math.pow(textspacing,2) * 1.5
			local textradius = radius * textspacing

			for i=1,count do
				--Ideally:
				--Draw arc from d to d+arcdegrees
				--Draw text at d+arcdegrees/2

				local cl = calloutkeys[i]
				if cl then
					local text = calloutsounds[cl].name or cl or ""
					surface.SetFont("TFAVOX_Callout_Radial")
					local w,h = surface.GetTextSize(text)
					if w>textareawidth then
						text = string.sub(text,1,string.len(text)-3) .. "..."
						w,h = surface.GetTextSize(text)
						while w>textareawidth do
							text = string.sub(text,1,string.len(text)-4) .. "..."
							w,h = surface.GetTextSize(text)
						end
					end

					local rad = math.rad( d + arcdegrees*0.66 )

					draw.SimpleText( text , "TFAVOX_Callout_Radial", scrw/2+math.cos( rad )*textradius, scrh/2-math.sin( rad )*textradius, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
				d=d-arcdegrees-padding

				surface.SetDrawColor( linebordercol )
				surface.DrawLine(  scrw/2+math.cos( math.rad( d ) )*innerradius, scrh/2-math.sin( math.rad( d ) )*innerradius,  scrw/2+math.cos( math.rad( d ) )*radius, scrh/2-math.sin( math.rad( d ) )*radius )
			end

		end
	end

	hook.Add("HUDPaint","TFAVOX_Callouts_Radial",DrawMenu)

	function RequestData()

		local ply = LocalPlayer()

		if !IsValid(ply) then return end

		if !ply.TFAVOX_Radial_HR then
			ply.TFAVOX_Radial_HR = true
			net.Start("tfavox_network_callouts_reqdata")
			net.SendToServer()
		end

	end

	hook.Add("HUDPaint","TFAVOX_Callouts_Radial_RD",RequestData)

	local function OpenRadial()

		local ply = LocalPlayer()

		if !IsValid(ply) then return end
		if !ply:Alive() then return end

		open = true
		gui.EnableScreenClicker( true )
	end

	local function CloseRadial()

		local ply = LocalPlayer()

		if open and IsValid(ply) and ply.ClientCallouts then

			local calloutsounds = ply.ClientCallouts
			local calloutkeys = table.GetKeys(calloutsounds)

			table.sort(calloutkeys,function(a,b)
				local val1 = calloutsounds[a].name or tostring(a)
				local val2 = calloutsounds[b].name or tostring(b)
				return val1<val2
			end)

			local scrw,scrh = ScrW(),ScrH()
			local radius = scrh * 0.375
			local innerradius = radius / 8
			local cursorx,cursory = input.GetCursorPos()

			local mouseangle = math.deg( math.atan2( cursorx-scrw/2, cursory-scrh/2 ) )
			local mousedist = math.sqrt( math.pow(cursorx-scrw/2,2) + math.pow(cursory-scrh/2,2) )

			local arcdegrees = (360/#calloutkeys)

			mouseangle = math.NormalizeAngle( 360 - ( mouseangle - 90 ) + arcdegrees )

			if mouseangle < 0 then mouseangle = mouseangle + 360 end

			if mousedist>innerradius then

				local i = math.floor( mouseangle / arcdegrees ) + 1
				local k = calloutkeys[i]
				if k then

					net.Start("tfavox_network_callouts")
					net.WriteString(k)
					net.SendToServer()

				end

			end

		end

		open = false
		gui.EnableScreenClicker( false )
	end

	concommand.Add("+tfa_vox_callout_radial",function(ply,cmd,args)
		local selfv = TFAVOX_Modules[myclass]
		if !selfv or selfv.active then
			OpenRadial()
		end
	end)

	concommand.Add("-tfa_vox_callout_radial",function(ply,cmd,args)
		local selfv = TFAVOX_Modules[myclass]
		if !selfv or selfv.active then
			CloseRadial()
		else
			if open then
				open = false
				gui.EnableScreenClicker( false )
			end
		end
	end)

end
