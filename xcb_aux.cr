fun xcb_aux_get_depth(x0 : xcb_connection_t*, x1 : Pointer(xcb_screen_t)) : UInt8

fun xcb_aux_get_depth_of_visual(x0 : Pointer(xcb_screen_t), x1 : xcb_visualid_t) : UInt8

fun xcb_aux_get_screen(x0 : Pointer(xcb_connection_t), x1 : Int32): Pointer(xcb_screen_t)

fun xcb_aux_get_visualtype(x0 : Pointer(xcb_connection_t), x1 : Int32, x2 : xcb_visualid_t) : Pointer(xcb_visualtype_t)

fun xcb_aux_find_visual_by_id(x0 : Pointer(xcb_screen_t), xcb_visualid_t) : Pointer(xcb_visualtype_t)

fun xcb_aux_find_visual_by_attrs(x0 : Pointer(xcb_screen_t), x1 : Int8, x2 : Int8): Pointer(xcb_visualtype_t)

fun xcb_aux_sync(Pointer(xcb_connection_t)) : Void

struct xcb_params_cw_t
    back_pixmap : UInt32
    back_pixel : UInt32
    border_pixmap : UInt32
    border_pixel : UInt32
    bit_gravity : UInt32
    win_gravity : UInt32
    backing_store : UInt32
    backing_planes : UInt32
    backing_pixel : UInt32
    override_redirect : UInt32
    save_under : UInt32
    event_mask : UInt32
    dont_propagate : UInt32
    colormap : UInt32
    cursor : UInt32
end

fun xcb_aux_create_window (x0 : Pointer(xcb_connection_t), x1 : UInt8, x2 : xcb_window_t, x3 : xcb_window_t, x4 : Int16, x5 : Int16, x6 : UInt16, x7 : UInt16, x8 : UInt16, x9 : UInt16, x10 : xcb_visualid_t, x11 : UInt32, x12 : Pointer(xcb_params_cw_t)) : xcb_void_cookie_t

fun xcb_aux_create_window_checked (x0 : Pointer(xcb_connection_t), x1 : UInt8, x2 : xcb_window_t, x3 : xcb_window_t, x3 : Int16, x4 : Int16, x5 : UIn16, x6 : UInt16, x7 UIn16, x8 : UInt16, x9 : xcb_visualid_t, x10 : UInt32, x11 : Pointer(xcb_params_cw_t)) : xcb_void_cookie_t


fun xcb_aux_change_window_attributes (x0 : Pointer(xcb_connection_t), x1 : xcb_window_t , x2 : UInt32 , x3 : Pointer(xcb_params_cw_t)) :  xcb_void_cookie_t

struct xcb_params_configure_window_t
	x : Int32  
	y : Int32  
	width : UInt32 
	height : UInt32 
	border_width : UInt32 
	sibling : UInt32 
	stack_mode : UInt32 
end

fun xcb_aux_configure_window(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : UInt16, x3 : Pointer(xcb_params_configure_window_t)) : xcb_void_cookie_t

struct xcb_params_gc_t
	function : UInt32
	plane_mask : UInt32
	foreground : UInt32
	background : UInt32
	line_width : UInt32
	line_style : UInt32
	cap_style : UInt32
	join_style : UInt32
	fill_style : UInt32
	fill_rule : UInt32
	tile : UInt32
	stipple : UInt32
	tile_stipple_origin_x : UInt32
	tile_stipple_origin_y : UInt32
	font : UInt32
	subwindow_mode : UInt32
	graphics_exposures : UInt32
	clip_originX : UInt32
	clip_originY : UInt32
	mask : UInt32
	dash_offset : UInt32
	dash_list : UInt32
	arc_mode : UInt32
end

fun xcb_aux_create_gc (x0 : Pointer(xcb_connection_t), x1 : xcb_gcontext_t, x2 : xcb_drawable_t, x3 : UInt32, x4 : Pointer(xcb_params_gc_t)) : xcb_void_cookie_t

fun xcb_aux_create_gc_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_gcontext_t, x2 : xcb_drawable_t, x3 : UInt32, x4 : Pointer(xcb_params_gc_t)) : xcb_void_cookie_t

fun xcb_aux_change_gc(x0 : Pointer(xcb_connection_t), x1 : xcb_gcontext_t, x2 : UInt32, x3 : Pointer(xcb_params_gc_t)) : xcb_void_cookie_t


fun xcb_aux_change_gc_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_gcontext_t, x2 : UInt32, x3 : Pointer(xcb_params_gc_t)) : xcb_void_cookie_t

struct xcb_params_keyboard_t
	key_click_percent : UInt32
	bell_percent : UInt32
	bell_pitch : UInt32
	bell_duration : UInt32
	led : UInt32
	led_mode : UInt32
	key : UInt32
	auto_repeat_mode : UInt32
end

fun xcb_aux_change_keyboard_control(x0 Pointer(xcb_connection_t), x1 : UInt32, x2 : Pointer(xcb_params_keyboard_t)) : xcb_void_cookie_t

fun xcb_aux_parse_color(x0 : Pointer(Char), x1 : Pointer(UInt16), x2 : Pointer(UInt16), x3 : Pointer(UInt16)) : Int32

fun xcb_aux_set_line_attributes_checked (x0 : Pointer(xcb_connection_t), x1 : xcb_gcontext_t, x2 : UInt16, x3 : Int32, x4 : Int32, x5 : Int32) : xcb_void_cookie_t

fun xcb_aux_clear_window(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t): xcb_void_cookie_t
