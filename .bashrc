# shellcheck shell=bash disable=SC1091


# If not running interacative don't do anything
[ -z "$PS1" ] && return

# ssh-agent
function sshagent_findsockets {
    # TODO: This should actually be /private/tmp on Mac.  Clearly not adding
    # value.  There's probably a better way.
    find /tmp -uid "$(id -u)" -type s -name agent.\* 2>/dev/null
}

function sshagent_testsocket {
    if [ ! -x "$(which ssh-add)" ] ; then
        echo "ssh-add is not available; agent testing aborted"
        return 1
    fi

    if [ X"$1" != X ] ; then
        export SSH_AUTH_SOCK=$1
    fi

    if [ X"$SSH_AUTH_SOCK" = X ] ; then
        return 2
    fi

    if [ -S "$SSH_AUTH_SOCK" ] ; then
        ssh-add -l > /dev/null
        if [ $? = 2 ] ; then
            echo "Socket $SSH_AUTH_SOCK is dead!  Deleting!"
            rm -f "$SSH_AUTH_SOCK"
            return 4
        else
            return 0
        fi
    else
        echo "$SSH_AUTH_SOCK is not a socket!"
        return 3
    fi
}

function sshagent_init {
    # ssh agent sockets can be attached to a ssh daemon process or an
    # ssh-agent process.

    AGENTFOUND=0

    # Attempt to find and use the ssh-agent in the current environment
    if sshagent_testsocket ; then AGENTFOUND=1 ; fi

    # If there is no agent in the environment, search /tmp for
    # possible agents to reuse before starting a fresh ssh-agent
    # process.
    if [ $AGENTFOUND = 0 ] ; then
        for agentsocket in $(sshagent_findsockets) ; do
            if [ $AGENTFOUND != 0 ] ; then break ; fi
            if sshagent_testsocket "$agentsocket" ; then AGENTFOUND=1 ; fi
        done
    fi

    # If at this point we still haven't located an agent, it's time to
    # start a new one
    if [ $AGENTFOUND = 0 ] ; then
        eval "$(ssh-agent)"
    fi

    # Clean up
    unset AGENTFOUND
    unset agentsocket
}

sshagent_init


# environment
## use vi mode for bash
set -o vi
bind -m vi-command 'Control-l: clear-screen'
bind -m vi-insert 'Control-l: clear-screen'
## Make ctrl+w only delete a word at a time
stty werase undef
bind '\C-w:unix-filename-rubout'

export BASH_SILENCE_DEPRECATION_WARNING=1
export CLICOLOR=1
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
export EDITOR=$(which nvim)
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --smart-case --follow --glob "!{.git,node_modules,vendor}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export GO111MODULE=auto
export GO_SRC_DIR="$HOME/go/src"
# TODO: Should be conditional.  I've let containers reduce my exposure surface.
export GOOS="darwin"
export GOPATH="$HOME/go"
export GOPROXY="proxy.golang.org,direct"
export GOSUMDB="off"
export GPG_TTY=$(tty)
export SHELL=$(which bash)

## avoid duplicates
export HISTCONTROL=ignoredups:erasedups
# TODO: I recently just removed the limit altogether.  Follow up.
export HISTFILESIZE=
## append history entries..
shopt -s histappend
## after each command, save and reload history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"


# completions
shopt -s nullglob
# TODO: I use [[]] and [] inconsistently.
if [[ -d "$HOME/.nix-profile/share/bash-completion/completions" ]]; then
    for i in "$HOME"/.nix-profile/share/bash-completion/completions/*; do
        source "$i"
    done
fi
[[ -f "/usr/local/etc/bash_completion" ]] && source /usr/local/etc/bash_completion
[[ -f "/usr/local/etc/profile.d/bash_completion.sh" ]] && source /usr/local/etc/profile.d/bash_completion.sh
[[ -f "/usr/local/opt/asdf/asdf.sh" ]] && source /usr/local/opt/asdf/asdf.sh
[[ -f "/usr/local/opt/asdf/etc/bash_completion.d/asdf.bash" ]] && source /usr/local/opt/asdf/etc/bash_completion.d/asdf.bash

# TODO: this can't be right anymore...
[[ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc' ]] && source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc
[[ -f '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc' ]] && source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc

[[ -x "$(command -v kind)" ]] && source <(kind completion bash)
[[ -x "$(command -v kubectl)" ]] && source <(kubectl completion bash)
[[ -x "$(command -v helm)" ]] && source <(helm completion bash)

[[ -f '/usr/local/bin/aws_completer' ]] && complete -C '/usr/local/bin/aws_completer' aws
[[ -f '/usr/bin/aws_completer' ]] && complete -C '/usr/bin/aws_completer' aws

[[ -f "$HOME/.asdf/asdf.sh" ]] && source "$HOME"/.asdf/asdf.sh
[[ -f "$HOME/.asdf/completions/asdf.bash" ]] && source "$HOME"/.asdf/completions/asdf.bash
[[ -f "$HOME/.fzf.bash" ]] && source "$HOME"/.fzf.bash

# nix fzf
if command -v fzf-share >/dev/null; then
    source "$(fzf-share)/key-bindings.bash"
    source "$(fzf-share)/completion.bash"
fi

complete -o default -F __start_kubectl kc
complete -C $(asdf which terraform) terraform


# path
export PATH=~/go/bin:~/.cargo/bin:~/.local/bin:$PATH


# prompt
nix_prompt() {
    if [[ $IN_NIX_SHELL != "" ]]; then
        # TODO: Want the directory name where I originally started the nix shell.
        echo "(nix)"
    fi
}
tf_ws_prompt() {
  if [ -f ".terraform/environment" ]; then
    if [[ $(cat .terraform/environment) != "default" ]]; then
      echo "("$(cat .terraform/environment)")"
    fi
  fi
}
git_prompt() {
  if [[ $(git branch 2>/dev/null | grep '^*' | colrm 1 2) != "" ]]; then
    echo "("$(git branch 2>/dev/null | grep '^*' | colrm 1 2)")"
  fi
}
## TODO: add kube-ps1 and kube-tmuxp back in the mix?
if [[ $HOSTNAME =~ "-" ]]; then
    PS1_HOST="work"
    PS1="["'$(date +"%H:%M:%S")'"] \[\e]0;\u@${PS1_HOST}: \w\a\]\[\033[01;32m\]\u@${PS1_HOST}\[\033[00m\] : \[\033[01;34m\]\w\[\033[00m\] "'$(git_prompt)$(tf_ws_prompt)$(nix_prompt)'" > "
else
    PS1="["'$(date +"%H:%M:%S")'"] \[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\] : \[\033[01;34m\]\w\[\033[00m\] "'$(git_prompt)$(tf_ws_prompt)$(nix_prompt)'" > "
fi


# aliases
ls --color=auto &> /dev/null && alias ls='ls --color=auto'
[[ -f /usr/local/bin/exa ]] && alias ls=exa

alias ag="ag -f"
#alias awsp="source _awsp"
alias date_tag='date +timestamp_%Y%m%d%H%M%S'
alias cless="less -r"
alias cmore="more -r"
alias jfr="cd ~/go/src/github.com/jfreeland"
alias kc=kubectl
alias kctx=kubectx
alias kns=kubens
alias ll="ls -lag"
alias vi=nvim
alias vimdiff="nvim -d"
alias watch="watch "


# random functions
function aws-list-instances() {
	aws ec2 describe-instances --region $1 --output=json | jq '.Reservations[].Instances[] | .InstanceId + ", " + .InstanceType + ", " + .PrivateDnsName + ", " + .PublicDnsName + ", " + .Placement.AvailabilityZone'
}

function goup() {
  num=$1
  while [ $num -ne 0  ];do
    cd ..
    num=$( expr $num - 1 )
  done
}

# include private config
[[ -f "$HOME/.private.bash" ]] && source "$HOME"/.private.bash

# include work config
[[ -f "$HOME/.workrc.bash" ]] && source "$HOME"/.workrc.bash


# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
export NIX_SHELL_PRESERVE_PROMPT=true
eval "$(direnv hook bash)"
