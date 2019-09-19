import
  x11/[xlib, xutil, x, keysym],
  posix,
  mnmlpkg/utils

var
  dpy = XOpenDisplay(nil)
  ev: TXEvent
  ksym: TKeySym
  kstr: cstring
  start: TXButtonEvent
  attr: TXWindowAttributes
  wa: TXSetWindowAttributes

# launch programs
proc spawn*(s: cstringArray) =
  var 
    pid: Pid
    status: Pid
  pid = fork()
  if pid == 0:
    status = execvp(s[0], s)
    if status == -1:
      perror("mnml")
  if pid < 0:
    die("mnml: error in forking")

# error handlers
var oldxerror*: proc (dpy: PDisplay, ee: PXErrorEvent): cint {.cdecl.}

proc xerror*(dpy: PDisplay, ee: PXErrorEvent): cint {.cdecl.} =
  # TODO: handle other errors
#  if ee.error_code.cuint == BadWindow or
#      (ee.request_code.cuint == XSetInputFocus and ee.error_code.cuint == BadMatch) or
#      (ee.request_code.cuint == XConfigureWindow and ee.error_code.cuint == BadMatch) or
#      (ee.request_code.cuint == XGrabButton and ee.error_code.cuint == BadAccess) or
#      (ee.request_code.cuint == XGrabKey and ee.error_code.cuint == BadAccess) or
#      (ee.request_code.cuint == XCopyArea and ee.error_code.cuint == BadDrawable):
  if ee.error_code.cint == BadWindow:
    stderr.write("mnml: fatal error: error code and request code: ",
      ee.error_code.cuint, " " , ee.request_code.cuint, "\n")
    return 0
  return 0

proc xerrorstart*(dpy: PDisplay, ee: PXErrorEvent): cint {.cdecl.} =
  die("mnml: another window manager is already running\n")
  return -1

proc checkotherwm*() =
  discard XSetErrorHandler(xerrorstart)
  discard dpy.XSelectInput(XDefaultRootWindow(dpy), SubstructureRedirectMask)
  discard XSync(dpy, 0)
  discard XSetErrorHandler(xerror)
  discard XSync(dpy, 0)

proc grabkeys() =
  var kcode: TKeyCode
  discard dpy.XUngrabKey(AnyKey, AnyModifier, dpy.XDefaultRootWindow())
  return

proc setup*() =
  wa.event_mask = SubstructureRedirectMask or SubstructureNotifyMask or ButtonPressMask or 
    EnterWindowMask or LeaveWindowMask or StructureNotifyMask or PropertyChangeMask
  discard dpy.XChangeWindowAttributes(dpy.XDefaultRootWindow, CWEventMask, addr wa)
  discard XSetErrorHandler(xerror)
  discard dpy.XSelectInput(dpy.XDefaultRootWindow, wa.event_mask)

proc raisewindow(dpy: PDisplay, ev: TXEvent) =
  echo "raise"
  discard dpy.XGetWindowAttributes(ev.xbutton.subwindow, addr attr)
  discard dpy.XRaiseWindow(ev.xkey.subwindow)
  start = ev.xbutton
 
proc resizewindow(dpy: PDisplay, ev: TXEvent) =
  echo "resize"
  let
    xdiff = ev.xbutton.x_root - start.x_root
    ydiff = ev.xbutton.y_root - start.y_root
  discard dpy.XMoveResizeWindow(start.subwindow,
    cint(attr.x + (if start.button == 1: xdiff else: 0)),
    cint(attr.y + (if start.button == 1: ydiff else: 0)),
    cuint(max(1, attr.width + (if start.button == 3: xdiff else: 0))),
    cuint(max(1, attr.height + (if start.button == 3: ydiff else: 0))))

proc main() =
  if dpy == nil:
    die("mnml: error opening X display\n")
  checkotherwm()
  setup()

  # mouse actions
  discard dpy.XGrabButton(1, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)
  discard dpy.XGrabButton(3, Mod4Mask, dpy.XDefaultRootWindow, 1, ButtonPressMask or ButtonReleaseMask or PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None)
  
  discard dpy.XGrabKey(dpy.XKeysymToKeycode(XStringToKeysym("q")).cint, Mod4Mask, dpy.XDefaultRootWindow, 1, GrabModeAsync, GrabModeAsync)
  discard dpy.XGrabKey(dpy.XKeysymToKeycode(XK_Return).cint, Mod4Mask, dpy.XDefaultRootWindow, 1, GrabModeAsync, GrabModeAsync)

  # initialize error handler
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
          discard dpy.XUnmapWindow(ev.xunmap.window)
        of "Return":
          var l = @["urxvt"].allocCStringArray
          spawn(l)
          echo "mapping"
          l.deallocCStringArray
        else:
          continue
    elif ev.theType == ButtonPress and ev.xbutton.subwindow.culong != None:
      dpy.raisewindow(ev)
    elif ev.theType == MotionNotify and start.subwindow.culong != None:
      dpy.resizewindow(ev)
    elif ev.theType == ButtonRelease:
      start.subwindow = None
    elif ev.theType == MapNotify:
      echo "got MapNotify"
    elif ev.theType == MapRequest:
      discard dpy.XMapWindow(ev.xmaprequest.window)
    elif ev.theType == UnmapNotify:
      echo "got UnmapNotify"
      discard dpy.XDestroyWindow(ev.xunmap.window)


echo("the mnml window manager")
echo("(c) 2019 Anirudh Oppiliappan <x@icyphox.sh>")
main()
