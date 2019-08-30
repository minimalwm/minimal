# minimal
A window manager written in Nim, inspired by dwm and i3

## Development

Using `Xephyr` makes things a lot easier. It can be found as `xserver-xephyr`
on Ubuntu/Debian & `xorg-server-xephyr` in Arch Linux.

Launch `Xephyr`:
```shell
$ Xephyr -ac -br -noreset -screen 800x600 :1 &
```

Run `minimal` under display `:1`:
```shell
$ DISPLAY=:1 ./minimal
```

Launch applications under the `Xephyr` server:
```shell
$ DISPLAY=:1 xterm
```

## Usage

As of now, `minimal` only supports moving & resizing windows. That can
be done using `Meta` + left mouse & `Meta` + right mouse, respectively.
Windows can be raised using `Meta` + `F1`.
