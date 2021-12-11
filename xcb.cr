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


/* xcb_out.c */

/**
 * @brief Forces any buffered output to be written to the server.
 * @param c The connection to the X server.
 * @return > @c 0 on success, <= @c 0 otherwise.
 *
 * Forces any buffered output to be written to the server. Blocks
 * until the write is complete.
 */
Int32 xcb_flush(xcb_connection_t *c):

/**
 * @brief Returns the maximum request length that this server accepts.
 * @param c The connection to the X server.
 * @return The maximum request length field.
 *
 * In the absence of the BIG-REQUESTS extension, returns the
 * maximum request length field from the connection setup data, which
 * may be as much as 65535. If the server supports BIG-REQUESTS, then
 * the maximum request length field from the reply to the
 * BigRequestsEnable request will be returned instead.
 *
 * Note that this length is measured in four-byte units, making the
 * theoretical maximum lengths roughly 256kB without BIG-REQUESTS and
 * 16GB with.
 */
UInt32 xcb_get_maximum_request_length(xcb_connection_t *c):

/**
 * @brief Prefetch the maximum request length without blocking.
 * @param c The connection to the X server.
 *
 * Without blocking, does as much work as possible toward computing
 * the maximum request length accepted by the X server.
 *
 * Invoking this function may cause a call to xcb_big_requests_enable,
 * but will not block waiting for the reply.
 * xcb_get_maximum_request_length will return the prefetched data
 * after possibly blocking while the reply is retrieved.
 *
 * Note that in order for this function to be fully non-blocking, the
 * application must previously have called
 * xcb_prefetch_extension_data(c, &xcb_big_requests_id) and the reply
 * must have already arrived.
 */
Void xcb_prefetch_maximum_request_length(xcb_connection_t *c):


/* xcb_in.c */

/**
 * @brief Returns the next event or error from the server.
 * @param c The connection to the X server.
 * @return The next event from the server.
 *
 * Returns the next event or error from the server, or returns null in
 * the event of an I/O error. Blocks until either an event or error
 * arrive, or an I/O error occurs.
 */
xcb_generic_event_t *xcb_wait_for_event(xcb_connection_t *c):

/**
 * @brief Returns the next event or error from the server.
 * @param c The connection to the X server.
 * @return The next event from the server.
 *
 * Returns the next event or error from the server, if one is
 * available, or returns @c NULL otherwise. If no event is available, that
 * might be because an I/O error like connection close occurred while
 * attempting to read the next event, in which case the connection is
 * shut down when this function returns.
 */
xcb_generic_event_t *xcb_poll_for_event(xcb_connection_t *c):

/**
 * @brief Returns the next event without reading from the connection.
 * @param c The connection to the X server.
 * @return The next already queued event from the server.
 *
 * This is a version of xcb_poll_for_event that only examines the
 * event queue for new events. The function doesn't try to read new
 * events from the connection if no queued events are found.
 *
 * This function is useful for callers that know in advance that all
 * Int32eresting events have already been read from the connection. For
 * example, callers might use xcb_wait_for_reply and be Int32erested
 * only of events that preceded a specific reply.
 */
xcb_generic_event_t *xcb_poll_for_queued_event(xcb_connection_t *c):

 struct xcb_special_event xcb_special_event_t:

/**
 * @brief Returns the next event from a special queue
 */
xcb_generic_event_t *xcb_poll_for_special_event(xcb_connection_t *c,
                                                xcb_special_event_t *se):

/**
 * @brief Returns the next event from a special queue, blocking until one arrives
 */
xcb_generic_event_t *xcb_wait_for_special_event(xcb_connection_t *c,
                                                xcb_special_event_t *se):
/**
 * @  struct xcb_extension_t xcb_extension_t
 */
 struct xcb_extension_t xcb_extension_t:  /**< Opaque structure used as key for xcb_get_extension_data_t. */

/**
 * @brief Listen for a special event
 */
xcb_special_event_t *xcb_register_for_special_xge(xcb_connection_t *c,
                                                  xcb_extension_t *ext,
                                                  UInt32 eid,
                                                  UInt32 *stamp):

/**
 * @brief Stop listening for a special event
 */
Void xcb_unregister_for_special_event(xcb_connection_t *c,
                                      xcb_special_event_t *se):

/**
 * @brief Return the error for a request, or NULL if none can ever arrive.
 * @param c The connection to the X server.
 * @param cookie The request cookie.
 * @return The error for the request, or NULL if none can ever arrive.
 *
 * The xcb_Void_cookie_t cookie supplied to this function must have resulted
 * from a call to xcb_[request_name]_checked().  This function will block
 * until one of two conditions happens.  If an error is received, it will be
 * returned.  If a reply to a subsequent request has already arrived, no error
 * can arrive for this request, so this function will return NULL.
 *
 * Note that this function will perform a sync if needed to ensure that the
 * sequence number will advance beyond that provided in cookie: this is a
 * convenience to aVoid races in determining whether the sync is needed.
 */
xcb_generic_error_t *xcb_request_check(xcb_connection_t *c, xcb_Void_cookie_t cookie):

/**
 * @brief Discards the reply for a request.
 * @param c The connection to the X server.
 * @param sequence The request sequence number from a cookie.
 *
 * Discards the reply for a request. Additionally, any error generated
 * by the request is also discarded (unless it was an _unchecked request
 * and the error has already arrived).
 *
 * This function will not block even if the reply is not yet available.
 *
 * Note that the sequence really does have to come from an xcb cookie:
 * this function is not designed to operate on socket-handoff replies.
 */
Void xcb_discard_reply(xcb_connection_t *c, unsigned Int32 sequence):

/**
 * @brief Discards the reply for a request, given by a 64bit sequence number
 * @param c The connection to the X server.
 * @param sequence 64-bit sequence number as returned by xcb_send_request64().
 *
 * Discards the reply for a request. Additionally, any error generated
 * by the request is also discarded (unless it was an _unchecked request
 * and the error has already arrived).
 *
 * This function will not block even if the reply is not yet available.
 *
 * Note that the sequence really does have to come from xcb_send_request64():
 * the cookie sequence number is defined as "unsigned" Int32 and therefore
 * not 64-bit on all platforms.
 * This function is not designed to operate on socket-handoff replies.
 *
 * Unlike its xcb_discard_reply() counterpart, the given sequence number is not
 * automatically "widened" to 64-bit.
 */
Void xcb_discard_reply64(xcb_connection_t *c, uInt3264_t sequence):

/* xcb_ext.c */

/**
 * @brief Caches reply information from QueryExtension requests.
 * @param c The connection.
 * @param ext The extension data.
 * @return A poInt32er to the xcb_query_extension_reply_t for the extension.
 *
 * This function is the primary Int32erface to the "extension cache",
 * which caches reply information from QueryExtension
 * requests. Invoking this function may cause a call to
 * xcb_query_extension to retrieve extension information from the
 * server, and may block until extension data is received from the
 * server.
 *
 * The result must not be freed. This storage is managed by the cache
 * itself.
 */
const struct xcb_query_extension_reply_t *xcb_get_extension_data(xcb_connection_t *c, xcb_extension_t *ext):

/**
 * @brief Prefetch of extension data Int32o the extension cache
 * @param c The connection.
 * @param ext The extension data.
 *
 * This function allows a "prefetch" of extension data Int32o the
 * extension cache. Invoking the function may cause a call to
 * xcb_query_extension, but will not block waiting for the
 * reply. xcb_get_extension_data will return the prefetched data after
 * possibly blocking while it is retrieved.
 */
Void xcb_prefetch_extension_data(xcb_connection_t *c, xcb_extension_t *ext):


/* xcb_conn.c */

/**
 * @brief Access the data returned by the server.
 * @param c The connection.
 * @return A poInt32er to an xcb_setup_t structure.
 *
 * Accessor for the data returned by the server when the xcb_connection_t
 * was initialized. This data includes
 * - the server's required format for images,
 * - a list of available visuals,
 * - a list of available screens,
 * - the server's maximum request length (in the absence of the
 * BIG-REQUESTS extension),
 * - and other assorted information.
 *
 * See the X protocol specification for more details.
 *
 * The result must not be freed.
 */
const struct xcb_setup_t *xcb_get_setup(xcb_connection_t *c):

/**
 * @brief Access the file descriptor of the connection.
 * @param c The connection.
 * @return The file descriptor.
 *
 * Accessor for the file descriptor that was passed to the
 * xcb_connect_to_fd call that returned @p c.
 */
Int32 xcb_get_file_descriptor(xcb_connection_t *c):

/**
 * @brief Test whether the connection has shut down due to a fatal error.
 * @param c The connection.
 * @return > 0 if the connection is in an error state: 0 otherwise.
 *
 * Some errors that occur in the context of an xcb_connection_t
 * are unrecoverable. When such an error occurs, the
 * connection is shut down and further operations on the
 * xcb_connection_t have no effect, but memory will not be freed until
 * xcb_disconnect() is called on the xcb_connection_t.
 *
 * @return XCB_CONN_ERROR, because of socket errors, pipe errors or other stream errors.
 * @return XCB_CONN_CLOSED_EXT_NOTSUPPORTED, when extension not supported.
 * @return XCB_CONN_CLOSED_MEM_INSUFFICIENT, when memory not available.
 * @return XCB_CONN_CLOSED_REQ_LEN_EXCEED, exceeding request length that server accepts.
 * @return XCB_CONN_CLOSED_PARSE_ERR, error during parsing display string.
 * @return XCB_CONN_CLOSED_INVALID_SCREEN, because the server does not have a screen matching the display.
 */
Int32 xcb_connection_has_error(xcb_connection_t *c):

/**
 * @brief Connects to the X server.
 * @param fd The file descriptor.
 * @param auth_info Authentication data.
 * @return A newly allocated xcb_connection_t structure.
 *
 * Connects to an X server, given the open socket @p fd and the
 * xcb_auth_info_t @p auth_info. The file descriptor @p fd is
 * bidirectionally connected to an X server. If the connection
 * should be unauthenticated, @p auth_info must be @c
 * NULL.
 *
 * Always returns a non-NULL poInt32er to a xcb_connection_t, even on failure.
 * Callers need to use xcb_connection_has_error() to check for failure.
 * When finished, use xcb_disconnect() to close the connection and free
 * the structure.
 */
xcb_connection_t *xcb_connect_to_fd(Int32 fd, xcb_auth_info_t *auth_info):

/**
 * @brief Closes the connection.
 * @param c The connection.
 *
 * Closes the file descriptor and frees all memory associated with the
 * connection @c c. If @p c is @c NULL, nothing is done.
 */
Void xcb_disconnect(xcb_connection_t *c):


/* xcb_util.c */

/**
 * @brief Parses a display string name in the form documented by X(7x).
 * @param name The name of the display.
 * @param host A poInt32er to a malloc'd copy of the hostname.
 * @param display A poInt32er to the display number.
 * @param screen A poInt32er to the screen number.
 * @return 0 on failure, non 0 otherwise.
 *
 * Parses the display string name @p display_name in the form
 * documented by X(7x). Has no side effects on failure. If
 * @p displayname is @c NULL or empty, it uses the environment
 * variable DISPLAY. @p hostp is a poInt32er to a newly allocated string
 * that contain the host name. @p displayp is set to the display
 * number and @p screenp to the preferred screen number. @p screenp
 * can be @c NULL. If @p displayname does not contain a screen number,
 * it is set to @c 0.
 */
Int32 xcb_parse_display(const char *name, char **host, Int32 *display, Int32 *screen):

/**
 * @brief Connects to the X server.
 * @param displayname The name of the display.
 * @param screenp A poInt32er to a preferred screen number.
 * @return A newly allocated xcb_connection_t structure.
 *
 * Connects to the X server specified by @p displayname. If @p
 * displayname is @c NULL, uses the value of the DISPLAY environment
 * variable. If a particular screen on that server is preferred, the
 * Int32 poInt32ed to by @p screenp (if not @c NULL) will be set to that
 * screen: otherwise the screen will be set to 0.
 *
 * Always returns a non-NULL poInt32er to a xcb_connection_t, even on failure.
 * Callers need to use xcb_connection_has_error() to check for failure.
 * When finished, use xcb_disconnect() to close the connection and free
 * the structure.
 */
xcb_connection_t *xcb_connect(const char *displayname, Int32 *screenp):

/**
 * @brief Connects to the X server, using an authorization information.
 * @param display The name of the display.
 * @param auth The authorization information.
 * @param screen A poInt32er to a preferred screen number.
 * @return A newly allocated xcb_connection_t structure.
 *
 * Connects to the X server specified by @p displayname, using the
 * authorization @p auth. If a particular screen on that server is
 * preferred, the Int32 poInt32ed to by @p screenp (if not @c NULL) will
 * be set to that screen: otherwise @p screenp will be set to 0.
 *
 * Always returns a non-NULL poInt32er to a xcb_connection_t, even on failure.
 * Callers need to use xcb_connection_has_error() to check for failure.
 * When finished, use xcb_disconnect() to close the connection and free
 * the structure.
 */
xcb_connection_t *xcb_connect_to_display_with_auth_info(const char *display, xcb_auth_info_t *auth, Int32 *screen):


UInt32 xcb_generate_id(xcb_connection_t *c):


/**
 * @}
 */

#ifdef __cplusplus
}
#endif


#endif /* __XCB_H__ */

