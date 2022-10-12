
local myclass = MODULE and MODULE.class or "callouts"
local padding = 10
local basecol = Color(64,64,64,124)
local circlebordercol = Color(255,255,255,64)
local linebordercol = Color(255,255,255,64)
local textcol = Color(255,255,255,192)
local textspacing = 0.6
local function CreateWheelFont()
	surface.CreateFont( "Gesture_Radial", {
		font = "Roboto",
		size = 12 * (ScrH() / 480),
		weight = 750,
		extended = true
	} )
end
CreateWheelFont()
hook.Add("OnScreenSizeChanged", "Gesture_Radial_CWF", CreateWheelFont)

local rectbl = {
    ['agree'] = { -- callout classname in these quotes
        ['name'] = "Agree",
        ['gesture'] = "g agree"
    },
    ['disagree'] = { -- callout classname in these quotes
        ['name'] = "Disagree",--Callout friendly name ( what you see in the wheel )
        ['gesture'] = "g disagree"
    },
    ['test'] = { -- callout classname in these quotes
        ['name'] = "Test",--Callout friendly name ( what you see in the wheel )
        ['gesture'] = "g test"
    },
    ['test2'] = { -- callout classname in these quotes
        ['name'] = "Test2",--Callout friendly name ( what you see in the wheel )
        ['gesture'] = "g test2"
    },  
}

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

    local gestures = rectbl 
    local gestureskeys = table.GetKeys(gestures)

    table.sort(gestureskeys,function(a,b)
        local val1 = gestures[a].name or tostring(a)
        local val2 = gestures[b].name or tostring(b)
        return val1<val2
    end)

    if open then
        local scrw,scrh = ScrW(),ScrH()
        local count = math.max( #gestureskeys, 3 )
        local arcdegrees = ( 360/count ) - padding
        local radius = scrh * 0.175
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

            local cl = gestureskeys[i]
            if cl then
                local text = gestures[cl].name or cl or ""
                surface.SetFont("Gesture_Radial")
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

                draw.SimpleText( text , "Gesture_Radial", scrw/2+math.cos( rad )*textradius, scrh/2-math.sin( rad )*textradius, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            d=d-arcdegrees-padding

            surface.SetDrawColor( linebordercol )
            surface.DrawLine(  scrw/2+math.cos( math.rad( d ) )*innerradius, scrh/2-math.sin( math.rad( d ) )*innerradius,  scrw/2+math.cos( math.rad( d ) )*radius, scrh/2-math.sin( math.rad( d ) )*radius )
        end

    end
end

hook.Add("HUDPaint","Gesture_Radial",DrawMenu)

local function OpenRadial()

    local ply = LocalPlayer()

    if !IsValid(ply) then return end
    if !ply:Alive() then return end

    open = true
    gui.EnableScreenClicker( true )
end

local function CloseRadial()

    local ply = LocalPlayer()

    if open and IsValid(ply) then

        local gestures = rectbl
        local gestureskeys = table.GetKeys(gestures)

        table.sort(gestureskeys,function(a,b)
            local val1 = gestures[a].name or tostring(a)
            local val2 = gestures[b].name or tostring(b)
            return val1<val2
        end)

        local scrw,scrh = ScrW(),ScrH()
        local radius = scrh * 0.175
        local innerradius = radius / 8
        local cursorx,cursory = input.GetCursorPos()

        local mouseangle = math.deg( math.atan2( cursorx-scrw/2, cursory-scrh/2 ) )
        local mousedist = math.sqrt( math.pow(cursorx-scrw/2,2) + math.pow(cursory-scrh/2,2) )

        local arcdegrees = (360/#gestureskeys)

        mouseangle = math.NormalizeAngle( 360 - ( mouseangle - 90 ) + arcdegrees )

        if mouseangle < 0 then mouseangle = mouseangle + 360 end

        if mousedist>innerradius then

            local i = math.floor( mouseangle / arcdegrees ) + 1
            local k = gestureskeys[i]
            if k then
                print(k)

                --net.Start("gesture_network")
                --net.WriteString(v.gesture)
                --net.SendToServer()
            end

        end

    end

    open = false
    gui.EnableScreenClicker( false )
end

concommand.Add("+gesture_radial_menu",function(ply,cmd,args)
        OpenRadial()
end)

concommand.Add("-gesture_radial_menu",function(ply,cmd,args)
    CloseRadial()
    if open then
        open = false
        gui.EnableScreenClicker( false )
    end
end)
