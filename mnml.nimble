# Package

version       = "0.0.1"
author        = "jacobsin"
description   = "A window manager written in nim"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["mnml"]

# Version Dependency
requires "nim >= 0.20.0"

# Library Dependencies
requires "x11"
# foreignDep "libx11-dev"

# -----------------------------------------------------#
# Task Definitions ------------------------------------#
# -----------------------------------------------------#
task build, "Run a simple build":
    exec "nim c src/mnml.nim"

task release, "Build a release":
    exec "nim c -d:release --opt:speed src/mnml.nim"

task debug, "Build for debugging":
  exec "nim c --debugger:native src/mnml.nim"
