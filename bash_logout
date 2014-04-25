# ~/.bash_logout: executed by bash(1) when login shell exits.

# when leaving the last level of sheel $SHLVL == 1
# console cleared the screen. This works in tty, not in terminal
# you can use /usr/bin/clear if need to work in terminal, but unneccesary

if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi
