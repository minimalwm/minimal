import
  x11/[xlib, xutil, x, keysym],
  minimalpkg/[keybinds, utils]

proc main() =
  var
    dpy = XOpenDisplay(nil)
    start: TXButtonEvent
    ev: TXEvent
    ksym: TKeySym
    kstr: cstring
    handler: TXErrorHandler

  if dpy == nil:
    die("mnml: error opening X display")

  dpy.checkotherwm()

  # mouse actions
  discard dpy.XGrabButton(1, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)
  discard dpy.XGrabButton(3, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)
  
  # FIXME: throws BadWindow, also closes WM session
  discard dpy.XGrabKey(dpy.XKeysymToKeycode(XStringToKeysym("q")).cint, Mod4Mask, dpy.XDefaultRootWindow, 1, GrabModeAsync, GrabModeAsync)
  discard dpy.XGrabKey(dpy.XKeysymToKeycode(XK_Return).cint, Mod4Mask, dpy.XDefaultRootWindow, 1, GrabModeAsync, GrabModeAsync)

  # initialize error handler
#  handler = xerror
#  oldxerror = XSetErrorHandler(handler)

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
          discard dpy.XUnmapWindow(ev.xkey.subwindow)
          discard dpy.XDestroyWindow(ev.xkey.subwindow)
        of "Return":
          var l = @["xterm"].allocCStringArray
          spawn(l)
          discard dpy.XMapWindow(ev.xkey.window)
          l.deallocCStringArray
        else:
          continue
    elif ev.theType == ButtonPress and ev.xbutton.subwindow.culong != None:
      dpy.raisewindow(ev)
    elif ev.theType == MotionNotify and start.subwindow.culong != None:
      dpy.resizewindow(ev)
    elif ev.theType == ButtonRelease:
      start.subwindow = None

main()
