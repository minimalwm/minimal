import
  posix,
  x11/[xlib, xutil, x, keysym]

const
  EXIT_FAILURE* = 0
  EXIT_SUCCESS* = 1

# exit procs
proc perror*(s: cstring): void {.header: "<stdio.h>".}
proc die*(msg: cstring) =
  stderr.write(msg)
  quit EXIT_FAILURE

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
    stderr.write("mnml: fatal error: error code and request code: ", ee.error_code.cuint, " " , ee.request_code.cuint, "\n")
    return 0
  return 0

proc xerrorstart*(dpy: PDisplay, ee: PXErrorEvent): cint {.cdecl.} =
  die("mnml: another window manager is already running\n")
  return -1

proc checkotherwm*(dpy: PDisplay) =
  oldxerror = XSetErrorHandler(xerrorstart)
  discard dpy.XSelectInput(DefaultRootWindow(dpy), SubstructureRedirectMask)
  discard XSync(dpy, 0)
  discard XSetErrorHandler(xerror)
  discard XSync(dpy, 0)

# mouse actions
var 
  start*: TXButtonEvent
  attr*: TXWindowAttributes

proc raisewindow*(dpy: PDisplay, ev: TXEvent) =
  discard dpy.XGetWindowAttributes(ev.xbutton.subwindow, addr attr)
  discard dpy.XRaiseWindow(ev.xkey.subwindow)
  start = ev.xbutton
 
proc resizewindow*(dpy: PDisplay, ev: TXEvent) =
  let
    xdiff = ev.xbutton.x_root - start.x_root
    ydiff = ev.xbutton.y_root - start.y_root
  discard dpy.XMoveResizeWindow(start.subwindow,
    cint(attr.x + (if start.button == 1: xdiff else: 0)),
    cint(attr.y + (if start.button == 1: ydiff else: 0)),
    cuint(max(1, attr.width + (if start.button == 3: xdiff else: 0))),
    cuint(max(1, attr.height + (if start.button == 3: ydiff else: 0))))

