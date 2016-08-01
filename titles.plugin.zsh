# Copyright 2015 John Reese
# Licensed under the MIT license
#
# Update terminal/tmux window titles based on location/command

function update_title_clean() {
  # escape '%' in $1, make nonprintables visible
  a=${(V)2//\%/\%\%}
  a=$(print -n "%20>...>$a" | tr -d "\n")
  if [[ -n "$TMUX" ]]; then
    print -Pn "\ek$1:$a\e\\"
  elif [[ "$TERM" =~ "xterm*" ]]; then
    print -Pn "\e]0;$1:$a\a"
  fi
}
function update_title() {
  # escape '%' in $1, make nonprintables visible
  if [[ -n "$TMUX" ]]; then
    print -Pn "\ek$1:$2\e\\"
  elif [[ "$TERM" =~ "xterm*" ]]; then
    print -Pn "\e]0;$1:$2\a"
  fi
}

# called just before the prompt is printed
function _zsh_title__precmd() {
  update_title "%n@%m" "%20<...<%~"
}

# called just before a command is executed
function _zsh_title__preexec() {
  local -a cmd; cmd=(${(z)1})             # Re-parse the command line

  # Construct a command that will output the desired job number.
  case $cmd[1] in
    fg)	cmd="${(z)jobtexts[${(Q)cmd[2]:-%+}]}" ;;
    %*)	cmd="${(z)jobtexts[${(Q)cmd[1]:-%+}]}" ;;
  esac
  update_title_clean "%n@%m" "$cmd"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_title__precmd
add-zsh-hook preexec _zsh_title__preexec
