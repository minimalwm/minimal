import
  x11/x,
  x11/xlib,
  x11/xatom,
  x11/xinerama,

  minimalpkg/converters

var
  display:PDisplay    # Display object for x11

when isMainModule:
  display = XOpenDisplay(nil)
  # nil here will ensure that it opens
  # the default display

  if display.isNil:
    quit("Failed to open Display", QuitFailure)

  var xinerama_status = XineramaIsActive(display)

  if xinerama_status.isFalse:
    quit("Xinerama is not loaded.", QuitFailure)

  discard XCloseDisplay(display)
  # Should find way to always ensure this procedure is called.
