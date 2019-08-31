import
  x11/[xlib, xutil, x, keysym],
  minimalpkg/[keybinds, utils]

var
  dpy = XOpenDisplay(nil)
  start: TXButtonEvent
  ev: TXEvent
  attr: TXWindowAttributes
  ksym: TKeySym
  kstr: cstring


if dpy == nil:
  echo "error: failed to open X display"
  quit 1

# mouse actions
discard dpy.XGrabButton(1, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)
discard dpy.XGrabButton(3, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)

# FIXME: throws BadWindow, also closes WM session
discard dpy.XGrabKey(dpy.XKeysymToKeycode(XStringToKeysym("q")).cint, Mod4Mask, dpy.XDefaultRootWindow, 1, GrabModeAsync, GrabModeAsync)
discard dpy.XGrabKey(dpy.XKeysymToKeycode(XK_Return).cint, Mod4Mask, dpy.XDefaultRootWindow, 1, GrabModeAsync, GrabModeAsync)

while true:

  discard dpy.XNextEvent(addr ev)
  echo "Type: ", ev.theType, ", subwindow: ", ev.xkey.subwindow, " ", ev.xbutton.subwindow, " ", start.subwindow
  echo "keycode: ", ev.xkey.keycode
  if ev.theType == KeyPress and ev.xkey.window.culong != None:
    ksym = XKeycodeToKeysym(dpy, cast[TKeyCode](ev.xkey.keycode), 0)
    kstr = XKeysymToString(ksym)
    echo "keystring: ", kstr
    case $kstr:
      of "q":
        discard dpy.XDestroyWindow(ev.xkey.subwindow)
      of "Return":
        var l = @["xterm"].allocCStringArray
        spawn(l)
        l.deallocCStringArray
      else:
        continue
  elif ev.theType == ButtonPress and ev.xbutton.subwindow.culong != None:
    discard dpy.XGetWindowAttributes(ev.xbutton.subwindow, addr attr)
    discard dpy.XRaiseWindow(ev.xkey.subwindow)
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

