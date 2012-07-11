# ~/.bashrc
#

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Colours
txtblk='\[\033[0;30m\]' # Black - Regular
txtred='\[\033[0;31m\]' # Red
txtgrn='\[\033[0;32m\]' # Green
txtylw='\[\033[0;33m\]' # Yellow
txtblu='\[\033[0;34m\]' # Blue
txtpur='\[\033[0;35m\]' # Purple
txtcyn='\[\033[0;36m\]' # Cyan
txtwht='\[\033[0;37m\]' # White
bldblk='\[\033[1;30m\]' # Black - Bold
bldred='\[\033[1;31m\]' # Red
bldgrn='\[\033[1;32m\]' # Green
bldylw='\[\033[1;33m\]' # Yellow
bldblu='\[\033[1;34m\]' # Blue
bldpur='\[\033[1;35m\]' # Purple
bldcyn='\[\033[1;36m\]' # Cyan
bldwht='\[\033[1;37m\]' # White
unkblk='\[\033[4;30m\]' # Black - Underline
undred='\[\033[4;31m\]' # Red
undgrn='\[\033[4;32m\]' # Green
undylw='\[\033[4;33m\]' # Yellow
undblu='\[\033[4;34m\]' # Blue
undpur='\[\033[4;35m\]' # Purple
undcyn='\[\033[4;36m\]' # Cyan
undwht='\[\033[4;37m\]' # White
bakblk='\[\033[40m\]'   # Black - Background
bakred='\[\033[41m\]'   # Red
bakgrn='\[\033[42m\]'   # Green
bakylw='\[\033[43m\]'   # Yellow
bakblu='\[\033[44m\]'   # Blue
bakpur='\[\033[45m\]'   # Purple
bakcyn='\[\033[46m\]'   # Cyan
bakwht='\[\033[47m\]'   # White
txtrst='\[\033[0m\]'    # Text Reset

export EDITOR="emacsclient -nw"
export VISUAL="$EDITOR"
export TERM='xterm-256color'

# Add directory to PATH if it exists and is not already there.
# TODO: abstract "in path" out to a function
prepend_path() {
    to_add=$1
    if [ -d $to_add ]; then
        export PATH=$to_add:$PATH
    fi
}

append_path() {
    to_add=$1
    if [ -d $to_add ]; then
        export PATH=$PATH:$to_add
    fi
}

find_emacs() {
    # finds my Emacs install
    if [ `uname` = "Darwin" ]; then
        if [ -d /usr/local/Cellar/emacs ]; then
            dir="/usr/local/Cellar/emacs"
            emacsen=$(find "$dir" -name Emacs -type f | head -n 1)
        fi

        if [ -n "$emacsen" ]; then
            emacsbin=$(find "$dir" -name emacs -type f | head -n 1)

            if [ ! -e "$emacsbin" ]; then
                alias emacs="$emacsen"
            fi

            emacsclient=$(find "$dir" -name emacsclient -type f | head -n 1)
            emacsdir=$(dirname $emacsclient)
            prepend_path $emacsdir
        fi
    fi
}

find_git() {
    # it's recommended *not* to put /usr/local/bin before /usr/bin
    # because there might be system dependencies - however if I don't
    # do something, XCode's Git ends up before my custom one in the
    # path.
    if [ -e /usr/local/bin/git ]; then
        git=$(readlink /usr/local/bin/git)
        gitdir=$(dirname $git)
        prepend_path "/usr/local/bin/$gitdir"
    fi
}

find_brew() {
    # explicitly put homebrew bin in PATH, as other shells might not
    # find it
    if [ `uname` = "Darwin" ]; then
        brewpath=$(command -v brew)
        brewdir=$(dirname $brewpath)
        append_path $brewdir
        if [ -f `brew --prefix`/etc/bash_completion ]; then
            . `brew --prefix`/etc/bash_completion
        fi
    fi
}

# Show stuff in prompt
precmd() {

    # my Tmux config has the host already, so we can hide it from the
    # prompt.
    if [ $TMUX_PANE ]; then
        PS1=""
    elif [ $SSH_CONNECTION ]; then
        PS1="${txtrst}${txtred}\h${txtrst} "
    else
        PS1="${txtrst}${txtpur}\h${txtrst} "
    fi

    PS1="${PS1}${txtrst}${txtgrn}\w \$${txtrst} "

    if git branch >& /dev/null; then
        PS1="${txtrst}${bakylw}${bldblk} $(git branch --no-color | grep '^*' | cut -d ' ' -f 2-) ${txtrst} ${PS1}"
    fi

    if [ $RUBY_VERSION ]; then
        PS1="${txtrst}${txtwht}${bakred} ${RUBY_VERSION} ${txtrst} ${PS1}"
    fi
}

PROMPT_COMMAND=precmd

PS2="%F{$prompt_fg}%K{$prompt_bg}${PS2}%f%k"
PS3="%F{$prompt_fg}%K{$prompt_bg}${PS3}%f%k"
PS4="%F{$prompt_fg}%K{$prompt_bg}${PS4}%f%k"

find_emacs
find_git
find_brew

export PATH
