# Use modern completion system.
autoload -Uz +X compinit && compinit

# Execute code in the background to not affect the current session.
{
    # Compile zcompdump, if modified, to increase startup speed.
    zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
    if [[ -s "$zcompdump" ]] && \
       [[ (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
      zcompile -U "$zcompdump"
    fi
} &!

# Load colour variables.
eval "$(dircolors -b)"

# Description for options that are not described by completion functions.
zstyle ':completion:*' auto-description "${BRIGHT_BLACK}Specify %d${RESET}"
# Enable corrections, expansions, completions and approximate completers.
zstyle ':completion:*' completer _expand _complete _correct _approximate
# Display 'Completing $section' between types of matches, ie. 'Completing external command'
zstyle ':completion:*' format "${BRIGHT_BLACK}Completing %d${RESET}"
# Display all types of matches separately (same types as above).
zstyle ':completion:*' group-name ''
# Use menu selection if there are more than two matches (or when not on screen).
zstyle ':completion:*' menu select=2
zstyle ':completion:*' menu select=long
# Set colour specifications.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
# Prompt to show when completions don't fit on screen.
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
# Define matcher specifications.
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=* l:|=*'
# Don't use legacy `compctl`.
zstyle ':completion:*' use-compctl false
# Show command descriptions.
zstyle ':completion:*' verbose true
# Extra patterns to accept.
zstyle ':completion:*' accept-exact '*(N)'
# Enable caching.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Extra settings for processes.
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Modify git completion for only local files and branches - much faster!
__git_files () { _wanted files expl 'local files' _files  }

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
