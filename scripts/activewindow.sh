#!/bin/sh

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

print_icon() {
    CLASS=$(hyprctl activewindow -j | jq -r '.class' | tr '[:upper:]' '[:lower:]')

    ICON=$(gtk-query-icon-theme hicolor "$CLASS" 2>/dev/null | head -n1)
    if [ -n "$ICON" ] && [ -f "$ICON" ]; then
        printf "%s\n" "$ICON"
        return
    fi

    ICON=$(find \
        /usr/share/icons \
        /usr/share/pixmaps \
        -type f \( -iname "$CLASS.png" -o -iname "$CLASS.svg" \) \
        2>/dev/null | head -n1)

    if [ -n "$ICON" ]; then
        printf "%s\n" "$ICON"
        return
    fi

    printf "/usr/share/icons/hicolor/48x48/apps/application-default-icon.png\n"
}

print_icon
socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    case "$line" in
        activewindow*|activewindowv2*)
            print_icon
            ;;
    esac
done
