# Location of the history file
HISTFILE=$HOME/dotfiles/zsh/history

# Number of history entries to keep in memory
HISTSIZE=100000

# Number of history entries to keep in the history file
SAVEHIST=1000000

# Prevent overwriting the prompt with output without newlines
unsetopt promptcr

# Record start time and elapsed time in the history file
setopt extended_history

# Append to history file instead of creating a new one
setopt append_history

# Do not record duplicates (older ones are deleted)
setopt hist_ignore_all_dups

# Do not add the same command line as the previous one to history
setopt hist_ignore_dups

setopt HIST_SAVE_NO_DUPS

# Do not store the `history` command itself in history
setopt hist_no_store

# Do not record commands that start with a space
setopt hist_ignore_space

# Remove extra whitespace before recording
setopt hist_reduce_blanks

# Write to the history file upon command completion
# inc_append_history_time: Adds to history file during execution
# ↑ When used with extended_history, the elapsed time will be recorded as 0
setopt inc_append_history_time

# Treat # as a comment in command lines
setopt interactive_comments

# Automatically remove trailing / added by completion
setopt auto_remove_slash

# Add trailing / to directory names in completion, preparing for the next completion
setopt auto_param_slash

# Add trailing / to directory names when expanding filenames
setopt mark_dirs

# Display file type markers in completion candidate lists (e.g., ls -F symbols)
setopt list_types

# Move to directories without using cd
setopt auto_cd

# Correct mistyped commands
setopt correct

# Pause before executing rm * command
setopt rm_star_wait
