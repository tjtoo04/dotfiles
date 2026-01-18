FONT_NAME="Monaspace Argon NF"
FONT_SIZE=14
BG_NORMAL="#1e1e2e"   # Dark background (Catppuccin Mocha)
FG_NORMAL="#cdd6f4"   # Light text
BG_SELECTED="#313244" # Highlight background
FG_SELECTED="#fab387" # Highlight text (Orange accent)
LINES=8               # Number of lines to show (makes it a floating box)
PROMPT="Run: "

# Combine wmenu-run with wmenu and styling options
wmenu-run -l "$LINES" -f "$FONT_NAME $FONT_SIZE" -N "$BG_NORMAL" -n "$FG_NORMAL" -S "$FG_SELECTED" -s "$BG_SELECTED" -i -p "$PROMPT" &
