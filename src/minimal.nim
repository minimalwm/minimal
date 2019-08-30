import x11/xlib, x11/xutil, x11/x, x11/keysym

var
  dpy = XOpenDisplay(nil)
  start: TXButtonEvent
  ev: TXEvent
  attr: TXWindowAttributes

if dpy == nil: quit 1

discard dpy.XGrabKey(dpy.XKeysymToKeycode(XStringToKeysym("F1")).cint, Mod4Mask, dpy.XDefaultRootWindow, 1, GrabModeAsync, GrabModeAsync)
discard dpy.XGrabButton(1, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)
discard dpy.XGrabButton(3, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)

while true:
  discard dpy.XNextEvent(addr ev)
  echo "Type: ", ev.theType, ", subwindow: ", ev.xkey.subwindow, " ", ev.xbutton.subwindow, " ", start.subwindow
  if ev.theType == KeyPress and ev.xkey.subwindow.culong != None:
    discard dpy.XRaiseWindow(ev.xkey.subwindow)
  elif ev.theType == ButtonPress and ev.xbutton.subwindow.culong != None:
    discard dpy.XGetWindowAttributes(ev.xbutton.subwindow, addr attr)
    start = ev.xbutton
  elif ev.theType == MotionNotify and start.subwindow.culong != None:
    let
      xdiff = ev.xbutton.x_root - start.x_root
      ydiff = ev.xbutton.y_root - start.y_root
    discard dpy.XMoveResizeWindow(start.subwindow,
      cint(attr.x + (if start.button == 1: xdiff else: 0)),
      cint(attr.y + (if start.button == 1: ydiff else: 0)),
      cuint(max(1, attr.width + (if start.button == 3: xdiff else: 0))),
      cuint(max(1, attr.height + (if start.button == 3: ydiff else: 0))))
  elif ev.theType == ButtonRelease:
    start.subwindow = None

