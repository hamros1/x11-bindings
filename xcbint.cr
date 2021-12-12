lib LibXCB
	WORKAROUND_NONE = 0
	WORKAROUND_GLX_GET_FB_CONFIGS_BUG = 1
	WORKAROUND_EXTERNAL_SOCKET_OWNER = 2

	LAZY_NONE = 0
	LAZY_COOKIE = 1
	LAZY_FORCED = 2

	alias xcb_list_free_func_t = Pointer(Void) -> NoReturn

	alias _xcb_map = _xcb_map

	fun _xcb_map_new(x0 : Void) : Pointer(_xcb_map)
	fun _xcb_map_delete(x0 : _xcb_map, x1 : xcb_list_free_func_t): Void 
	fun _xcb_map_put(x0 : _xcb_map, x1 Int32, Pointer(Void)): Int32 
	fun _xcb_map_remove(x0 : Pointer(_xcb_map), x1 : Int32): Pointer(Void)

	struct _xcb_fd
		fd : StaticArray(Int32, XCB_MAX_PASS_FD)
		nfd : Int32 
		ifd : Int32 
	end

	struct _xcb_out 
		cond : pthread_cond_t
		writing : Int32 

		socket_cond : pthread_cond_t 
		close : (Pointer(Void) -> Pointer(return_socket)
		socket_closure : Pointer(Void)
		socket_moving : Int32

		queue : StaticArray(Char, XCB_QUEUE_BUFFER_SIZE)
		queue_len : Int32 

		request : UInt64 
		request_written : UInt64 

		reqlenlock : pthread_mutex_t 
		maximum_request_length_tag : lazy_reply_tag 
		maximum_request_length : { lazy_reply_tag cookie : xcb_big_requests_enable_cookie_t, value : UInt32 }
	end

	fun _xcb_out_init(x0 : Pointer(_xcb_out)): Int32 
	fun _xcb_out_destroy(x0 : Pointer(_xcb_out)): Void 

	fun _xcb_out_send(x0 : Pointer(xcb_connection_t), x1 : Pointer(iovec), x2 : Int32) : Int32 
	fun _xcb_out_send_sync(x0 : Pointer(xcb_connection_t)) : Void 
	fun _xcb_out_flush_to(x0 : Pointer(xcb_connection_t), x1 : UInt64) : Int32 

	struct _xcb_in
		event_cond : pthread_cond_t 
		reading : Int32 

		queue : StaticArray(Char, 4096)
		queue_len : Int32 

		request_expected : UInt64
		request_read : UInt64
		request_completed : UInt64
		current_reply : Pointer(reply_list)
		current_reply_tail : Pointer(Pointer(reply_list))

		replies : Pointer(_xcb_map)
		events : Pointer(event_list)
		events_tail : Pointer(Pointer(event_list))
		readers : Pointer(reader_list)
		special_waiters : Pointer(special_list)

		pending_replies : Pointer(pending_reply)
		pending_replies_tail : Pointer(Pointer(pending_reply))

		special_events : Pointer(xcb_special_event)
	end

	fun _xcb_in_init(x0 : Pointer(_xcb_in)): Int32 
	fun _xcb_in_destroy(x0 : Pointer(_xcb_in)): Void 

	fun _xcb_in_wake_up_next_reader(x0 : Pointer(xcb_connection_t)): Void 

	fun _xcb_in_expect_reply(x0 : xcb_connection_t, x1 : UInt64, x2 : workarounds, x3 : Int32): Int32 
	fun _xcb_in_replies_done(x0 : xcb_connection_t): Void 

	fun _xcb_in_read(x0 : xcb_connection_t): Int32 
	fun _xcb_in_read_block(x0 : Pointer(xcb_connection_t), x1 : Void, x2 : Int32): Int32 

	struct _xcb_xid
		lock : pthread_mutex_t 
		last : UInt32 
		base : UInt32 
		max : UInt32 
		inc : UInt32 
	end

	fun _xcb_xid_init(x0 : Pointer(xcb_connection_t)): Int32 
	fun _xcb_xid_destroy(x0 : Pointer(xcb_connection_t)): Void 

	struct _xcb_ext
		lock : pthread_mutex_t 
		extensions : Pointer(lazyreply)
		extensions_size : Int32 
	end

	fun _xcb_ext_init(x0 : Pointer(xcb_connection_t)): Int32 
	fun _xcb_ext_destroy(x0 : Pointer(xcb_connection_t)): Void 

	struct xcb_connection_t
		has_error : Int32 

		setup : xcb_setup_t 
		fd : Int32 

		iolock : pthread_mutex_t 
	in : _xcb_in 
	out : _xcb_out 

	ext : _xcb_ext 
	xid : _xcb_xid 
	end

	fun _xcb_conn_shutdown(x0 : Pointer(xcb_connection_t), x1 : Int32): Void 

	fun _xcb_conn_ret_error(x0 : Int32 err): Pointer(xcb_connection_t)

	fun _xcb_conn_wait(x0 : Pointer(xcb_connection_t), Pointer(pthread_cond_t), Pointer(Ponter(iovec)), Pointer(Int32)) : Int32 

	fun _xcb_get_auth_info(x0 : Int32, x1 : Pointer(xcb_auth_info_t), x2 : Int32): Int32 
end
