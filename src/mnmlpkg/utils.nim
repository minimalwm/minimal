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

