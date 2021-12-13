CurNormal = 0
CurResize = 1
CurMove = 2
CurLast = 3

ColBorder = 0
ColFG = 1
ColBG = 2
ColLast = 3

ClkTagBar = 0
ClkLtSymbol = 1
ClkLtSymbol = 2
ClkStatusText = 3
ClkWinWinTitle = 4

ClkTagBar = 0
ClkLtSmybol = 1
ClkStatusText = 2
ClkWinTitle = 3
ClkClientWin = 4
ClkRootWin = 5
ClkLast = 6

struct Arg
	i : Int32
	ui : UInt32
	f : Float32
	v : Pointer(Void)
end

struct Button
	click : UInt32
	mask : UInt32
	button : Arg
	arg : Arg
end

struct Client
	name : String
	mina, maxa : Float32
	x, y, w, h : Int32
	basew, baseh, incew, inch, maxw, maxh, minw, minh : Int32
	bw, oldbw : Int32
	tags : Int32
	isfixed, isfloating, isurgent, oldstate : Bool
	nxt : Pointer(Client)
	snxt : Pointer(Client)
	mon : Pointer(Monitor)
	win : xcb_window_t
end

struct DC
	x, y, w, h : Int32
	norm : UInt32[ColLast]
	sel : UInt32[ColLast]
	gc : xcb_gcontext_t
	type font = x0 : Int32, x1 : Int32, x2 : Int32, x3 : xcb_font_t, x4 : Bool
end

struct Key
	mod : UInt32
	keysym : xcb_keysym_t
	func : Pointer(Arg) -> NoReturn
	arg : Arg
end

struct Layout
	symbol = Pointer(Char)
	arrange = Pointer(Monitor)
end

struct Monitor
	ltsymbol : StaticArray(Char, 16)
	mfact : Float32
	num : Int32
	by : Int32
	mx, my, mw, mh : Int32
	wx, wy, ww, wh : Int32
	seltags : Int32
	sellt : Int32
	tagset : StaticArray(Int32, 2)
	showbar : Bool
	topbar : Bool
	clients : Pointer(Client)
	sel : Pointer(Client)
	stack : Pointer(Client)
	nxt : Pointer(Monitor)
	barwin : xcb_window_t
	lt : StaticArray(Layout, 2)
end

def Rule
	class_ : Pointer(Char)
	instance : Pointer(Char)
	title : Pointer(Char)
	tags : Int32
	isfloating : Bool
	monitor : Int32
end

struct handler_func_t
	request : UInt32
	func : Pointer(xcb_generic_event_t) -> Int32
end
