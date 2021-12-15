bh, blw = 0
numlockmask = 0
cursor = StaticArray(xcb_cursor_t, CurLast)

mons, selmon = Pointer(Monitor).null
root = uninitialized xcb_window_t
xscreen = Pointer(xcb_screen_t).null
syms = Pointer(xcb_key_symbols_t).null
err = Pointer(xcb_generic_error_t).null
conn = Pointer(xcb_connection_t).null

NetSupported = uninitialized xcb_atom_t
NetWMName = uninitialized xcb_atom_t
NetWMState = uninitialized xcb_atom_t
NetWMFullscreen = uninitialized xcb_atom_t

WMProtocols = uninitialized xcb_atom_t
WMDelete = uninitialized xcb_atom_t
WMState = uninitialized xcb_atom_t

def arrange(m)
	if m
		client_show_hide(m.stack)
		client_focus(nil)
		arrangemon(m)
	else
		m = mons
		while m
			client_show_hide(m.stack)
			m = m.next
		end

		client_focus(nil)

		m = mons
		while m
			arrangemon(m)
			m = m.next
		end
	end 
end

def arrangemon(m)
	m.ltsymbol = m.lt[m.sellt].symbol

	if m.lt[m.sellt].arrange
		m.lt[m.sellt].arrange(m)
	end

	restack(m)
end

def checkotherwm
	wm_cookie = xcb_change_window_attributes_checked(conn, root, XCB_EVENT_MASK, XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT.as(Array(UInt32)))
	if err = xcb_reqest_check(conn, wm_cookie)
		free(err)
	end
end

def cleanup
	a = Arg(ui: 0)
	foo = Layout("", nil)
	
	view(pointerof(a))
	selmon.lt[selmon.sell] = pointerof(foo)
	m = mons 
	while m
		while m.stack
			client_unmanage(m.stack, false)
		end
		m = m.next
	end
	xcb_close_font(conn, dc.font.xfont)
	xcb_ungrab_key(conn, cursor[CurNormal])
	xcb_free_cursor(conn, cursor[CurResize])
	xcb_free_cursor(conn, cursor[CurMove])
	xcb_free_colors(conn, xscreen.default_colormap, 0, ColLast, dc.norm)
	xcb_free_colors(conn, xscreen.default_colormap, 0, ColLast, dc.last)

	while mons
		cleanupmon(mons)
	end

	xcb_set_input_focus(conn, XCB_INPUT_FOCUS_POINTER_ROOT, XCB_INPUT_FOCUS_POINTER_ROOT, XCB_CURRENT_TIME)
	xcb_flush(conn)
end

def cleanupmon
	if mon = mons
		mons = mons.next
	else
		m = mons 
		while m && m.next != mon
			m = m.next
		end
		m.next = mon.next
	end 

	xcb_unmap_window(conn, mon.barwin)
	xcb_destroy_window(conn, mon.barwin)
	free(mon)
end

def createmon
	m = Pointer.malloc(sizeof(Monitor))
	m.tagset[0] = m.tagset[1]
	m.fact = mfact
	m.showbar = showbar
	m.topbar = topbar
	m.lt[0] = pointerof layouts[0]
	m.lt[1] = pointerof layouts[1]
	m.ltsymbol = layouts[0].symbol
	return m
end

def dirtomon(dir)
	if dir > 0
		if !m = selmon.next
			m = mons
		end
	else
		if selmon == mons
			m = mons
			while m
				m = m.next
			end
		else
			m = mons
			while m.next != selmon
				m = m.next
			end
		end
	end

	return m
end

def getcolor(colstr)
	cmap = xscreen.default_colormap
	colcopy = cmap.dup

	if xcb_aux_parse_color(colcopy, pointerof red, pointerof green, pointerof blue)
		if reply = xcb_alloc_color_reply(conn, xcb_alloc_color(cmap, red, green, blue), pointerof err)
			pixel = reply.pixel
			free(reply)
		else
			pixel = screen.black_pixel
		end
	else
		if reply = xcb_alloc_named_color(conn, cmap, colstr.size, colstr, pointerof err)
			pixel = reply.pixel
			free(reply)
		else
			pixel = xscreen.black_pixel
		end 
	end

	return pixel
end

def getrootptr
	reply = xcb_query_pointer_reply(conn, xcb_query_pointer(conn, root), pointerof err)

	x = reply.root_x
	y = reply.root_y

	free(reply)

	return true
end 

def getstate(w)
	result = -1

	cookie = xcb_get_property(conn, 0, w, WMState, XCB_ATOM_ATOM, 0, 0)
	reply = xcb_get_property_reply(conn, cookie, pointerof err)

	if !reply
		return -1
	end

	if !xcb_get_property_value_length(reply)
		free(reply)
		return -1
	end

	result = Pointer(xcb_get_property_value(reply))
	free(reply)

	result
end

def gettextprop(w, atom, text, size)
	reply = nil
	if !xcb_icccm_get_text_property_reply(conn, xcb_icccm_get_text_property(conn, w, atom), pointerof reply, pointerof err)
		return false
	end

	if err
		return false
	end

	if !reply.name || !reply.name_len
		return false
	end

	xcb_icccm_get_text_property_reply_wipe(pointerof(reply))

	return true
end

def grabbuttons(c, focused)
	updatenumlockmask
	xcb_ungrab_button(conn, XCB_BUTTON_INDEX_ANY, c.win, XCB_GRAB_ANY)

	if focused
		buttons.each do |button|
			if !button.func
				break
			end

			if button.click == ClkClientWin
				xcb_grab_button(conn, false, c.win, BUTTONMASK, XCB_GRAB_MODE_SYNC, XCB_GRAB_MODE_ASYNC, XCB_WINDOW_NONE, XCB_CURSOR_NONE, buttons.button, buttons.mask)
				xcb_grab_button(conn, false, c.win, BUTTONMASK, XCB_GRAB_MODE_SYNC, XCB_GRAB_MODE_ASYNC, XCB_WINDOW_NONE, XCB_CURSOR_NONE, buttons.button, buttons.mask | XCB_MOD_MASK_LOCK)
				xcb_grab_button(conn, false, c.win, BUTTONMASK, XCB_GRAB_MODE_SYNC, XCB_GRAB_MODE_ASYNC, XCB_WINDOW_NONE, XCB_CURSOR_NONE, buttons.button, buttons.mask | numlockmask)
				xcb_grab_button(conn, false, c.win, BUTTONMASK, XCB_GRAB_MODE_SYNC, XCB_GRAB_MODE_ASYNC, XCB_WINDOW_NONE, XCB_CURSOR_NONE, buttons.button, buttons.mask | numlockmask | XCB_MOD_MASK_LOCK)
			else
				xcb_grab_button(conn, false, c.win, BUTTONMASK, XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_SYNC, XCB_WINDOW_NONE, XCB_CURSOR_NONE, XCB_BUTTON_INDEX_ANY, XCB_BUTTON_MASK_ANY)
			end
		end
	end
end

def grabkeys
	updatenumlockmask
	xcb_ungrab_key(conn, XCB_GRAB_ANY, root, XCB_MOD_MASK_ANY)

	keys.each do |key|
		if !key.func
			break
		end

		if code = xcb_key_symbols_get_keycode(syms, key.keycode)
			xcb_grab_key(conn, true, root, key.mod, Pointer(code), XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_ASYNC)
			xcb_grab_key(conn, true, root, key.mod | XCB_MOD_MASK_LOCK, Pointer(code), XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_ASYNC)
			xcb_grab_key(conn, true, root, key.mod | numlockmask, Pointer(code), XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_ASYNC)
			xcb_grab_key(conn, true, root, key.mod | numlockmask | XCB_MOD_MASK_LOCK, Pointer(code), XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_ASYNC)
			free(code)
		end
	end
end

def keypress(e)
	ev = e
	keysym = xcb_key_press_lookup_keysym(syms, ev, 0)
	keys.each do |key|
		if !key.func
			break
		end

		if keysym == key.keysym && cleanmask(key.mod) == cleanmask(ev.state)
			key.func(key.arg)
		end
	end
end

def ptrtomon(x, y)
	m = mons
	while m
		if inrect(x, y, m.wx, m.wy, m.ww, m.wh)
			return m
		end
		m.next
	end

	return selmon
end

def manage(w)
	trans = XCB_WINDOW_NONE

	c = Pointer.malloc(sizeof(Client))

	c.win = w
	client_update_title(c)

	geom_cookie = xcb_get_geometry(conn, w)

	trans_reply = XCB_NONE
	xcb_iccm_get_transient_for_reply(conn, xcb_icccm_get_wm_transient_for(conn, w), pointerof trans_reply, pointerof err)

	if trans_reply != XCB_NONE
		t = client_get_from_window(trans_reply)
	end

	if t
		c.mon = t.mon
		c.tags = t.tags
	else
		c.mon = selmon
		c.isfloating = 0
		c.tags = c.mon.tagset[c.mon.seltags]
	end

	geom_reply = xcb_get_geometry_reply(conn, geom_cookie, pointerof err)

	c.x = c.oldx = geom_reply.x + c.mon.wx
	c.y = c.oldx = geom_reply.y + c.mon.wy
	c.w = c.oldw = geom_reply.width
	c.h = c.oldh = geom_reply.height
	c.oldbw = geom_reply.border_width

	if c.w == c.mon.mw && c.h == c.mon.mh
		c.isfloating = 1
		c.x = c.mon.mx
		c.y = c.mon.my
		c.bw = 0
	else
		if c.x + width(c) > c.mon.mx + c.mon.mw
		end
		if c.y + height(c) > c.mon.my + c.mon.mh
		end
		c.x = max(c.x, c.mon.mx)
		c.y = max(c.y, ((c.mon.by == 0) && c.x + (c.w / 2) >= c.mon.wx) && (c.x + (c.w / 2) < c.mon.wx + c.mon.ww) ? bh : c.mon.my)
		c.bw = borderpx
	end

	cw_values = [dc.norm[ColBorder], XCB_EVENT_MASK_ENTER_WINDOW | XCB_EVENT_MASK_FOCUS_CHANGE | XCB_EVENT_MAK_PROPERTY_CHANGE | XCB_EVENT_MASK_STRUCTURE_NOTIFY]
	xcb_change_window_attributes(conn, w, XCB_CW_BORDER_PIXEL | XCB_CW_EVENT_MASK, cw_values)
	client_configure(c)
	client_update_size_hints(c)
	grabbuttons(c, false)
	if !c.isfloating
		c.isfloating = c.oldstate = trans != XCB_WINDOW_NONE || c.isfixed
	end
	client_attach(c)
	client_attach_stack(c)
	config_values = [c.x + 2 * sw, c.y, c.w, c.h, c.bw, XCB_STACK_MODE_ABOVE]
	xcb_configure_window(conn, c.win, XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_HEIGHT | XCB_CONFIG_WINDOW_BORDER_WIDTH | c.isfloating ? XCB_CONFIG_WIDOW_STACK_MODE : 0, config_values)
	xcb_map_window(conn, c.win)
	client_set_state(c, XCB_ICCC_WM_STATE_NORMAL)
	arrange(c.mon)
end

def monocle(m)
	n = 0
	c = c.clients
	while c
		if isvisible(c)
			n++
		end
		c.next
	end
	if n > 0
		n++
	end
	c = client_next_tiled(m.clients)
	while c
		client_resize(c, m.wx, m.wy, m.ww -2 * c.bw, m.wh - 2 * c.bw, false)
		client_next_tiled(c.next)
	end
end

def restack(m)
	draw_bar(m)

	if !m.sel
		return
	end 

	if m.sel.isfloating || m.lt[m.sellt].arrange
		xcb_configure_window(conn, m.sel.win, XCB_CONFIG_WINDOW_STACK_MODE, XCB_STACK_MODE_ABOVE.as(Array(UInt32))
	end

	if m.lt[m.sellt].arrange
		values = [m.barwin, XCB_STACK_MODE_BELOW]
		if !c.isfloating && isvisible(c)
			values = [m.barwin, XCB_STACK_MODE_BELOW]
			xcb_configure_window(conn, c.win, XCB_CONFIG_WINDOW_SIBLING | XCB_CONFIG_WINDOW_STACK_MODE, values)
			values[0] = c.win
		end
	end

	xcb_flush(conn)

	handle_clear_event(XCB_ENTER_NOTIFY)
end

def scan
	query_reply = xcb_query_tree_reply(conn, xcb_query_tree(conn, root), pointerof err)
	num = query_reply.children_len
	wins = xcb_query_tree_children(query_reply)

	num.times do |i|
		ga_reply = xcb_get_window_attributes_reply(conn, xcb_get_window_attributes(conn, wins[i]), pointerof err)

		if ga_reply.override_redirect
			next
		end

		trans_reply = XCB_NONE
		xcb_icccm_get_wm_transient_for_reply(conn, xcb_icccm_get_wm_transient_for(conn, wins[i]), pointerof trans_reply, pointerof err)

		if trans_reply != XCB_NONE
			next
		end

		if ga_reply.map_state == XCB_MAP_STATE_VIEWABLE || getstate(wins[i]) == XCB_ICCCM_WM_STATE_ICONIC
			manage(wins[i])
		end

		free(ga_reply)
	end
	
	num.times do |i|
		ga_reply = xcb_get_window_attributes_reply(conn, xcb_get_window_attributes(conn, wins[i], pointerof err))

		trans_reply = XCB_NONE
		xcb_icccm_get_wm_transient_for_reply(conn, xcb_icccm_get_wm_transient_for(conn, wins[i], pointerof trans_reply, pointerof err))

		if trans_reply != XCB_NONE && ga_reply.map_state == XCB_MAP_STATE_VIEWABLE || getstate(wins[i]) == XCB_ICCCM_WM_STATE_ICONIC
			manage(wins[i])
		end

		free(ga_reply)
	end

	if query_reply
		free(query_reply)
end

def setup_atom
	atom_cookie = xcb_intern_atom(conn, 0, name.size, name)
	reply = xcb_intern_atom_reply(conn, atom_cookie, pointerof err)

	reply.atom
end

def setup
	draw_init

	sw = xscreen.width_in_pixels
	sh = xscreen.height_in_pixels
	updategeom
	
	WMProtocols = setup_atom("WM_PROTOCOLS")
	WMDelete = setup_atom("WM_DELETE_WINDOW")
	WMState = setup_atom("WM_STATE")
	NetSupported = setup_atom("_NET_SUPPORTED")
	NetWMName = setup_atom("_NET_WM_NAME")
	NetWMState = setupp_atom("_NET_WM_STATE")
	NetWMFullscreen = setup_atom("_NET_WM_STATE_FULLSCREEN")

	updatebars
	updatestatus

	supported = [NetSupported, NetWMName, NetWMState, NetWMFullscreen]
	xcb_change_property(conn, XCB_PROP_MODE_REPLACE, root, NetSupported, XCB_ATOM, 32, sizeof supported / sizeof xcb_atom_t, supported)

	cw_values = [XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY | XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_ETNER_WINDOW | XCB_EVENT_MASK_LEAVE_WINDOW | XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_PROPERTY_CHANGE, cursor[CurNormal]]

	syms = xcb_key_symbols_alloc(conn)
	grabkeys
end

def tile
	c = client_next_tiled(m.clients)
	n = 0
	while c
		c = client_next_tiled(c.next)
		n++
	end

	if n == 0
		return
	end

	c = client_next_tiled(m.clients)
	mw = m.mfact * m.ww
	client.resize(c, m.wx, m.wy, (n == 1 ? m.ww : mw) - 2 * c.bw, m.wh - 2 * c.bw, false)
	if --n == 0
		return
		x = (m.wx + mw > c.x + c.w) ? c.x + c.w + 2 * c.bw : m.wx + mw
		y = m.wy
		w = (m.wx + mw > c.x c.w) ? m.wx + m.ww - x : m.ww - mw
		h = m.wh / n
		if h < bh
			h = m.wh
		end
		c = client_next_tiled(c.next)
		i = 0
		while c
			client_resize(c, x, y, w - 2 * c.bw, ((i + 1 == n) ? m.wy + m.wh - y - 2 * c.bw : h - 2 * c.bw), false)
			if h != m.wh
				y = c.y + height(c)
			end
			c = client_next_tiled(c.next)
			i++
		end
end

def updatebars
	values = [XCB_BACK_PIXMAP_NONE, dc.norm[ColBG], true, XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_EXPOSURE, cursor[CurNormal]]
	m = mons
	while m
		m.barwin = xcb_generate_id(conn)
		xcb_create_window(conn, XCB_COPY_FROM_PARENT, m.barwin, root, m.wx, m.by, m.ww, bh, 0, XCB_WINDOW_CLASS_INPUT_OUTPUT, xscreen.root_visual, XCB_CW_BACK_PIXMAP | XCB_CW_BACK_PIXEL | XCB_CW_OVERRIDE_REDIRECT | XCB_CW_EVENT_MASK | XCB_CW_CURSOR, values)
		xcb_map_window(conn, m.barwin)

		m.next
	end
end

def updatebarpos
	m.wy = m.my
	m.wh = m.mh
	
	if m.showbar
		m.wh -= bh
		m.by = m.topbar ? m.wy : m.wy + m.wh
		m.wy = m.topbar ? m.wy + bh : m.wy
	else
		m.by = -bh
	end
end

def updategeom
	dirty = false

	if !mons
		mons = createmon
	end

	if mons.mw != sw || mons.mh != sh
		dirty = true
		mons.mw = mons.ww = sw
		mons.mh = mons.wh = sh
		updatebarpos(mons)
	end

	if dirty
		selmon = mons
		selmon = wintomon(root)
	end

	dirty
end

def updatenumlockmask
	reply = xcb_get_modifier_mapping_reply(conn, xcb_get_modifier_mapping(conn), pointerof(err))
	codes = xcb_get_modifier_mapping_keycodes(reply)

	if !temp = xcb_key_symbols_get_keycode(syms, XK_Num_lock)
		target = temp
		free(temp)
	else
		return
	end

	8.times do |i|
		reply.keycodes_per_modifier.times do |j|
			if codes[i * reply_keycodes_per_modifier + j] == target
				numlockmask = (1 << i)
			end
		end
	end
end

def updatestatus
	if !gettextprop(root, XCB_ATOM_WM_NAME, stext, sizeof(stext))
		drawbar(selmon)
	end
end

def updatewindowhints(c)
	if !xcb_icccm_get_wm_hints_reply(conn, xcb_icccm_get_wm_hints_reply(conn, c.win), pointerof wmh, pointerof err)
		return
	end

	if c == selmon.sel && wmh.flags & XCB_ICCCM_WM_HINT_X_URGENCY
		wmh.flags &= ~XCB_ICCCM_WM_HINT_X_URGENCY
		xcb_icccm_set_wm_hints(conn, c.win, &wmh)
	else
		c.isurgent = (wmh.flags & XCB_ICCCM_HINT_X_URGENCY) ? true : false
	end
end

def wintomon(w)
	if w == root && getrootptr(&x, &y)
		return ptrtomon(x, y)
	end

	m = mons
	while m
		if w == m.barwin
			return m
		end
		m.next
	end

	if  c = client_get_from_window(w)
		return c.mon
	end

	selmon
end
