alias PChar = Pointer Char

alias PMonitor = Pointer Monitor
alias PClient = Pointer Client

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
						fence = rect.height - n.second_child.constraints.min_hegith
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
