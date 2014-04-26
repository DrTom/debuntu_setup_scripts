cat <<'EOF' > ~/.bashrc

set -o vi

export PATH="${HOME}/bin:${PATH}"

export EDITOR=vim

# fancy prompt

if [ "`id -u`" -eq 0 ]; then
  CCODE='\[\033[01;31m\]'
else
  CCODE='\[\033[01;32m\]'
fi

_PS1 ()
{
    local PRE= NAME="$1" LENGTH="$2";
    [[ "$NAME" != "${NAME#$HOME/}" || -z "${NAME#$HOME}" ]] &&
        PRE+='~' NAME="${NAME#$HOME}" LENGTH=$[LENGTH-1];
    ((${#NAME}>$LENGTH)) && NAME="/…${NAME:$[${#NAME}-LENGTH+4]}";
    echo "$PRE$NAME"
}

PS1=${CCODE}'\u\[\033[00m\]@\[\033[01;33m\]\h\[\033[00m\]:\[\033[01;34m\]$(_PS1 "$PWD" 20)\[\033[00m\]\$ '



# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


function source_debuntu_master {
  source <(curl https://raw.githubusercontent.com/DrTom/debuntu_setup_scripts/master/bin/debuntu_fun.sh)
}

function source_debuntu_wip {
    source <(curl https://raw.githubusercontent.com/DrTom/debuntu_setup_scripts/wip/bin/debuntu_fun.sh)
}

EOF

