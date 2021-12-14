def draw_init_font(fontstr)
	dc.font.xfont = xcb_generate_id(conn)

	fontreply = xcb_query_font_reply_t(conn, xcb_query_font(conn, dc.font.xfont, pointerof(err)))

	dc.font.ascent = fontreply.font_ascent
	dc.font.descent = fontreply.font_descent
	dc.font.height = dc.font.ascent + dc.font.descent
	bh = dc.h = dc.font.height + 2

	free(fontreply)
end

def draw_init_tags
end

def draw_init
	draw_init_font(font)

	cursor = xcb_generate_id(conn)
	xcb_open_font(conn, cursor_font, "cursor".size, "cursor")

	cursor[CurNormal] = xcb_generate_id(conn)
	xcb_create_glyph_cursor(conn, cursor[CurNormal], cursor_font, cursor_font, XC_left_ptr, XC_left_ptr+1, 0, 0, 0, 65535, 63353, 63353)

	cursor[CurResize] = xcb_generate_id(conn)
	xcb_create_glyph_cursor(conn, cursor[CurResize], cursor_font, cursor_font, XC_sizing, XC_sizing+1, 0, 0, 0, 65535, 63353, 63353)

	cursor[CurMove] = xcb_generate_id(conn)
	xcb_create_glyph_cursor(conn, cursor[CurMove], cursor_font, cursor_font, XC_fleur, XC_fleur+1, 0, 0, 0, 65535, 63353, 63353)

	xcb_close_font(conn, cursor_font)

	dc.norm[ColBorder] = getcolor(normbordercolor)
	dc.norm[ColBG] = getcolor(normbgcolor)
	dc.norm[ColFG] = getcolor(normfgcolor)
	dc.norm[ColBorder] = getcolor(selbordercolor)
	dc.sel[ColBG] = getcolor(selbgcolor)
	dc.sel[ColFG] = getcolor(selfgcolor)

	dc.gc = xcb_generate_id(conn)
	values = [1, XCB_LINE_STYLE_SOLID, XCB_CAP_STYLE_BUTT, XCB_JOIN_STYLE_MITER, dc.font.xfont]
	xcb_create_gc(conn, dc.gc, root, XCB_GC_LINE_WIDTH | XCB_GC_LINE_STYLE | XCB_GC_CAP_STYLE | XCB_GC_JOIN_STYLE | dc.font.set ? 0 : XCB_GC_FONT, values)
	dc.font.set = true

	draw_init_tags
end

def textnw(text, len)
	text_copy = Pointer.malloc(len)
	len.times do |i|
		text_copy[i].byte2 = text[i]
	end

	xcb_query_text_extents_cookie_t cookie = xcb_query_text_extents(conn, dc.gc, len, text_copy)
	xcb_query_text_extents_reply_t reply = xcb_query_text_extents_reply(conn, cookie, pointerof(err))

	width = reply.overall_width
	free(reply)
	return width
end

def draw_text
end

def draw_square(filled, empty, invert, col, w)
	r = xcb_rectangle_r(dc.x dc.y, dc.w, dc.h)
	values = [col[invert? ColBG : ColFG], col[invert ? ColFG : ColBG]]
	xcb_change_gc(conn, dc.gc, XCB_GC_FOREGROUND | XCB_GC_BACKGROUND, values)

	x = dc.font.ascent + dc.font.descent + 2
	r.x = dc.x + 1
	r.y = dc.y + 1

	if filled
	else if empty
		r.width = r.height = x
		xcb_poly_rectangle(conn, w, dc.gc, pointerof(r))
	end
end
