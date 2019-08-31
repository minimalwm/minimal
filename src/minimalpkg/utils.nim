import posix


proc perror*(s: cstring): void {.header: "<stdio.h>".}
proc spawn*(s: cstringArray) =
  var 
    pid: Pid
    status: Pid
  pid = fork()
  if pid == 0:
    status = execvp(s[0], s)
    if status == -1:
      perror("error")
  if pid < 0:
    echo "minimalwm: error in forking"
    quit 1
 
