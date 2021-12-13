@[Link("XCB")
lib LibXCB
	X_PROTOCOL 11

	X_PROTOCOL_REVISION 0

	X_TCP_PORT 6000

	XCB_CONN_ERROR 1

	XCB_CONN_CLOSED_EXT_NOTSUPPORTED 2

	XCB_CONN_CLOSED_MEM_INSUFFICIENT 3

	XCB_CONN_CLOSED_REQ_LEN_EXCEED 4

	XCB_CONN_CLOSED_PARSE_ERR 5

	XCB_CONN_CLOSED_INVALID_SCREEN 6

	XCB_CONN_CLOSED_FDPASSING_FAILED 7

	alias xcb_connection_t = xcb_connection_t

	struct xcb_generic_iterator_t{
		data : Pointer(Void)
		rem : Int32 
		index : Int32 
	end

	struct xcb_generic_reply_t
		response_type : UInt8 
		pad0 : UInt8 
		sequence : UInt16 
		length : UInt32 
	end

	struct xcb_generic_event_t
		response_type : UInt8   
		pad0 : UInt8  
		sequence : UInt16 
		pad[7] : UInt32 
		full_sequence : UInt32 
	end

	struct xcb_raw_generic_event_t
		response_type : UInt8   
		pad0 : UInt8  
		sequence : UInt16 
		pad[7] : UInt32 
	end

	struct xcb_ge_event_t
		response_type : UInt8  
		pad0 : UInt8  
		sequence : UInt16 
		length : UInt32 
		event_type : UInt16 
		pad1 : UInt16 
		pad[5] : StaticArray(UInt32, 5)
		full_sequence :  UInt32 
	end

	struct xcb_generic_error_t
		response_type : UInt8   
		error_code : UInt8   
		sequence : UInt16 
		resource_id : UInt32 
		minor_code : UInt16 
		major_code : UInt8 
		pad0 : UInt8 
		pad[5] : UInt32 
		full_sequence : UInt32 
	end 

	struct xcb_Void_cookie_t
		sequence : UInt32
	end

	XCB_NONE = 0L

	XCB_COPY_FROM_PARENT = 0L

	XCB_CURRENT_TIME = 0L

	XCB_NO_SYMBOL = 0L

	struct xcb_auth_info_t
		namelen : Int32   
		name : Pointer(Char)
		datalen : Int32  
		data : Pointer(Char)
	end

	fun xcb_flush(x0 : xcb_connection_t) : Int32 

	fun xcb_get_maximum_request_length(x0 : xcb_connection_t) : UInt32 

	fun xcb_prefetch_maximum_request_length(x0 : xcb_connection_t) : Void 

	fun xcb_wait_for_event(x0 : xcb_connection_t) : Pointer(xcb_generic_event_t)

	fun xcb_poll_for_event(x0 : xcb_connection_t) : Pointer(xcb_generic_event_t)

	fun xcb_poll_for_queued_event(x0 : xcb_connection_t) : Pointer(xcb_generic_event_t)

	alias xcb_special_event_t = xcb_special_event 

	fun xcb_poll_for_special_event(x0 : Pointer(xcb_connection_t), x1 : Pointer(xcb_special_event_t)) : Pointer(xcb_generic_event_t)

	fun xcb_wait_for_special_event(x0 : xcb_connection_t, x1 : xcb_special_event_t) : Pointer(xcb_generic_event_t)

	alias xcb_extension_t =  xcb_extension_t 

	fun xcb_register_for_special_xge(x0 : Pointer(xcb_connection_t), x1 : Pointer(xcb_extension_t), x2 : UInt32, x3 : Pointer(UInt32)): Pointer(xcb_special_event_t)

	fun xcb_unregister_for_special_event(x0 : xcb_connection_t, x1 : xcb_special_event_t): Void 

	fun xcb_request_check(x0 : Pointer(xcb_connection_t), x1 : Pointer(xcb_Void_cookie_t)): Pointer(xcb_generic_error_t)

	fun xcb_discard_reply(x0 : xcb_connection_t, x1 : Int32) : Void 

	fun xcb_discard_reply64(x0, x1) : Void 

	fun xcb_get_extension_data(Pointer(xcb_connection_t), Pointer(xcb_extension_t)) :  xcb_query_extension_reply_t 

	fun xcb_prefetch_extension_data(x0 : Pointer(xcb_connection_t), x1 : Pointer(xcb_extension_t)) : Void 

	fun xcb_get_setup(Pointer(xcb_connection_t)) : x_setup_t

	fun xcb_get_file_descriptor(x0 : Pointer(xcb_connection_t)) : Int32 

	fun xcb_connection_has_error(Pointer(xcb_connection_t)) : Int32 

	fun xcb_connect_to_fd(x0 : Int32, x1 : Pointer(xcb_auth_info_t)) : Pointer(xcb_connection_t)

	fun xcb_disconnect(x0 : Pointer(xcb_connection_t)): Void 

	fun xcb_parse_display(x0 : Pointer(Char), x1 : Pointer(Pointer(Char)), x2 : Pointer(Int32), x3 : Pointer(Int32)) : Int32 

	fun xcb_connect(x0 : Pointer(Char), x1 : Pointer(Int32)): Pointer(xcb_connection_t)

	fun xcb_connect_to_display_with_auth_info(x0 : Pointer(Char*), Pointer(xcb_auth_info_t), Pointer(Int32)) : Pointer(xcb_connection_t)

	fun xcb_generate_id(Pointer(xcb_connection_t)) : UInt32 
end
