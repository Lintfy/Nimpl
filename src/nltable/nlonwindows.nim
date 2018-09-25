
# telines on Windows

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
proc GetStockObject(fnObject: int32): pointer {.importc: "GetStockObject", Gdi.}
proc LoadCursorA(hInstance: pointer, lpCursorName: cstring): pointer {.importc: "LoadCursorA", User.}
proc GetDC(hWnd:pointer):pointer{.importc:"GetDC", User.}
proc TextOutW(hdc: pointer, nXStart, nYStart: int32, lpString: cstring, cchString: int32): bool {.importc: "TextOutW", Gdi.}
proc ReleaseDC(hWnd,hDc:pointer):int8{.importc:"ReleaseDC", User.}
proc BeginPaint(hWnd: pointer, lpPaint: var PaintStruct): pointer {.importc: "BeginPaint", User.}
proc EndPaint(hWnd: pointer, lpPaint: var PaintStruct): bool {.importc: "EndPaint", User.}
proc GetAsyncKeyState(vKey:int32): int8 {.importc: "GetAsyncKeyState", User.}
##proc SendMessageA(hWnd: pointer, msg: int32, wParam, lParam: pointer): pointer {.importc: "SendMessageA", User.}
proc CreateFontA(nHeight, nWidth, nEscapement, nOrientation, fnWeight, fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet, fdwOutputPrecision, fdwClipPrecision, fdwQuality, fdwPitchAndFamily: int32, lpszFace: cstring): pointer {.importc: "CreateFontA", Gdi.}
##proc SetPixel(hdc: pointer, x, y: int32, crColor: RGB32): int32 {.importc: "SetPixel", Gdi.}
proc MoveToEx(hdc: pointer, x, y: int32, lpPoint: pointer): bool {.importc: "MoveToEx", Gdi.}
proc LineTo(hdc: pointer, nXEnd, nYEnd: int): bool {.importc: "LineTo", Gdi.}
proc CreatePen(fnPenStyle, nWidth: int32, crColor: RGB32): pointer {.importc: "CreatePen", Gdi.}
proc CreateSolidBrush(crColor: RGB32): pointer {.importc: "CreateSolidBrush", Gdi.}
proc SelectObject(hdc, hgdiobj: pointer): pointer {.importc: "SelectObject", Gdi.}
##proc DeleteObject(hObject: pointer): bool {.importc: "DeleteObject", Gdi.}
proc Rectangle(hdc: pointer, sx, sy, ex, ey: int32): pointer {.importc: "Rectangle", Gdi.}
proc Ellipse(hdc: pointer, sx, sy, ex, ey: int32): pointer {.importc: "Ellipse", Gdi.}
##proc FillRect(hDC: pointer, lprc: Rect, hbr: pointer): int32 {.importc: "FillRect", User.}

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
  hfont : pointer = CreateFontA(20,0,0,0,0,0,0,0,0,0,0,0,0,"Calibri")
  msg : Msg
  ps : PaintStruct
  hdc,tdc : pointer
  dlxy : seq[seq[array[2,int]]] = @[]
  rcxy : seq[array[6,int]] = @[]
  txy : seq[array[2,int]] = @[]
  txts : seq[string] = @[]
  pen,rcp,brs : seq[pointer] = @[]
  stx : string
  inp* : int=0

# setHwnd

# event - event
proc event(hWnd:pointer,uMsg:int,wParam,lParam:pointer):pointer=
  inp=0
  case uMsg
  of 0x0002: # means "WM_DESTROY"
    PostQuitMessage(0)
  of 0x0100:
    for i in [37,38,39,40]:
      if GetAsyncKeyState(int32(i))!=0:
        inp=i-36
  of 0x000F: # means "WM_PAINT"
    # draw lines
    hdc = hwnd.BeginPaint(ps)
    var dln=0
    for xy in dlxy:
      discard hdc.SelectObject(pen[dln])
      discard hdc.MoveToEx(int32(xy[0][0]),int32(xy[0][1]),nil)
      for i in 1..<xy.len:
        discard hdc.LineTo(xy[i][0],xy[i][1])
      dln+=1
    dln=0
    for xy in rcxy:
      discard hdc.SelectObject(rcp[dln])
      discard hdc.SelectObject(brs[dln])
      if xy[4]==0:
        ##if xy[5]==0:
          ##discard hdc.FillRect(Rect(left:int32(xy[0]),top:int32(xy[1]),right:int32(xy[2]),bottom:int32(xy[3])),rcp[dln])
        ##else:discard hdc.Rectangle(int32(xy[0]),int32(xy[1]),int32(xy[2]),int32(xy[3]))
        discard hdc.Rectangle(int32(xy[0]),int32(xy[1]),int32(xy[2]),int32(xy[3]))
      else:
        discard hdc.Ellipse(int32(xy[0]),int32(xy[1]),int32(xy[2]),int32(xy[3]))
      dln+=1
    discard hwnd.EndPaint(ps)

    # draw texts

    tdc = hwnd.GetDC
    discard tdc.SelectObject(hfont)
    for ts in (0..<txts.len):
      stx=txts[ts]
      for i in countdown(txts[ts].len-1,1):
        stx.insert("\0",i)

      discard tdc.TextOutW(int32(txy[ts][0]),int32(txy[ts][1]),stx,int8(txts[ts].len))
    discard hwnd.ReleaseDC(tdc)
    ##
  else:
    discard

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
  discard TranslateMessage(msg.addr)
  discard DispatchMessageA(msg.addr)

# showWin - show the window
proc showWin*(winSize:tuple)=
  hwnd = CreateWindowExA(1,"MAIN","NimPl - Alpha",0x00CF0000,150,200,winSize[0],winSize[1],nil,nil,nil,nil)
  if hwnd==nil:echo "Failed to create window"
  discard hwnd.ShowWindow(5)
