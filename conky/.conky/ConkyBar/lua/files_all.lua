require 'cairo'

function conky_main()

    if conky_window == nil then return end

    local w=conky_window.width
    local h=conky_window.height
    local cs=cairo_xlib_surface_create(conky_window.display,
        conky_window.drawable, conky_window.visual, w, h)
    cr=cairo_create(cs)

    updates=tonumber(conky_parse('${updates}'))
    --start drawing after "updates_gap" updates
    --prevent segmentation error for cpu
    updates_gap=5
    flagOK=0
    if updates==1 then
        set_settings()

        flagOK=0
        for i in pairs(graph_settings) do
            if graph_settings[i].width==nil then graph_settings[i].width=100 end
            if graph_settings[i].nb_values==nil then
                graph_settings[i].nb_values= graph_settings[i].width
            end
            --create an empty table to store values
            graph_settings[i]["values"]={}
            --beginning point
            graph_settings[i].beg = graph_settings[i].nb_values
            --graph_settings[i].beg = 0
            for j =1, graph_settings[i].nb_values do
                graph_settings[i].values[j]=0
            end
            graph_settings[i].flag_init=true
            flagOK=flagOK + check_settings(graph_settings[i])

        end
    end

    if flagOK>0 then
        --abort script if error in one of the tables
        print ("ERROR : Check the graph_setting table")
        return
    end

    --drawing process
    if updates > updates_gap then

        go_gauge_rings(cr)

        for i in pairs(graph_settings) do
            if graph_settings[i].draw_me==true then graph_settings[i].draw_me = nil end
            if (graph_settings[i].draw_me==nil or conky_parse(tostring(graph_settings[i].draw_me)) == "1") then
                local nb_values=graph_settings[i].nb_values
                graph_settings[i].automax=0
                for j =1, nb_values do
                    if graph_settings[i].values[j+1]==nil then
                        graph_settings[i].values[j+1]=0
                    end

                    graph_settings[i].values[j]=graph_settings[i].values[j+1]
                    if j==nb_values then
                        --store value
                        if graph_settings[i].name=="" then
                            value=graph_settings[i].arg
                        else
                            value=tonumber(conky_parse('${' ..
                            graph_settings[i].name .. " " ..
                            graph_settings[i].arg ..'}'))
                        end
                        if not value then
                            value=0
                        end
                        graph_settings[i].values[nb_values]=value
                    end
                    graph_settings[i].automax=math.max(graph_settings[i].automax,
                    graph_settings[i].values[j])
                    --should stop weird glitches at beginning when no values reported yet for upspeed or diskio
                    if graph_settings[i].automax == 0 then graph_settings[i].automax = 1 end
                end
                draw_graph(graph_settings[i])
            end
        end
    end


    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    updates=nil
    updates_gap=nil

end

--==============================================================================
--                            seamod_rings.lua
--
--  Date    : 05/02/2012
--  Author  : SeaJey
--  Version : v0.1
--  License : Distributed under the terms of GNU GPL version 2 or later
--
--  This version is a modification of lunatico_rings.lua wich is modification of conky_orange.lua
--
--  conky_orange.lua:    http://gnome-look.org/content/show.php?content=137503&forumpage=0
--  lunatico_rings.lua:  http://gnome-look.org/content/show.php?content=142884
--==============================================================================

require 'cairo'


--------------------------------------------------------------------------------
--                                                                    gauge DATA
gauge = {
{
    name='fs_used_perc',            arg='',                  max_value=100,
    x=155,                          y=180,
    graph_radius=110,
    graph_thickness=5,
    graph_start_angle=-60,
    graph_unit_angle=1.2,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.1,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.3,
    hand_fg_colour=0x1793d0,       hand_fg_alpha=1.0,
    txt_radius=120,
    txt_weight=0,                  txt_size=9.0,
    txt_fg_colour=0x1793d0,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=0,        graduation_mark_thickness=1,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='',
    caption_weight=1,              caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.3,
},
}

-------------------------------------------------------------------------------
--                                                                 rgb_to_r_g_b
-- converts color in hexa to decimal
--
function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

-------------------------------------------------------------------------------
--                                                            angle_to_position
-- convert degree to rad and rotate (0 degree is top/north)
--
function angle_to_position(start_angle, current_angle)
    local pos = current_angle + start_angle
    return ( ( pos * (2 * math.pi / 360) ) - (math.pi / 2) )
end


-------------------------------------------------------------------------------
--                                                              draw_gauge_ring
-- displays gauges
--
function draw_gauge_ring(display, data, value)
    local max_value = data['max_value']
    local x, y = data['x'], data['y']
    local graph_radius = data['graph_radius']
    local graph_thickness, graph_unit_thickness = data['graph_thickness'], data['graph_unit_thickness']
    local graph_start_angle = data['graph_start_angle']
    local graph_unit_angle = data['graph_unit_angle']
    local graph_bg_colour, graph_bg_alpha = data['graph_bg_colour'], data['graph_bg_alpha']
    local graph_fg_colour, graph_fg_alpha = data['graph_fg_colour'], data['graph_fg_alpha']
    local hand_fg_colour, hand_fg_alpha = data['hand_fg_colour'], data['hand_fg_alpha']
    local graph_end_angle = (max_value * graph_unit_angle) % 360

    -- background ring
    cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, 0), angle_to_position(graph_start_angle, graph_end_angle))
    cairo_set_source_rgba(display, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
    cairo_set_line_width(display, graph_thickness)
    cairo_stroke(display)

    -- arc of value
    local val = value % (max_value + 1)
    local start_arc = 0
    local stop_arc = 0
    local i = 1
    while i <= val do
        start_arc = (graph_unit_angle * i) - graph_unit_thickness
        stop_arc = (graph_unit_angle * i)
        cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
        cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
        cairo_stroke(display)
        i = i + 1
    end
    local angle = start_arc

    -- hand
    start_arc = (graph_unit_angle * val) - (graph_unit_thickness * 2)
    stop_arc = (graph_unit_angle * val)
    cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
    cairo_set_source_rgba(display, rgb_to_r_g_b(hand_fg_colour, hand_fg_alpha))
    cairo_stroke(display)

    -- graduations marks
    local graduation_radius = data['graduation_radius']
    local graduation_thickness, graduation_mark_thickness = data['graduation_thickness'], data['graduation_mark_thickness']
    local graduation_unit_angle = data['graduation_unit_angle']
    local graduation_fg_colour, graduation_fg_alpha = data['graduation_fg_colour'], data['graduation_fg_alpha']
    if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
        local nb_graduation = graph_end_angle / graduation_unit_angle
        local i = 0
        while i < nb_graduation do
            cairo_set_line_width(display, graduation_thickness)
            start_arc = (graduation_unit_angle * i) - (graduation_mark_thickness / 2)
            stop_arc = (graduation_unit_angle * i) + (graduation_mark_thickness / 2)
            cairo_arc(display, x, y, graduation_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
            cairo_set_source_rgba(display,rgb_to_r_g_b(graduation_fg_colour,graduation_fg_alpha))
            cairo_stroke(display)
            cairo_set_line_width(display, graph_thickness)
            i = i + 1
        end
    end

    -- text
    local txt_radius = data['txt_radius']
    local txt_weight, txt_size = data['txt_weight'], data['txt_size']
    local txt_fg_colour, txt_fg_alpha = data['txt_fg_colour'], data['txt_fg_alpha']
    local movex = txt_radius * math.cos(angle_to_position(graph_start_angle, angle))
    local movey = txt_radius * math.sin(angle_to_position(graph_start_angle, angle))
    cairo_select_font_face (display, "ubuntu", CAIRO_FONT_SLANT_NORMAL, txt_weight)
    cairo_set_font_size (display, txt_size)
    cairo_set_source_rgba (display, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
    cairo_move_to (display, x + movex - (txt_size / 2), y + movey + 3)
    cairo_show_text (display, value)
    cairo_stroke (display)

    -- caption
    local caption = data['caption']
    local caption_weight, caption_size = data['caption_weight'], data['caption_size']
    local caption_fg_colour, caption_fg_alpha = data['caption_fg_colour'], data['caption_fg_alpha']
    local tox = graph_radius * (math.cos((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    local toy = graph_radius * (math.sin((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    cairo_select_font_face (display, "ubuntu", CAIRO_FONT_SLANT_NORMAL, caption_weight);
    cairo_set_font_size (display, caption_size)
    cairo_set_source_rgba (display, rgb_to_r_g_b(caption_fg_colour, caption_fg_alpha))
    cairo_move_to (display, x + tox + 5, y + toy + 1)
    -- bad hack but not enough time !
    if graph_start_angle < 105 then
        cairo_move_to (display, x + tox - 30, y + toy + 1)
    end
    cairo_show_text (display, caption)
    cairo_stroke (display)
end


-------------------------------------------------------------------------------
--                                                               go_gauge_rings
-- loads data and displays gauges
--
function go_gauge_rings(display)
    local function load_gauge_rings(display, data)
        local str, value = '', 0
        str = string.format('${%s %s}',data['name'], data['arg'])
        str = conky_parse(str)
        value = tonumber(str)
        draw_gauge_ring(display, data, value)
    end

    for i in pairs(gauge) do
        load_gauge_rings(display, gauge[i])
    end
end

-------------------------------------------------------------------------------
--                                                                         MAIN

function set_settings()
    graph_settings={

        {--HDD io graph
        name="exec",
        arg="~/.conky/ConkyBar/scripts/diskio.sh",
        max=100,
        autoscale=true,
        x=80,
        y=135,
        width=150,
        height=30,
        nb_values=70,
        background =false,
        fg_colour={ {0,0x666666,1}, {1,0x666666,1}},
        fg_orientation="ww"
    },

}
end


function check_settings(t)
    --tables are check only when conky start
	if t.name==nil and t.arg==nil then
		print ("No input values ... use parameters 'name'" ..
			" with 'arg' or only parameter 'arg' ")
		return 1
	end

	if t.max==nil then
		print ("No maximum value defined, use 'max'")
		print ("for name=" .. t.name .. " with arg=" .. t.arg)
		return 1
	end
	if t.name==nil then t.name="" end
	if t.arg==nil then t.arg="" end
	return 0
end



function draw_graph(t)
    --drawing function

    local function rgb_to_r_g_b(colour)
        return ((colour[2] / 0x10000) % 0x100) / 255., ((colour[2] / 0x100) % 0x100) / 255., (colour[2] % 0x100) / 255., colour[3]
    end

	local function linear_orientation(o,w,h)
	    --set gradient for bg and bg border
	    local p
		if o=="nn" then
			p={w/2,h,w/2,0}
		elseif o=="ne" then
			p={w,h,0,0}
		elseif o=="ww" then
			p={0,h/2,w,h/2}
		elseif o=="se" then
			p={w,0,0,h}
		elseif o=="ss" then
			p={w/2,0,w/2,h}
		elseif o=="ee" then
			p={w,h/2,0,h/2}
		elseif o=="sw" then
			p={0,0,w,h}
		elseif o=="nw" then
			p={0,h,w,0}
		end
		return p
	end

	local function linear_orientation_inv(o,w,h)
	    --set gradient for fg and fg border
	    local p
		if o=="ss" then
			p={w/2,h,w/2,0}
		elseif o=="sw" then
			p={w,h,0,0}
		elseif o=="ee" then
			p={0,h/2,w,h/2}
		elseif o=="nw" then
			p={w,0,0,h}
		elseif o=="nn" then
			p={w/2,0,w/2,h}
		elseif o=="ww" then
			p={w,h/2,0,h/2}
		elseif o=="ne" then
			p={0,0,w,h}
		elseif o=="se" then
			p={0,h,w,0}
		end
		return p
	end


	--set default values

    --cancel drawing if not needed
	if t.draw_me~=nil and conky_parse(tostring(t.draw_me)) ~= "1" then
		return
	end



	if t.height==nil	then t.height=20 end
	--checked in previous part : width and nb_values

	if t.background==nil    then t.background=true end
	if t.bg_bd_size==nil	then t.bg_bd_size=0 end
	if t.x==nil 		    then t.x=t.bg_bd_size end
	if t.y==nil 		    then t.y=conky_window.height -t.bg_bd_size end
	if t.bg_colour==nil 	then t.bg_colour={{0,0x000000,.5},{1,0xFFFFFF,.5}} end
	if t.bg_bd_colour==nil 	then t.bg_bd_colour={{1,0xFFFFFF,1}} end

	if t.foreground==nil    then t.foreground=true end
	if t.fg_colour==nil 	then t.fg_colour={{0,0x00FFFF,1},{1,0x0000FF,1}} end

	if t.fg_bd_size==nil	then t.fg_bd_size=0 end
	if t.fg_bd_colour==nil  then t.fg_bd_colour={{1,0xFFFF00,1}} end

	if t.autoscale==nil     then t.autoscale=false end
	if t.inverse==nil       then t.inverse=false end
	if t.angle==nil         then t.angle=0 end

	if t.bg_bd_orientation==nil then t.bg_bd_orientation="nn" end
	if t.bg_orientation==nil then t.bg_orientation="nn" end
	if t.fg_bd_orientation==nil then t.fg_bd_orientation="nn" end
	if t.fg_orientation==nil then t.fg_orientation="nn" end

    --check colours tables
	for i=1, #t.fg_colour do
        if #t.fg_colour[i]~=3 then
        	print ("error in fg_colour table")
        	t.fg_colour[i]={1,0x0000FF,1}
        end
    end

	for i=1, #t.fg_bd_colour do
        if #t.fg_bd_colour[i]~=3 then
        	print ("error in fg_bd_colour table")
        	t.fg_bd_colour[i]={1,0x00FF00,1}
        end
    end

	for i=1, #t.bg_colour do
        if #t.bg_colour[i]~=3 then
        	print ("error in background color table")
        	t.bg_colour[i]={1,0xFFFFFF,0.5}
        end
    end

	for i=1, #t.bg_bd_colour do
        if #t.bg_bd_colour[i]~=3 then
        	print ("error in background border color table")
        	t.bg_bd_colour[i]={1,0xFFFFFF,1}
        end
    end

    --calculate skew parameters if needed
    if t.flag_init then
	    if t.skew_x == nil then
		    t.skew_x=0
	    else
		    t.skew_x = math.pi*t.skew_x/180
	    end
	    if t.skew_y == nil then
		    t.skew_y=0
	    else
		    t.skew_y = math.pi*t.skew_y/180
	    end
	    t.flag_init=false
	end

    cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
    cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)

    local matrix0 = cairo_matrix_t:create()
    tolua.takeownership(matrix0)
    cairo_save(cr)
    cairo_matrix_init (matrix0, 1,t.skew_y,t.skew_x,1,0,0)
    cairo_transform(cr,matrix0)

   	local ratio=t.width/t.nb_values

	cairo_translate(cr,t.x,t.y)
	cairo_rotate(cr,t.angle*math.pi/180)
	cairo_scale(cr,1,-1)

	--background
	if t.background then
	    local pts=linear_orientation(t.bg_orientation,t.width,t.height)
		local pat = cairo_pattern_create_linear (pts[1],pts[2],pts[3],pts[4])
		for i=1, #t.bg_colour do
			--print ("i",i,t.colour[i][1], rgb_to_r_g_b(t.colour[i]))
		    cairo_pattern_add_color_stop_rgba (pat, t.bg_colour[i][1], rgb_to_r_g_b(t.bg_colour[i]))
		end
		cairo_set_source (cr, pat)
		cairo_rectangle(cr,0,0,t.width,t.height)
		cairo_fill(cr)
		cairo_pattern_destroy(pat)
	end

    --autoscale
    cairo_save(cr)
	if t.autoscale then
		t.max= t.automax*1.1
	end

    local scale_x = t.width/(t.nb_values-1)
	local scale_y = t.height/t.max

    --define first point of the graph
	if updates-updates_gap <t.nb_values then
		t.beg = t.beg - 1
    	--next line prevent segmentation error when conky window is redraw
		--quicly when another window "fly" over it
		if t.beg<0 then t.beg=0 end
	else
		t.beg=0
	end
    if t.inverse then cairo_scale(cr,-1,1)
    cairo_translate(cr,-t.width,0) end

	--graph foreground
	if t.foreground then
	    local pts_fg=linear_orientation_inv(t.fg_orientation,t.width,t.height)
	    local pat = cairo_pattern_create_linear (pts_fg[1],pts_fg[2],pts_fg[3],pts_fg[4])
		for i=1,#t.fg_colour,1 do
			cairo_pattern_add_color_stop_rgba (pat, 1-t.fg_colour[i][1], rgb_to_r_g_b(t.fg_colour[i]))
		end
		cairo_set_source (cr, pat)

		cairo_move_to(cr,t.beg*scale_x,0)
		cairo_line_to(cr,t.beg*scale_x,t.values[t.beg+1]*scale_y)
		for i=t.beg, t.nb_values-1 do
			cairo_line_to(cr,i*scale_x,t.values[i+1]*scale_y)
		end
		cairo_line_to(cr,(t.nb_values-1)*scale_x,0)
		cairo_close_path(cr)
		cairo_fill(cr)
		cairo_pattern_destroy(pat)
	end

	--graph_border
	if t.fg_bd_size>0 then
    	local pts=linear_orientation_inv(t.fg_bd_orientation,t.width,t.height)
		local pat = cairo_pattern_create_linear (pts[1],pts[2],pts[3],pts[4])
		for i=1,#t.fg_bd_colour,1 do
			cairo_pattern_add_color_stop_rgba (pat, 1-t.fg_bd_colour[i][1], rgb_to_r_g_b(t.fg_bd_colour[i]))
		end
		cairo_set_source (cr, pat)
		cairo_move_to(cr,t.beg*scale_x,t.values[t.beg+1]*scale_y)
		for i=t.beg, t.nb_values-1 do
			cairo_line_to(cr,i*scale_x,t.values[i+1]*scale_y)
		end
		cairo_set_line_width(cr,t.fg_bd_size)
		cairo_stroke(cr)
		cairo_pattern_destroy(pat)
	end
	cairo_restore(cr)

	--background border
	if t.bg_bd_size>0 then
    	local pts=linear_orientation(t.bg_bd_orientation,t.width,t.height)
		local pat = cairo_pattern_create_linear (pts[1],pts[2],pts[3],pts[4])
		for i=1, #t.bg_bd_colour do
			--print ("i",i,t.colour[i][1], rgb_to_r_g_b(t.colour[i]))
		    cairo_pattern_add_color_stop_rgba (pat, t.bg_bd_colour[i][1], rgb_to_r_g_b(t.bg_bd_colour[i]))
		end
		cairo_set_source (cr, pat)
		cairo_rectangle(cr,0,0,t.width,t.height)
		cairo_set_line_width(cr,t.bg_bd_size)
		cairo_stroke(cr)
		cairo_pattern_destroy(pat)
	end

	cairo_restore(cr)

end

