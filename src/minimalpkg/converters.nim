import
  x11/x, 
  x11/xlib, 
  x11/xinerama

converter toBool*(x: TBool): bool = x.bool

proc isFalse*(x: TBool): bool = x != 1