
# nimplt on Windows

{.pragma: User, stdcall, dynlib: "User32.dll".}
{.pragma: Gdi, stdcall, dynlib: "Gdi32.dll".}

import nltypes,sequtils

# types
type
  WndClassEx = object
    cbSize: int32
    style: int32
    lpfnWndProc: pointer
    cbClsExtra: int32
    cbWndExtra: int32
    hInstance: pointer
    hIcon: pointer
    hCursor: pointer
    hbrBackground: pointer
    lpszMenuName: cstring
    lpszClassName: cstring
    hIconSm: pointer
  Point = object
    x: int32
    y: int32
  Msg = object
    hwnd: pointer
    message: int32
    wParam: int
    lParam: int
    time: int32
    pt: Point
  RGB32 = object
    red: byte
    green: byte
    blue: byte
    unused: byte
  PaintStruct = array[68, byte]
  Rect = object
    left: int32
    top: int32
    right: int32
    bottom: int32

# functions from Win32API
proc CreateWindowExA(dwExStyle:int32,lpClassName,lpWindowName:cstring,dwStyle:int32,x,y,nWidth,nHeight:int,hWndParent,hMenu,hInstance,lpParam:pointer):pointer{.importc:"CreateWindowExA",User.}
proc ShowWindow(hWnd:pointer,nCmdShow:int32):bool{.importc:"ShowWindow",User.}
proc DefWindowProcA(hWnd:pointer,uMsg:int,wParam,lParam:pointer):pointer{.importc:"DefWindowProcA",User.}
proc TranslateMessage(lpMsg: pointer): bool {.importc: "TranslateMessage", User.}
proc DispatchMessageA(lpMsg: pointer): pointer {.importc: "DispatchMessageA", User.}
proc PostQuitMessage(nExitCode: int32) {.importc: "PostQuitMessage", User.}
proc GetMessageA(lpMsg, hWnd: pointer, wMsgFilterMin, wMsgFilterMax: int32): bool {.importc: "GetMessageA", User.}
proc RegisterClassExA(lpwcx: WndClassEx): int16 {.importc: "RegisterClassExA", User.}
proc LoadCursorA(hInstance: pointer, lpCursorName: cstring): pointer {.importc: "LoadCursorA", User.}
proc GetDC(hWnd:pointer):pointer{.importc:"GetDC", User.}
proc TextOutW(hdc: pointer, nXStart, nYStart: int32, lpString: cstring, cchString: int32): bool {.importc: "TextOutW", Gdi.}
proc ReleaseDC(hWnd,hDc:pointer):int8{.importc:"ReleaseDC", User.}
proc BeginPaint(hWnd: pointer, lpPaint: ptr PaintStruct): pointer {.importc: "BeginPaint", User.}
proc EndPaint(hWnd: pointer, lpPaint: ptr PaintStruct): bool {.importc: "EndPaint", User.}
proc GetAsyncKeyState(vKey: int32): int8 {.importc: "GetAsyncKeyState", User.}
proc InvalidateRect(hWnd: pointer, lpRect:ref Rect, bErase: bool): bool {.importc: "InvalidateRect", User.}
proc InvalidateRgn(hWnd: pointer, hrgn:pointer, bErase: bool): bool {.importc: "InvalidateRect", User.}
proc UpdateWindow(hWnd: pointer): bool {.importc: "UpdateWindow", User.}
proc RedrawWindow(hWnd: pointer,lprcUpdate:ref Rect,hrgnUpdate:pointer,flags:int32): bool {.importc: "RedrawWindow", User.}
proc GetCursorPos(lpPoint :ptr Point) :bool {.importc:"GetCursorPos", User.}
proc CreateFontA(nHeight, nWidth, nEscapement, nOrientation, fnWeight, fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision, fdwClipPrecision, fdwQuality, fdwPitchAndFamily: int32, lpszFace: cstring): pointer {.importc: "CreateFontA", Gdi.}
proc MoveToEx(hdc: pointer, x, y: int32, lpPoint: pointer): bool {.importc: "MoveToEx", Gdi.}
proc LineTo(hdc: pointer, nXEnd, nYEnd: int): bool {.importc: "LineTo", Gdi.}
proc CreatePen(fnPenStyle, nWidth: int32, crColor: RGB32): pointer {.importc: "CreatePen", Gdi.}
proc CreateSolidBrush(crColor: RGB32): pointer {.importc: "CreateSolidBrush", Gdi.}
proc SelectObject(hdc, hgdiobj: pointer): pointer {.importc: "SelectObject", Gdi.}
proc DeleteObject(hObject: pointer): bool {.importc: "DeleteObject", Gdi.}
proc Rectangle(hdc: pointer, sx, sy, ex, ey: int32): pointer {.importc: "Rectangle", Gdi.}
proc Ellipse(hdc: pointer, sx, sy, ex, ey: int32): pointer {.importc: "Ellipse", Gdi.}
proc GetStockObject(fnObject: int32): pointer {.importc: "GetStockObject", Gdi.}
proc DeleteDC(hdc:pointer):bool{.importc: "DeleteDC", Gdi.}

proc GetLastError:int32{.importc:"GetLastError",stdcall,dynlib:"Kernel32.dll".}

proc event(hWnd:pointer,uMsg:int,wParam,lParam:pointer):pointer

var winc= WndClassEx(
  cbSize:WndClassEx.sizeof.int32,
  lpszClassName:"MAIN",
  lpfnWndProc:event,
  style:0,
  cbClsExtra:0,
  cbWndExtra:0,
  hInstance:nil,
  hIcon:nil,
  hCursor:LoadCursorA(nil, cast[cstring](32512)),
  hbrBackground:GetStockObject(0),
  lpszMenuName:nil,
  hIconSm:nil
  )
discard RegisterClassExA(winc)

var
  hwnd : pointer
  msg : Msg
  ##hdc,tdc : pointer
  txy : seq[array[2,int]] = @[]
  txts : seq[string] = @[]
  pen,rcp,brs : seq[pointer] = @[]
  stx : string
  inp : int=0
  dlxy : seq[seq[array[2,int]]] = @[]
  rcxy : seq[array[6,int]] = @[]
  ppos : Point
  mto,mtp : bool = false
  tesi : int =0

proc resetVal* =
  dlxy  = @[]
  rcxy  = @[]
  txy = @[]
  txts = @[]
  pen = @[]
  rcp = @[]
  brs = @[]

# event - event
proc event(hWnd:pointer,uMsg:int,wParam,lParam:pointer):pointer=
  inp=0

  var
    ps:PaintStruct
    hdc,tdc:pointer
    hpen,hbrs:pointer
    hfont : pointer = CreateFontA(20,0,0,0,0,0,0,0,0,0,0,0,0,"Calibri")

  case uMsg
  of 0x0002: # means "WM_DESTROY"
    PostQuitMessage(0)
    return nil
  of 0x0100:
    for i in countup(0,7):
      if GetAsyncKeyState(int32([0x25,0x26,0x27,0x28,0xA0,0xA1,0xA2,0xA3][i]))!=0:
        inp=i+1
    return nil
  of 0x0201: # means "WM_LBUTTONDOWN"
    mto=true
    return nil
    ##echo GetCursorPos(ppos.addr)
    ##echo ppos.x
    ##echo "0x0201"
  of 0x0202: # means "WM_LBUTTONUP"
    mto=false
    return nil
    ##echo "0x0202"
  of 0x0200: # means "WM_MOUSEMOVE"
    return nil
  of 0x02A3: # means "WM_MOUSELEAVE"
    echo "0x02A3"
    return nil
  of 0x000F: # means "WM_PAINT"
    # draw lines
    hdc = hwnd.BeginPaint(ps.addr)
    for i in 0..<dlxy.len:
      hpen=pen[i]
      discard hdc.SelectObject(hpen)
      discard hdc.MoveToEx(int32(dlxy[i][0][0]),int32(dlxy[i][0][1]),nil)
      for I in 1..<dlxy[i].len:
        discard hdc.LineTo(dlxy[i][I][0],dlxy[i][I][1])
      discard hpen.DeleteObject

    # draw rects
    for i in 0..<rcxy.len:
      hpen=rcp[i]
      hbrs=brs[i]
      if rcxy[i][4]==0:
        discard hdc.Rectangle(int32(rcxy[i][0]),int32(rcxy[i][1]),int32(rcxy[i][2]),int32(rcxy[i][3]))
      else:
        discard hdc.Ellipse(int32(rcxy[i][0]),int32(rcxy[i][1]),int32(rcxy[i][2]),int32(rcxy[i][3]))
      discard hpen.DeleteObject
      discard hbrs.DeleteObject

    #draw texts
    tdc = hwnd.GetDC
    discard tdc.SelectObject(hfont)
    for ts in (0..<txts.len):
      stx=txts[ts]
      for i in countdown(txts[ts].len-1,1):
        stx.insert("\0",i)
      discard tdc.TextOutW(int32(txy[ts][0]),int32(txy[ts][1]),stx,int8(txts[ts].len))
    discard hfont.DeleteObject

    discard hwnd.ReleaseDC(hdc)
    discard hwnd.ReleaseDC(tdc)
    discard hwnd.EndPaint(ps.addr)
    mtp=false
    return nil

    # draw texts
    #[
    tdc = hwnd.GetDC
    discard tdc.SelectObject(hfont)
    for ts in (0..<txts.len):
      stx=txts[ts]
      for i in countdown(txts[ts].len-1,1):
        stx.insert("\0",i)
      echo tdc.TextOutW(int32(txy[ts][0]),int32(txy[ts][1]),stx,int8(txts[ts].len))
    echo hwnd.ReleaseDC(tdc)
    echo tdc.DeleteDC
    echo hdc.DeleteDC
    echo hwnd.EndPaint(ps)
    echo "-----"

    ]#
  else:discard

  return DefWindowProcA(hWnd,uMsg,wParam,lParam)

# line - draw lines
proc line*(w:int,rgb:array[3,int] or seq[int],xy:seq[array[2,int]])=
  pen.add(CreatePen(0,int32(w),RGB32(red:uint8(rgb[0]), green:uint8(rgb[1]), blue:uint8(rgb[2]), unused:0)))
  dlxy.add(xy)

# softLine - draw lines (soft)
proc softLine*(w:int,rgb:array[3,int],xy:seq[array[2,int]])=
  ##proc tff(n:int):int=255-(255-n)div 2
  line(w,map(rgb,proc(n:int):int=255-(255-n)div 2),xy)
  line(w-1,rgb,xy)

# rect
proc rect*(sx,sy,ex,ey:int,rgb:tuple,cy,w:int)=
  rcp.add(CreatePen(0,int32(w),RGB32(red:uint8(rgb[0]), green:uint8(rgb[1]), blue:uint8(rgb[2]), unused:0)))
  brs.add([CreateSolidBrush(RGB32(red:uint8(255), green:uint8(255), blue:uint8(255), unused:0)),CreateSolidBrush(RGB32(red:uint8(rgb[0]), green:uint8(rgb[1]), blue:uint8(rgb[2]), unused:0))][int(w==0)])
  rcxy.add([sx,sy,ex,ey,cy,w])

# text - draw a text
proc text*(x,y:int,txt:string)=
  txts.add(txt)
  txy.add([x,y])

# GetMessage - get message
proc GetMessage*:bool =
  return GetMessageA(msg.addr,nil,0,0)

# Loopin - main loop
proc Loopin* =
  #[
  if GetLastError()!=0:
    echo """<< Win32API error >>
Error code : """ & $GetLastError()
  ]#
  discard DispatchMessageA(msg.addr)

# reDraw
proc reDraw* =
  if not mtp:
    mtp=true
    discard hwnd.InvalidateRgn(nil,true)
  discard hwnd.UpdateWindow

# mousePos - mouse position
proc mousePos* :array[2,int]=
  discard GetCursorPos(ppos.addr)
  return [int(ppos.x),int(ppos.y)]

# showWin - show the window
proc showWin*(winSize:tuple)=
  hwnd = CreateWindowExA(1,"MAIN","Nimplt - Alpha",0x00CF0000,150,200,winSize[0],winSize[1],nil,nil,nil,nil)
  if hwnd==nil:echo "Failed to create window"
  if hwnd.ShowWindow(5):echo "Failed to show window"
