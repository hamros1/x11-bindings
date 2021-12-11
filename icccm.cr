struct xcb_get_text_property_reply_t
	_reply : Pointer(xcb_get_property_reply_t)
	encoding : xcb_atom_t 
	name_len : UInt32 
	name : Char*
	format : UInt8 
end

fun xcb_get_text_property(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t): xcb_get_property_cookie_t 

fun xcb_get_text_property_unchecked(Pointer(xcb_connection_t), xcb_window_t, xcb_atom_t) : xcb_get_property_cookie_t 

fun xcb_get_text_property_reply(x0 : Pointer(xcb_connection_t), x1 : xcb_get_property_cookie_t, x3 : Pointer(xcb_get_text_property_reply_t), x4 : Pointer(Pointer(xcb_generic_error_t))) : UInt8 

fun xcb_get_text_property_reply_wipe(Pointer(xcb_get_text_property_reply_t)) : Void 

fun xcb_set_wm_name_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t, x3 : UInt32, x4 : Char*) : Void

fun xcb_set_wm_name(x0 : xcb_connection_t, x1 : xcb_window_t, x2 : xcb_atom_t, x3 : UInt32, x4 : Char*) : Void 

fun xcb_get_wm_name(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t): xcb_get_property_cookie_t 

fun xcb_get_wm_name_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_name_reply(Pointer(xcb_connection_t), xcb_get_property_cookie_t, Pointer(xcb_get_text_property_reply_t), Pointer(Pointer(xcb_generic_error_t))) : UInt8 

fun xcb_watch_wm_name(x0 : Pointer(xcb_property_handlers_t), x1 : UInt32, x2 : xcb_generic_property_handler_t, x3 : Pointer(Void)) : Void 

fun xcb_set_wm_icon_name_checked(x0 : xcb_connection_t *c, x1 : xcb_window_t, x2 : xcb_atom_t, x3 : UInt32, x4 : Char*) : Void 

fun xcb_set_wm_icon_name(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t, x3 : UInt32, x4 : Char*) : Void

fun xcb_get_wm_icon_name(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_icon_name_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_icon_name_reply(x0 : Pointer(xcb_connection_t), x1 : xcb_get_property_cookie_t, x2 : Pointer(xcb_get_text_property_reply_t), Pointer(Pointer(xcb_generic_error_t))): UInt8 

fun xcb_watch_wm_icon_name(x0 : Pointer(xcb_property_handlers_t), x1 : UInt32, x2 : xcb_generic_property_handler_t, x3 : Pointer(Void)): Void 

fun xcb_set_wm_client_machine_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t, x3 : UInt32, x4 : Char*) : Void 

fun xcb_set_wm_client_machine(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t, x3 : UInt32, x4 : Char*) : Void 

fun xcb_get_wm_client_machine(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_client_machine_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_client_machine_reply(Pointer(xcb_connection_t), xcb_get_property_cookie_t, Pointer(xcb_get_text_property_reply_t), Pointer(Pointer(xcb_generic_error_t))) : UInt8 

fun xcb_watch_wm_client_machine(x0 : Pointer(xcb_property_handlers_t), x1 : UInt32, x2 : xcb_generic_property_handler_t, x3 : Pointer(Void)) : Void 

struct xcb_get_wm_class_reply_t
	instance_name : Pointer(Char)
	class_name : Pointer(Char)
	_reply : Pointer(xcb_get_property_reply_t)
end

fun xcb_get_wm_class(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_class_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t): xcb_get_property_cookie_t 

fun xcb_get_wm_class_from_reply(x0 : Pointer(xcb_get_wm_class_reply_t, x1 : Pointer(xcb_get_property_reply_t))) : UInt8 

fun xcb_get_wm_class_reply(x0 : xcb_connection_t, x1 : xcb_get_property_cookie_t, Pointer(xcb_get_wm_class_reply_t), Pointer(Pointer(xcb_generic_error_t))) : UInt8 


fun xcb_get_wm_class_reply_wipe(Pointer(xcb_get_wm_class_reply_t)) : Void 

fun xcb_get_wm_transient_for(Pointer(xcb_connection_t), xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_transient_for_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_transient_for_from_reply(Pointer(xcb_window_t), Pointer(xcb_get_property_reply_t)) : UInt8 

fun xcb_get_wm_transient_for_reply(Pointer(xcb_connection_t), xcb_get_property_cookie_t, Pointer(xcb_window_t), Pointer(Pointer(xcb_generic_error_t))) : UInt8 

XCB_SIZE_HINT_US_POSITION = 1 << 0
XCB_SIZE_HINT_US_SIZE = 1 << 1
XCB_SIZE_HINT_P_POSITION = 1 << 2
XCB_SIZE_HINT_P_SIZE = 1 << 3
XCB_SIZE_HINT_P_MIN_SIZE = 1 << 4
XCB_SIZE_HINT_P_MAX_SIZE = 1 << 5
XCB_SIZE_HINT_P_RESIZE_INC = 1 << 6
XCB_SIZE_HINT_P_ASPECT = 1 << 7
XCB_SIZE_HINT_BASE_SIZE = 1 << 8
XCB_SIZE_HINT_P_WIN_GRAVITY = 1 << 9

struct xcb_size_hints_t{
	flags : UInt32 
	x, y : Int32 
	width, height : Int32 
	min_width, min_height : Int32 
	max_width, max_height : Int32 
	width_inc, height_inc : Int32 
	min_aspect_num, min_aspect_den : Int32 
	max_aspect_num, max_aspect_den : Int32 
	base_width, base_height : Int32 
	win_gravity : UInt32 
end

fun xcb_size_hints_set_position(x0 : Pointer(xcb_size_hints_t), x1 : Int32,
																x2 : Int32, x3 : Int32) : Void 

fun xcb_size_hints_set_size(x0 : Pointer(xcb_size_hints_t), x1 : Int32, x2 : Int32, x3 : Int32): Void 

fun xcb_size_hints_set_min_size(x0 : Pointer(xcb_size_hints_t), x1 : Int32, x2 : Int32): Void 

fun xcb_size_hints_set_max_size(x0 : Pointer(xcb_size_hints_t), x1 : Int32, x2 : Int32) : Void 

fun xcb_size_hints_set_resize_inc(Pointer(xcb_size_hints_t), Int32, Int32) : Void 

fun xcb_size_hints_set_aspect(x0 : Pointer(xcb_size_hints_t), x1 : Int32, x2 : Int32, x3 : Int32, Int32) : Void 

fun xcb_size_hints_set_base_size(x0 : xcb_size_hints_t, x1 : Int32, x2 : Int32): Void 

fun xcb_size_hints_set_win_gravity(x0 : Pointer(xcb_size_hints_t), x1 : UInt32): Void 

fun xcb_set_wm_size_hints_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t, x3 : Pointer(xcb_size_hints_t)): Void 

fun xcb_set_wm_size_hints(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t, x3 : Pointer(xcb_size_hints_t)) : Void 

fun xcb_get_wm_size_hints(x0 Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_size_hints_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_size_hints_reply(x0 : Pointer(xcb_connection_t), x1 : xcb_get_property_cookie_t, x2 : Pointer(xcb_size_hints_t), x3 : Pointer(Pointer(xcb_generic_error_t))) : UInt8 

fun xcb_set_wm_normal_hints_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t , x2 : Pointer(xcb_size_hints_t)): Void 
fun xcb_set_wm_normal_hints(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t , x2 : xcb_size_hints_t) : Void 

fun xcb_get_wm_normal_hints(x0 : Pointer(xcb_connection_t, x1 : xcb_window_t)) : xcb_get_property_cookie_t 

fun xcb_get_wm_normal_hints_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_size_hints_from_reply(x0 : Pointer(xcb_size_hints_t), x1 : Pointer(xcb_get_property_reply_t)) : UInt8

fun xcb_get_wm_normal_hints_reply(x0 : Pointer(xcb_connection_t), x1 : Pointer(xcb_get_property_cookie_t), x2 : Pointer(xcb_size_hints_t), x3 : Pointer(Pointer(xcb_generic_error_t))) : UInt8 

struct xcb_wm_hints_t
	flags : Int32 
	input : UInt32 
	initial_state : Int32 
	icon_pixmap : xcb_pixmap_t 
	icon_window : xcb_window_t 
	icon_x, icon_y : Int32 
	icon_mask : xcb_pixmap_t 
	window_group : xcb_window_t 
end

XCB_NUM_WM_HINTS_ELEMENTS 9

XCB_WM_STATE_WITHDRAWN = 0
XCB_WM_STATE_NORMAL = 1
XCB_WM_STATE_ICONIC = 3

XCB_WM_HINT_INPUT = (1L << 0)
XCB_WM_HINT_STATE = (1L << 1)
XCB_WM_HINT_ICON_PIXMAP = (1L << 2)
XCB_WM_HINT_ICON_WINDOW = (1L << 3)
XCB_WM_HINT_ICON_POSITION = (1L << 4)
XCB_WM_HINT_ICON_MASK = (1L << 5)
XCB_WM_HINT_WINDOW_GROUP = (1L << 6)
XCB_WM_HINT_X_URGENCY = (1L << 8)

XCB_WM_ALL_HINTS = (XCB_WM_HINT_INPUT | XCB_WM_HINT_STATE |\
										XCB_WM_HINT_ICON_PIXMAP | XCB_WM_HINT_ICON_WINDOW |\
										XCB_WM_HINT_ICON_POSITION | XCB_WM_HINT_ICON_MASK |\
										XCB_WM_HINT_WINDOW_GROUP)

fun xcb_wm_hints_get_urgency(x0 : Pointer(xcb_wm_hints_t)) : UInt32 

fun xcb_wm_hints_set_input(x0 : Pointer(xcb_wm_hints_t), x1 : UInt8) : Void 

fun xcb_wm_hints_set_iconic(x0 : Pointer(xcb_wm_hints_t)) : Void 

fun xcb_wm_hints_set_normal(x0 : Pointer(xcb_wm_hints_t)) : Void 

fun xcb_wm_hints_set_withdrawn(x0 : Pointer(xcb_wm_hints_t)) : Void 

fun xcb_wm_hints_set_none(x0 : Pointer(xcb_wm_hints_t)) : Void 

fun xcb_wm_hints_set_icon_pixmap(x0 : Pointer(xcb_wm_hints_t), x1 : xcb_pixmap_t) : Void

fun xcb_wm_hints_set_icon_mask(x0 : Pointer(xcb_wm_hints_t), x1 : xcb_pixmap_t) : Void 

fun xcb_wm_hints_set_icon_window(x0 : Pointer(xcb_wm_hints_t), x1 : xcb_window_t) : Void 

fun xcb_wm_hints_set_window_group(x0 : Pointer(xcb_wm_hints_t), x1 : xcb_window_t) : Void 

fun xcb_wm_hints_set_urgency(x0 : Pointer(xcb_wm_hints_t)) : Void 

fun xcb_set_wm_hints_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : Pointer(xcb_wm_hints_t)) : Void 

fun xcb_set_wm_hints(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t , x2 : Pointer(xcb_wm_hints_t)) : Void 

fun xcb_get_wm_hints(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_hints_unchecked(Pointer(xcb_connection_t), xcb_window_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_hints_from_reply(x0 : Pointer(xcb_wm_hints_t), x1 : Pointer(xcb_get_property_reply_t)) : UInt8 

fun xcb_get_wm_hints_reply(x0 : Pointer(xcb_connection_t), x1 : xcb_get_property_cookie_t, x2 : Pointer(xcb_wm_hints_t), x3 : Pointer(Pointer(xcb_generic_error_t))) : UInt8 

fun xcb_set_wm_protocols_checked(x0 : Pointer(xcb_connection_t), x1 : xcb_atom_t, x2 : xcb_window_t, x3 : UInt32, x4 : Pointer(xcb_atom_t))) : Void 

fun xcb_set_wm_protocols(x0 : Pointer(xcb_connection_t), x1 : xcb_atom_t, x2 : xcb_window_t, x3 : UInt32, x4 : Pointer(xcb_atom_t)) : Void 

struct xcb_get_wm_protocols_reply_t
	atoms_len : UInt32 
	atoms : Pointer(xcb_atom_t)
	_reply : Pointer(xcb_get_property_reply_t)
end

fun xcb_get_wm_protocols(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_protocols_unchecked(x0 : Pointer(xcb_connection_t), x1 : xcb_window_t, x2 : xcb_atom_t) : xcb_get_property_cookie_t 

fun xcb_get_wm_protocols_reply(Pointer(xcb_connection_t), xcb_get_property_cookie_t, Pointer(xcb_get_wm_protocols_reply_t), Pointer(Pointer(xcb_generic_error_t))) : UInt8 

fun xcb_get_wm_protocols_reply_wipe(Pointer(xcb_get_wm_protocols_reply_t)) : Void 
