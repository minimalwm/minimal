import
  x11/x,
  x11/xlib,
  x11/xatom,
  x11/xinerama,

  minimalpkg/converters

var
  display:PDisplay    # Display object for x11
  root:TWindow        # Default root window for display
  attr:TXWindowAttributes
  screen:cint
  screen_width:cint
  screen_height:cint

when isMainModule:
  display = XOpenDisplay(nil)
  # nil here will ensure that it opens
  # the default display

  if display.isNil:
    quit("Failed to open Display", QuitFailure)

  var xinerama_status = XineramaIsActive(display)

  if xinerama_status.isFalse:   
    # Is there a better way to do this and I just suck.
    quit("Xinerama is not loaded.", QuitFailure)

  screen = DefaultScreen(display)
  screen_width = DisplayWidth(display, screen)
  screen_height = DisplayHeight(display, screen)
  
  root = RootWindow(display, screen)
  
  # Get monitors
  # 

  discard XCloseDisplay(display)
  # Should find way to always ensure this procedure is called.
