struct xcb_extension_t
	name : Char*
	global_id : Int32
end

struct xcb_protocol_request_t
	count : LibC::SizeT
	ext : Pointer(xcb_extension_t)
	opcode : UInt8
	isvoid : UInt8
end

XCB_REQUEST_CHECKED = (1 << 0)
XCB_REQUEST_RAW = (1 << 1)
XCB_REQUEST_DISCARD_REPLY = (1 << 2)
XCB_REQUEST_REPLY_FDS = (1 << 3)

xcb_send_request(x0 : xcb_connection_t, x1 : Int32, x2 : iovec *, x3 : Pointer(xcb_protocol_request_t)) : Int32 

xcb_send_request_with_fds(x0 : Pointer(xcb_connection_t), x1 : Int32, x2 : Pointer(iovec), x3 : Pointer(xcb_protocol_request_t), x4 : Int32, x5 : Pointer(Int32)) : Int32 

xcb_send_request64(x0 : Pointer(xcb_connection_t), x1 : Int32, x2 : Pointer(iovec), x3 : Pointer(xcb_protocol_request_t)) : UInt64 

xcb_send_request_with_fds64(x0 : Pointer(xcb_connection_t), x1 : Int32, x2 : iovec *vector, x3 : xcb_protocol_request_t *, x4 : Int32 , x5 : Int32) : UInt64 

xcb_send_fd(x0 : Pointer(xcb_connection_t), x1 : Int32) : Void

fun xcb_take_socket(x0 : Pointer(xcb_connection_t), x1 : Pointer(Void) -> Pointer(return_socket), x2 : Pointer(Void), x3 : Int32, x4 : Pointer(UInt64)) : Int32 

fun xcb_writev(x0 : Pointer(xcb_connection_t), x1 : Pointer(iovec), x2 : Int32, x3 : UInt64) : Int32 

fun xcb_wait_for_reply(x0 : Pointer(xcb_connection_t), x1 : Int32, x2 : Pointer(Pointer(xcb_generic_error_t))) : Void*

fun xcb_wait_for_reply64(x0 : Pointer(xcb_connection_t), x1 : UInt64, x2 : Pointer(Pointer(xcb_generic_error_t))) : Void

fun xcb_poll_for_reply(x0 : Pointer(xcb_connection_t), x1 : Int32, x2 : Pointer(Pointer(Void)), x3 : Pointer(Pointer(xcb_generic_error_t))) : Int32 

fun xcb_poll_for_reply64(x0 : Pointer(xcb_connection_t), x1 : UInt64, x2 : Pointer(Pointer(Void)), x3 : Pointer(Pointer(xcb_generic_error_t))) : Int32 

fun xcb_get_reply_fds(x0 : Pointer(xcb_connection_t), x1 : Pointer(Void), x2 : LibC::SizeT) : Pointer(Int32)

fun xcb_popcount(x0 : UInt32) : Int32 

fun xcb_sumof(x0 : Pointer(UInt8), x1 : Int32) : Int32 
