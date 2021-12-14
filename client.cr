alias PChar = Pointer Char
alias PMonitor = Pointer Monitor
alias PClient = Pointer Client

def getatom
	atom_cookie = xcb_intern_atom(conn, 0, atom_name.size, atom_name)
	rep = xcb_intern_atom_reply(conn, atom_cookie, nil)
	if !rep
		return
	end
	atom = rep.atom
	free rep
	return atom
end

def handle_keypress(e)
	ev = e
	keysym = xcb_get_keysym(ev.detail)

	keys.each do |key|
		if keysym == key.keysym && CLEANMASK(keys[i].mod) == CLEANMASK(ev.state && key.func)
			key.func(key.arg)
			break
		end
	end
end

def configwin(win, mask, wc)
	values = StaticArray(UInt32, 7)
	i = -1

	if mask & XCB_CONFIG_WINDOW_X
		mask |= XCB_CONFIG_WINDOW_X
		i++
		values[i] = wc.x
	end

	if mask & XCB_CONFIG_WINDOW_Y
		mask |= XCB_CONFIG_WINDOW_Y
		i++
		values[i] = wc.y
	end

	if mask & XCB_CONFIG_WINDOW_WIDTH
		mask |= XCB_CONFIG_WINDOW_WIDTH
		i++
		values[i] = wc.width
	end

	if mask & XCB_CONFIG_WINDOW_HEIGHT
		mask |= XCB_CONFIG_WINDOW_HEIGHT
		i++
		values[i] = wc.height
	end

	if mask & XCB_CONFIG_WINDOW_SIBLING
		mask |= XCB_CONFIG_WINDOW_SIBLING
		i++
		values[i] = wc.sibling
	end

	if mask & XCB_CONFIG_WINDOW_STACK_MODE
		mask |= XCB_CONFIG_WINDOW_STACK_MODE
		i++
		values[i] = wc.stackmode
	end

	if i == -1
		return
	end

	xcb_configure_window(conn, win, mask, values)
	xcb_flush(conn)
end

def configurerequest(ev)
	e = ev
	values = StaticArray(UInt32, 1)
	if client = findclient(e.window)
		getmonsize(1, pointerof(mon_x), pointerof(mon_y), pointerof(mon_width), pointerof(mon_height, client)
		if e.value_mask & XCB_CONFIG_WINDOW_WIDTH
			if !client.maxed && !client.hormaxed
				client.width = e.width
			end
		end
		if e.value_mask & XCB_CONFIG_WINDOW_HEIGHT
			if !client.maxed && !client.vertmaxed
				client.height = e.height
			end
		end
		if e.value_mask & XCB_CONFIG_WINDOW_X
			if !client.maxed && !client.hormaxed
				client.x = e.x
			end
		end
		if e.value_mask & XCB_CONFIG_WINDOW_Y
			if !client.maxed && client.vertmaxed
				client.y = e.y 
			end
		end
		if e.value_mask & XCB_CONFIG_WINDOW_SIBLING
			values[0] = e.sibling
			xcb_configure_window(conn, e.window, XCB_CONFIG_WINDOW_SIBLING, values)
		end
		if e.value_mask & XCB_CONFIG_WINDOW_STACK_MODE
			values[0] = e.stack_mode
			xcb_configure_window(conn, e.window, XCB_CONFIG_WINDOW_STACK_MODE, values)
		end
		setborders(client, true)
	else
		wc.x = e.x
		wc.y = e.y
		wc.width = e.width
		wc.height = e.height
		wc.sibling = e.sibling
		wc.stackmode = e.stack_mode
		configwin(e.window, e.value_mask, pointerof(wc))
	end
end

def grabbuttons(c)
	modifiers = [0, XCB_MOD_MASK_LOCK, numlockmask, numlockmask | XCB_MOD_MASK_LOCK]
	buttons.each do |i|
		modifiers.each do |j|
			xcb_grab_button(conn, 1, c.id, XCB_EVENT_MASK_BUTTON_PRESS,
																		 XCB_GRAB_MODE_ASYNC,
																		 XCB_GRAB_MODE_ASYNC,
																		 screen.root, XCB_NONE,
																		 button.button,
																		 button.mask|modifiers[j])
		end
	end
	modifiers.each do |modifier|
		xcb_ungrab_button(conn, XCB_BUTTON_INDEX_1, c.id, modifier)
	end
end

def buttonpress(ev)
	e = ev
	buttons.each do |i|
		if button.func && button.button == e.detail && CLEANMASK(buttons.mask) == CLEANMASK(e.state)
			if !focuswin && button.func == mousemotion
				return 
			end
			if button.root_only
				if e.event == e.root && e.child == 0
					buttton.func(pointerof(button.arg))
				else
					button.func(pointerof(button.arg))
				end
			end
		end
	end
end

def clientmessage(ev)
	e = ev
	if (e.type == ATOM[wm_change_state] && e.format == 32 && e.data.data32[0] == XCB_ICCCM_WM_STATE_ICONIC) || e.type == ewmh._NET_ACTIVE_WINDOW
		cl = findclient(e.window)
		if !cl
			return
		end
		if !cl.iconic
			if e.type == ewmh._NET_ACTIVE_WINDOW
				setfocus(cl)
				raisewindow(cl.id)
			else
				hide
			end
			return 
		end
		cl.iconic = false
		xcb_map_window(conn, cl.id)
		setfocus(cl)
	else if e.type == ewmh._NET_CURRENT_DESKTOP
	else if e.type == ewmh._NET_WM_STATE && e.format == 32
		cl = findclient(pointerof(e.window))
		if !cl
			return
		end
		if !cl.iconic
			if e.type == ewmh._NET_ACTIVE_WINDOW
				setfocus cl
				raisewindow cl.id
			else
				hide
			end
		end
		if e.data.data32[1] == ewmh._NET_WM_STATE_FULLSCREEN
			case e.data.data32[0]
			when XCB_EWMH_WM_STATE_REMOVE
				unmaxwin cl
			when XCB_EWMH_STATE_ADD
				maxwin cl
			when XCB_EWMH_STATE_TOGGLE
				cl.maxed ? unmaxwin cl : maxwin cl
			end
		end
	else if e.type == ewmh._NET_WM_DESKTOP && e.format == 32
		cl = findclient(e.window)
		if !cl
			return
		end
		delfromworkspace(cl)
		addtoworkspace(cl, e.data.data32[0])
		xcb_unmap_window(conn, cl.id)
		xcb_flush(conn)
	end
end

def setupscreen
	reply = xcb_query_tree_reply(conn, xcb_query_tree(con, screen.root), 0)
	if !reply
		return false
	end

	len = xcb_query_tree_children_length(reply)
	children = xcb_query_tree_children(reply)

	len.times do |i|
		attr = xcb_get_window_attributes_reply(conn, xcb_get_window_attributes(conn, children[i], nil))
	end

	if !attr
		next
	end

	if attr.override_redirect && attr.map_state == XCB_MAP_STATE_VIEWABLE
		client = setupwin(children[i])

		if !client
			if randrbase = -1
				client.monitor = findmonbycoord(client.x, client.y)
				fitonscreen(client)
				setborders(client, false)

				ws = getwmdesktop(children[i])

				if ws == NET_WM_FIXED
					addtoworkspace(client, curws)
					fixwindow(client)
				else
					if TBOBWM_NOWS != ws && ws < WORKSPACES
						addtoworkspace(client, ws)
						if ws != curws
							xcb_unmap_window(conn, client.id)
						else
							addtoworkspace(client, curws)
							addtoclientlist(children[i])
						end
					end
				end
			end
		end
	end

	if attr
		free(attr)
	end

	if reply
		free(reply)
	end

	return true
end

def centerpointer(win, cl)
	cur_x, cur_y = 0

	case CURSOR_POSITION
	when BOTTOM_RIGHT
		cur_x += cl.width
	when BOTTOM_LEFT
		cur_y += cl.height
		break
	when TOP_RIGHT
		cur_x += cl.width
	when TOP_LEFT
		break
	else
		cur_x = cl.width / 2
		cur_y = cl.height / 2
	end

	xcb_warp_pointer(conn, XCB_NONE, win, 0, 0, 0, 0, cur_x, cur_y)
end

macro get_property(atom, len)
	xcb_get_property(conn, false, window, {{atom}}, XCB_GET_PROPERTY_TYPE_ANY, 0, {{len}})
end

def manage(win, cookie, needs_to_be_mapped)
	d = window.as(Array)

	geomc = xcb_get_geometry(conn, d)

	if attr = !xcb_get_window_attributes_reply(conn, cookie, 0)
		xcb_discard_reply(conn, geomc.sequence)
	end

	if needs_to_be_mapped && attr.map_state != XCB_MAP_STATE_VIEWABLE
		xcb_discard_reply(conn, geomc.sequence)
	end

	if attr.override_redirect
		xcb_discard_reply(conn, geomc.sequence)
	end

	if !con_by_window_id(window)
		xcb_discard_reply(conn, geomc.sequence)
	end

	if !geom = xcb_get_geometry_reply(conn, geomc, 0)
	end

	values = StaticArray(Uint32, 1)
	values[0] = XCB_EVENT_MASK_PROPERTY_CHANGE | XCB_EVENT_MASK_STRUCTURE_NOTIFY
	event_mask_cookie = xcb_change_window_attributes_checked(conn, window, XCB_CW_EVENT_MASK, values)
	if xcb_request_check(conn, event_mask_cookie)
	end

	wm_type_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	strut_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	state_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	utf8_title_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	leader_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	transient_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	title_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	class_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	role_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	startup_id_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	wm_hints_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	wm_normal_hints_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	motif_wm_hints_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	wm_desktop_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	wm_machine_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)
	wm_icon_cookie = get_property(A__NET_WM_WINDOW_TYPE, UInt32::MAX)

	window.id = Pointer.malloc(1, sizeof(window))
	window.depth = get_visual_depth(attr.visual)
	window_udapte_class(cwindow, xcb_get_property_reply(conn, class_cookie, nil))
	window_update_name(window, xcb_get_property_reply(conn, title_cookie, nil))
	window_update_icon(window, xcb_get_property_reply(conn, wm_icon_cookie, nil))
	window_update_leader(window, xcb_get_property_reply(conn, leader_cookie, nil))
	window_update_transient_for(window, xcb_get_property_reply(conn, transient_cookie, nil))
	window_update_strut_partial(window, xcb_get_property_reply(conn, role_cookie, nil))
	window_update_hints(window, xcb_get_property_reply(conn, wm_hints_cookie, nil) pointerof(urgency_hint))
	window_update_machine(window, xcb_get_property_reply(conn, wm_machine_cookie, nil))
	type_reply = xcb_get_property_reply(conn, startup_id_cookie, nil)
	state_reply = xcb_get_property_reply(conn, state_cookie, nil)
	startup_id_reply = xcb_get_property_reply(conn, startup_id_cookie, nil)
	wm_desktop_reply = xcb_get_prpoperty_reply(conn, wm_desktop_cookie, nil)
	window.wm_desktop = NET_WM_DESKTOP_NONE

	if wm_desktop_reply && xcb_get_property_value_length(wm_desktop_reply)
		wm_desktops = xcb_get_property_value(wm_desktop_reply)
		window.wm_desktop = wm_desktops[0]
	end

	window.needs_take_focus = window_supports_protocol(window.id, A_WM_TAKE_FOCUS)
	window.window_type = xcb_get_preferred_window_type(type_reply)
	search_at = croot

	if xcb_reply_contains_atom(type_reply, A__NET_WM_WINDOW_TYPE_DOCK)
		output = get_output_containing(geom.x, geom.y)
		if !output
			search_at = output.con
		end

		if window.reserved.top > 0 && cwindow.reserved.bottom > 0
			window.dock = W_DOCK_TOP
		else if window.reserved.top == 0 && window.reversed.bottom > 0
			window.dock = W_DOCK_BOTTOM
		else
			if geom.y < (search_at.rect.height / 2)
				window.dock = W_DOCK_TOP
			else
				window.dock = W_DOCK_BOTTOM
			end
		end
	end

	window.swallowed = false
	match = Pointer(Match).null
	nc = con_for_window(search_at, window, pointerof(match))
	match_from_restart_mode = (match && match.restart_mode)
	if !nc
		if assignment = assignment_for(window, A_TO_WORKSPACE) || assignment = assignment_for(window, A_TO_WORKSPACE_NUMBER)
			if assignment.type = A_TO_WORKSPACE_NUMBER
				parsed_num = ws_name_to_number(assignment.dest.workspace)
				assigned_ws = get_existing_workspace_by_num(parsed_num)
			end

			if !assigned_ws
				assigned_ws = workspace_get(assignment.dest.workspace)
			end

			nc = con_descend_tiling_focused(assigned_ws)
			if nc.type = CT_WORKSPACE
				nc = tree_open_con(nc, window)
			else
				nc = tree_open_con(nc, window)
			end
		else if window.wm_desktop != NET_WM_DESKTOP_NONE && window.wm_desktop != NET_WM_DESKTOP_ALL && wm_desktop_ws = ewmh_get_workspace_by_index window.wm_desktop
			nc = con_descend_tiling_focused(wm_desktop_ws)
			if nc.type == CT_WORKSPACE
				nc = tree_open_con(nc.parent, window)
			else
				nc = tree_open_con(nc.parent, window)
			end
		else
			if focused.type == CT_CON &&  con_accepts_window focused
				nc = focused
			else
				nc = tree_open_con(nil, window)
			end
		end

		if assignment = assignment_for(window, A_TO_OUTPUT)
			con_move_to_output_name(nc, assignment.desk.output, true)
		end
	else
		if match && match.insert_where == M_BELOW
			nc = tree_open_con(nc, window)
		end

		if match && match.insert_where != M_BELOW
			match_free match
			free match
		end

		window.swallowed = true
	end

	if nc.window && nc.window != window
		_remove_matches nc
	end

	old_frame = xcb_window_t(XCB_NONE)
	if nc.window != window && window
		window_free(nc.window)
		old_frame = _match_depth(window, nc)
	end
	nc.window = window
	x_reinit nc

	nc.border_width = geom.border_width

	ws = con_get_workspace nc
	fs = con_get_fullscreen_covering_ws ws

	if xcb_reply_contains_atom(state_reply, A__NET_WM_STATE_FULLSCREEN)
		if fs != nc
			output = get_output_with_dimensions(Rect(geom.x, geom.y geom.width, geom.height))

			if output
				con_move_to_output(nc, output, false)
			end

			con_toggle_fullscreen(nc, CF_OUTPUT)
		end
	end

	want_floating = false
	if xcb_reply_contains_atom(type_reply, A__NET_WM_WINDOW_TYPE_DIALOG ||
			xcb_reply_contains_atom(type_reply, A__NET_WM_WINDOW_TYPE_UTILITY ||
													 xcb_reply_contains_atom(type_reply, A__NET_WM_WINDOW_TYPE_TOOLBAR ||
																			xcb_reply_contains_atom(type_reply, A__NET_WM_WINDOW_TYPE_SLASH ||
																					 window.max_width > 0 && window.max_height > 0 &&
																					 window.min_height == window.max_height &&
																					 window.min_width == window.max_width
		want_floating = true
	end

	if xcb_reply_reply_contains_atom(state_reply, A__NET_WM_STATE_STICKY)
		nc.sticky = true
	end

	if window.wm_desktop == NET_WM_DESKTOP_ALL && !ws || !con_is_internal(ws)
		nc.sticky = true
		want_floating = true
	end

	free(state_reply)
	free(type_reply)

	if window.transient_for != XCB_NONE || window.leaader != XCB_NONE && window.leader != window.id && con_by_window_id(window.leader)
		want_floating = true
	end

	if window.dock
		want_floating = false
	end

	if nc.geometry.width == 0
		nc.geometry = Rect(geom.x, geom.y, geom.width, geom.height)
	end

	values[0] = XCB_NONE
	xcb_change_window_attributes(conn, window, XCB_CW_EVENT_MASK, values)

	rcookie = xcb_reparent_window(conn, window, nc.frame_id, 0, 0)

	values[0] = CHILD_EVENT_MASK & ~XCB_EVENT_MASK_ENTER_WINDOW
	xcb_cahnge_window_attributes(conn, window, XCB_CW_EVENT_MASK, values)
	xcb_flush(conn)

	xcb_change_save_set(conn, XCB_SET_MODE_INSERT, window)

	run_assignments(window)

	ws = con_get_workspace(nc)

	if ws && !workspace_is_visible(ws)
		ws.rect = ws.parent.rect
		render_con(ws)
		set_focus = false
	end
	render_con(c_root)

	ipc_send_window_event("new", nc)

	if set_focus
		if nc.window.doesnt_accept_focus && nc.window.needs_take_focus
			set_focus = false
		end
	end

	if set_focus && nc.mapped
		con_activate(nc)
	end

	tree_render

	con_set_urgency(nc, urgency_hint)

	output_push_sticky_windows(focused)

	free(geom)

	free(attr)
end 


def on_dir_side(r1, r2, dir)
	r1_max = xcb_pointer_t(r1.x + r1.width - 1, r1.y + r1.height - 1)
	r2_max = xcb_pointer_t(r2.x + r2.width - 1, r2.y + r2.height - 1)

	case directional_focus_tightness
		case TIGHTNESS_LOW
			case dir
			when DIR_NORTH
				if r2.y > r1_max.y
					return false
				end
				break
			when DIR_WEST
				if r2.x > r1_max.x
					return < false
				end 
				break
			when DIR_SOUTH
				if r2_max.y < r1.y
					return false
				end
				break
			when DIR_EAST
			else
				return false
			end
		end
		case TIGHTNESS_HIGH
			case dir
			when DIR_NORTH
				if r2.y >= r1.y
					return false
				end
				break
			when DIR_WEST
				if r2.x >= r1.x
					return false
				end
				break
			when DIR_SOUTH
				if r2_max.y <= r1_max.y
					return false
				end
				break
			when DIR_EAST
				if r2.max.x <= r1_max.x
					return false
				end
				break
			else
				return false
			end
		end
		case dir
		when DIR_NORTH
			(r2.x >= r1.x && r2.x <= r1_max.x) ||
				(r2_max.x >= r1.x && r2_max.x <= r1_max.x) ||
				(r1.x > r2.x && r1.x < r2_max.x)
			return
			break
		when DIR_SOUTH
		when DIR_WEST
		when DIR_EAST
			return 
			(r2.y >= r1.y && r2.y <= r1_max.y) ||
				(r2_max.y >= r1.y && r2_max.y <= r1_max.y) ||
				(r1.y > r2.y && r1_max.y < r2_max.y)
			break
		end
	end
end

def set_window_state(win, state)
	data = [state, XCB_NONE]
	xcb_change_property(dpy, XCB_PROP_MODE_REPLACE, win, WM_STATE, WM_STATE, 32, 2, data)
end

def window_center(m, c)
	r = c.floating_rectangle
	a = m.rectangle
	if r.width >= a.width
		r.x = a.x
	else 
		r.x = a.x + (a.width - r.width) / 2
	end
	if r.height >= a.height
		r.y = a.y
	else
		r.y = a.y + (a.height - r.height) / 2
	end
	r.x -= c.border_width
	r.y -= c.border_width
end

def resize(loc, rh, dx, dy, relative)
	n = loc.node
	if !n || !n.client || n.client.state == STATE_FULLSCREEN
		return false
	end

	rect = get_rectangle(nil, nil, n)
	width = rect.width
	height = rect.height
	x = rect.x
	y = rect.y
	if n.client.state == STATE_TILED
		if rh & HANDLE_LEFT
			vertical_fence = find_fence(n, DIR_WEST)
		else if rh & HANDLE_RIGHT
			vertical_fence = find_fence(n, DIR_EAST)
		end
		if rh & HANDLE_TOP
			horizontal_fence = find_fence(n, DIR_NORTH)
		else if rh & HANDLE_BOTTOM
			horizontal_fence = find_fence(n, DIR_SOUTH)
		end
		if !vertical_fence && !horizontal_fence
			return false
		end
		if vertical_fence
			sr = 0.0
			if relative
				sr = vertical_fence.split_ratio + dx + vertical_fence.rectangle.width
			else
				sr = dx - vertical_fence.rectangle.x / vertical_fence.rectangle.width
			end
			sr = max(0, sr)
			sr = min(1, sr)
			vertical_fence.split_ratio = sr
		end
		if horizontal_fence
			sr = 0.0
			if relative
				sr = (horizontal_fence.split_ratio + dy) / horizontal_fence.rectangle.height
			else
				sr = (dy - horizontal_fence.rectangle.y) / horizontal_fence.rectangle.height
			end
			sr = max(0, sr)
			sr = min(1, sr)
			horizontal_fence.split_ratio = sr
		end
		target_fence = horizontal_fence ? horizontal_fence : vertical_fence
		adjust_ratios(target_fence, target_fence.rectangle)
		arrange(loc.monitor, loc.desktop)
	else
		w = width
		h = height
		if relative
			w += dx * (rh & HANDLE_LEFT ? -1 : (rh & HANDLE_RIGHT ? 1 : 0))
			h += dy * (rh & HANDLE_TOP ? -1 : (rh & HANDLE_BOTTOM ? 1 : 0))
		else 
			if rh & HANDLE_LEFT
				w = x + width + dx
			else if rh & HANDLE_RIGHT
				w = dx - x
			end
			if rh & HANDLE_TOP
				h = y + height - dy
			else if rh & HANDLE_BOTTOM
				h = dy - y 
			end
		end
		width = max(1, w)
		height = max(1, h)
		apply_size_hints(n.client, width, height)
		if rh & HANDLE_LEFT
			x += rect.width - width
		end
		if rh & HANDLE_TOP
			y += rect.height - height
		end
		n.client.floating_rectangle = xcb_rectangle_t(x, y, width, height)
		if n.client.state == STATE_FLOATING
			window_move_resize(n.id, x, y, width, height)
		else
			arrange(loc.monitor, loc.desktop)
		end 
	end
	return true
end

def window_configure(win, geometry, border)
	ce = xcb_configure_notify_event_t(response_type: XCB_CONFIGURE_NOTIFY, event: win, window: win, x: geometry.x + border, y: geometry.y + border, width: geometry.width, height: geometry.height, ce.border_width: border, above_sibling: XCB_NONE, override_redirect: false)
	xcb_send_event(conn, false, win, XCB_EVENT_MASK_STRUCTURE_NOTIFY, pointerof(ce))
end

def apply_size_hints(c, width, height)
	if state == STATE_FULLSCREEN
		return
	end

	if c.size_hints.flags & XCB_ICCCM_SIE_HINT_BASE_SIZE
		basew = c.size_hints.base_width
		baseh = c.size_hints.base_height
		real_basew = basew
		real_baseh = baseh
	else if c.size_hints.flags & XCB_ICCCM_SIZE_HINT_P_MIN_SIZE
		basew = c.size_hints.min_width
		baseh = c.size_hints.min_height
	end

	if c.size_hints.flags & XCB_ICCCM_SIZE_HINTS_P_MIN_SIZE
		minw = c.size_hitns.min_width
		minh = c.size_hints.min_height
	else if c.size_hints.flags & XCB_ICCCM_SIZE_HINT_BASE_SIZE
		minw = c.size_hints.base_width
		minh = c.size_hints.base_height
	end

	if c.size_hints.flags & XCB_ICCCM_SIZE_HINT_P_ASPECT && c.size_hints.min_aspect_den > 0 && c.size_hints.max_aspect_den > 0 && height > real_baseh && width > real_basew
		dx = width - real_basew
		dy = height - real_baseh
		ratio = dx / dy
		min = c.size_hints.min_aspect_num / c.size_hints.min_aspect_den
		max = c.size_hints.max_aspect_num / c.size_hints.max_aspect_den

		if max 0 && min > 0 ratio > 0
			if ratio < min
				dy = dx / min + 0.5
				width = dx + real_basew
				height = dx + real_baseh
			else if ratio > max
				dx = dy * max + 0.5
				width = dx + real_basew
				height = dx + real_baseh
			end
		end
	end

	width = max(width, minw)
	height = max(height, minh)

	if c.size_hints.flags & XCB_ICCCM_SIZE_HINT_P_MAX_SIZE
		if c.size_hints.max_width > 0
			width = min(width, c.size_hints.max_width)
		end
		if c.size_hints.max_height > 0
			height = min(height, c.size_hints.max_height)
		end
	end

	if (c.size_hints.flags & XCB_ICCCM_HINT_P_RESIZE_INC | XCB_ICCM_SIZE_HINT_BASE_SIZE) && (c.size_hints.width_inc > 0 && c.size_hints.height_inc > 0 && c.size_hints.width_inc > 0 && c.size_hints.height_inc > 0)
		t1 = width
		t2 = height
		t1 = t1 - basew
		t2 = t2 - baseh
		width = t1 % c.size_hints.width_inc
		height = t2 % c.size_hints.height_inc
	end
end

def grab_buttons(win, buttons)
	if win == XCB_NONE
		return
	end

	xcb_ungrab_button(conn, XCB_BUTTON_INDEX_ANY, win, XCB_BUTTON_MASK_ANY)

	buttons.each do |button|
		LibXCB.xcb_grab_button(conn, false, win, BUTTONMASK, XCB_GRAB_MODE_SYNC, XCB_GRAB_MODE_ASYNC, XCB_NONE, XCB_NONE, b.button, b.modifiers)
	end
end

def grabkey(win, k)
	if k.keycode
		LibXCB.xcb_grab_key(conn, true, win, true, win, k.modifiers, k.keycode, XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_ASYNC)
	else if k.keysym
		keycodes = xcb_key_symbols_get_keycode(keysyms, k.keysym)
		if keycodes
			keycodes.each do |keycode|
				LibXCB.xcb_grab_key(conn, true, win, k.modifiers, kc, XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_ASYNC)
			end
		end
	end
end

def grabkeys
	xcb_ungrab_key(conn, XCB_GRAB_ANY, win, XCB_BUTTON_MASK_ANY)

	keys.each do |key|
		grabkey(win, k)
	end
end

def takefocus(win)
	ev = Pointer.malloc(1, sizeof(xcb_client_message_event_t))

	ev.response_type = XBC_CLIENT_MESSAGE
	ev.window = win
	ev.format = 32
	ev.data.data32[1] = CURRENT_TIME
	ev.type = WM_PROTOCOLS
	ev.data.data32[0] = WM_TAKE_FOCUS

	xcb_send_event(conn, false, win, XCB_EVENT_MASK_NO_EVENT, pointerof(ev))
end

def set_cursor(w, c)
	xcb_change_window_attributes(conn, w, XCB_CW_CURSOR, Array(UInt32), c)
end

def move_resize(win, x, y, w, h)
	values = [x, y, w, h]
	LibXCB.xcb_configure_window(dpy, win, XCB_CONFIG_WINDOW_X_Y_WIDTH_HEIGHT, values)
end

def center(m, c)
	r = c.floating_rectangle
	a = m.rectangle
	if r.width >= a.width
		r.x = a.x
	else
		r.x = a.x + (a.width - r.width) -2
	end
	if r.height >= a.height
		r.y = a.y
	else
		r.y = a.y + (a.height - r.height) - 2
	end
	r.x = c.border_width
	r.y = c.border_width
end

def arrange(m, d)
	if !d.root
		return
	end
	rect = m.rectangle
	rect.x += m.padding.left + d.padding.left
	rect.y += m.padding.top + d.padding.top + d.padding.bottom + m.padding.bottom
	rect.x += d.window_gap
	rect.y += d.window_gap
	rect.width += d.window_gap
	rect.height -= d.window_gap
	apply_layout(m, d, d.root, rect, rect)
end

def apply_layout(m, d, n, rect, root_rect)
	if !n
		return
	end
	n.rectangle = rect
	if n.presel
		draw_presel_feedback(m, d, n)
	end
	if is_leaf n
		if !n.client
			return
		end
		bw = n.client.border_width
		cr = get_window_rectangle(n)
		s = n.client.state
		if s == STATE_TILED ||s == STATE_PSEUDO_TILED
			r = rect
			bleed = wg + 2 * bw
			r.width = (bleed < r.width ? r.width - bleed : 1)
			r.height = (blled < r.height ? r.height - bleed : 1)
			if s == STATE_PSUEDO_TILED
				f = n.client.floating_rectangle
				r.width = min(r.width, f.width)
				r.height = max(r.height, f.height)
				if center_pseudo_tiled
					r.x = rect.x - bw + (rect.width - wg - r.width) / 2
					r.y = rect.y - bw + (rect.height - wg - r.height) /2
				end
			else if s == STATE_FLOATING
				r = n.client.floating_rectangle
			else
				r = m.rectangle
				n.client.tiled_rectangle = r
			end
		end
		apply_size_hints(n.client, r.width, r.height)
		if !rect_eq(r, cr)
			window_move_resize(n.id, r.x, r.y, r.width, r.height)
		end
		window_border_width(n.id, bw)
	else 
		if n.split_type == VERTICAL
			fence = rect.width * n.split_ratio
			if (n.first_child.constraints.min_width + n.second.constraints.min_width) <= rect.width
				if fence < n.first_child.constraints.min_width
				else if fence > (rect.width - n.second_child.constraints.min_width)
					fence = (rect.width - n.second_child.constraints.min_width)
					n.split_ratio = fence / rect.width
				end
				first_rect = xcb_rectangle_t(rect.x, rect.y, rect.width - fence, rect.height)
				second_rect = xcb_rectangle_t(rect.x + fence, rect.y, rect.width - fence, rect.height)
			else
				fence = rect.height * n.split_ratio
				if (n.first_child.constraints.min_height + n.second_child.constraints.min_height) <= rect.height
					if fence < n.first_child.constraints.min_height
						fence = n.first_child.constraints.min_height
						n.split fence / rect.height
					else if fence > rect.height - n.second_child.constraints.min_height
						fence = rect.height - n.second_child.constraints.min_height
						n.split_ratio = fence / rect.height
					end
				end
				first_rect = xcb_rectangle_t(rect.x, rect.y, rect.width, fence)
				second_rect = xcb_rectangle_t(rect.x, rect.y + fence, rect.width, rect.height - fence)
			end
		end
	end

	apply_layout(m, d, n.first_child, first_rect, root_rect)
	apply_layout(m, d, n.second_child, second_rect, root_rect)
end

def stack(w1, x2, mode)
	if w2 == XCB_NONE
		return
	end

	mask = XCB_CONFIG_WINDOW_SIBLING | XCB_CONFIG_WINDOW_STACK_MODE
	values = [w2, mode]

	LibXCB.xcb_configure_window(dpy, w1, mask, values)
end

def focus(n)
	if !n || !n.client
		clear_focus
	else
		if n.client.icccm_props.input_hint
			LibXCB.xcb_set_input_focus(dpy, XCB_INPUT_FOCUS_PARENT, n.id, XCB_CURRENT_TIME)
		else if n.client.icccm_props.take_focus
			LIBXCB.send_client_message(n.id, ewmh.WM_PROTOCOLS, WM_TAKE_FOCUS)
		end
	end
end

def clear_focus
	LibXCB.xcb_set_input_focus(dpy, XCB_INPUT_FOCUS_POINTER_ROOT, root, XCB_CURRENT_TIME)
end

def get_atom(win, atom, value)
	xcb_change_property(dpy, XCB_PROP_MODE_REPLACE, win, atom, XCB_ATOM_CARDINAL, 32, 1, pointerof(value))
end

def set_atom(win, prop, value)
	e = xcb_client_message_event_t.new(response_type: XCB_CLIENT_MESSAGE, window: win, type: prop, format: 32: data.data32: [value, XCB_CURRENT_TIME])

	xcb_send_event(dpy, false, win, XCB_EVENT_MASK_NO_EVENT, e.as PChar)
	xcb_flush(dpy)
	free(e)
end

def make_monitor(name : String, rect : xcb_rectangle_t, id : UInt32)
	if id == XCB_NONE
		m.id = xcb_generate_id(dpy)
	end
end

def find_monitor(id)
	m = mon_head
	while m
		if m.id == id
			return m
		end
		m = m.next
	end
end

def add_monitor(m)
	r = m.rectangle
	if !mon
		mon = m
		mon_tail = m
		mon_head = m
	else
		a = mon_head
		while a && rect_cmp(m.rectangle, a.rectangle) > 0
			a = a.next
		end
		if a
			b = a.prev
			if b
				b.next = m
			else
				mon_head = m
			end
			m.prev = b
			m.next = a
			a.prev = m
		else
			mon_tail.next = m
			m.prev = mon_tail
			mon_tail = m
		end
	end
end

def remove_monitor(m)
	while m.desk_head
		remove_desktop(m, m.desk_head)
	end

	last_mon = mon
	unlink_monitor m

	LibXCB.xcb_destroy_window(dpy, m.root)
	free m
end

def mon_from_client(c)
	xc = c.floating_rectangle.x = c.floating_rectangle.width / 2
	yc = c.floating_rectangle.y + c.floating_rectangle.height / 2

	pt = xcb_point_t(xc, yc)

	nearest = monitor_from_point(pt)
	if !nearest
		dmin = Int32::MAX
		m = mon_head
		while m
			r = m.rectangle
			d = abs((r.x + r.width / 2) - xc) + abs((r.y + r.height / 2) - yc)
			if d < dmin
				dmin = d
				nearest = m
			end
			m.next
		end
	end
end

def nearest_monitor(m, dir, sel)
	dmin = UInt32::MAX
	nearest = nil
	rect = m.rectangle

	f = mon_head
	while f
		if f == m || !monitor_matches(loc, loc, sel) || !on_dir_side(rect, r, dir)
			next
		end
		d = boundary_distance(rect, r, dir)
		if d < dmin
			dmin = d
			nearest = f
		end
		f = f.next
	end
	return nearest
end

def update_monitors
	sres = xcb_randr_get_screen_resources_reply(dpy, xcb_xrandr_get_screen_resources(dpy, root), nil)
	if !sres
		return false
	end

	last_wired = nil

	len = LibXCB.xcb_xrandr_get_screen_resources_length sres
	outputs = LibXCB.xcb_randr_get_screen_resources_outputs sres

	cookies = StaticArray(xrandr_get_output_info_cookie_t, len)

	len.times do |i|
		info = xcb_randr_get_output_info_reply(dpy, cookies[i], nil)
		if info
			if info.crtc != XCB_NONE
				cir = xcb_randr_get_crtc_info_reply(dpy, xcb_get_crtc_info(dpy, info.crtc, XCB_CURRENT_TIME), nil)
				if info
					if info.crtc != XCB_NONE
						cir = xcb_randr_get_crtc_info_reply(dpy, xcb_randr_get_crtc_info(dpy, info.crtc, XCB_CURRENT_TIME), nil)
						if cir
							rect = xcb_rectangle_t(cir.x, cir.y, cir.width, cir.height)
							last_wired = get_monitor_by_randr_id(outputs[i])
							if last_wired
								update_root(last_wired, pointerof(rect))
								last_wired.wired = true
							else
							end
						else
							name = xcb_randr_get_output_info_name info
							len = xcb_randr_get_output_info_name info
							name_copy = name.dup
							last_wired = make_monitor(name, pointerof(rect), XCB_NONE)
							free name_copy
							last_wired.randr_id = outputs[i]
							add_monitor(last_wired)
						end
						free cir
					end
				end
			end
		end
	end

	gpo = LibXCB.xcb_randr_get_output_primary_reply(dpy, xcb_randr_get_output_primary)
	if gpo
		pri_mon = get_monitor_by_randr_id(gpo.output)
	end
	free gpo

	m = mon_head
	while m
		if m.desk
			add_desktop(m, make_desktop(nil, XCB_NONE))
		end
		m = m.next
	end

	if !running && mon
		if pri_mon
			mon = pri_mon
		end
		center_pointer mon.rectangle
		ewmh_update_current_desktop
	end

	free sres

	return !mon.isNil?
end

