# Core Paths
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# Specifics for Wayland / Sway
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=pixman
# Specifics for screensharing via zoom in firefox in sway
export XDG_CURRENT_DESKTOP=sway
export MOZ_ENABLE_WAYLAND=1
# Specifics for painless zoom in sway - as sway-only config seemingly won't behave
export GDK_BACKEND=x11
# Libreofficecalc appearance
export GTK_THEME="Adwaita:dark"
# Quality of Life Aliases
alias xx='doas -u root'
alias volup='wpctl set-volume @DEFAULT_SINK@ 0.1+'
alias voldown='wpctl set-volume @DEFAULT_SINK@ 0.1-'
