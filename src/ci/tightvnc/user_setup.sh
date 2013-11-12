# 
# example for starting and killing a display serer:
# export DISPLAY_NUMBER=5900
# tightvncserver :$DISPLAY_NUMBER -geometry 1024x768 -rfbport $DISPLAY_NUMBER -interface 0.0.0.0
# tightvncserver -kill :$DISPLAY_NUMBER -clean

rm -rf ~/.vnc
mkdir -p ~/.vnc
echo "$USER" | tightvncpasswd -f > ~/.vnc/passwd
chmod go-rw ~/.vnc/passwd

cat <<'EOF' > ~/.vnc/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
xsetroot -solid grey
#x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
#x-window-manager &
# Fix to make GNOME work
fluxbox &
export XKL_XMODMAP_DISABLE=1
/etc/X11/Xsession
EOF
chmod a+x ~/.vnc/xstartup


