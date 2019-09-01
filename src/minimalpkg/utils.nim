import
  posix,
  x11/[xlib, xutil, x, keysym]

proc perror*(s: cstring): void {.header: "<stdio.h>".}

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
    echo "mnml: error in forking"
    quit 1
 
proc xerror*(dpy: PDisplay, ee: PXErrorEvent): cint {.cdecl.}=
  # TODO: handle other errors
  # if ee.error_code.cuint == BadWindow:
  stderr.write("mnml: error code", ee.error_code)
  return 0
