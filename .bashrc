# shellcheck shell=bash disable=SC2003,SC1090,SC1091,SC2046,SC2063,SC2086,SC2155,SC2027

# TODO: I probably don't actually want this, but need to fix it when I have time:
# ln -s /dev/null /Users/josephfreeland/.local/state/nvim/lsp.log

#set -x
#DEBUG=1
# rm /opt/homebrew/etc/bash_completion.d/multipass
#trap 'echo -n $(/opt/homebrew/bin/gdate +"%T.%3N") && echo' DEBUG

# If not running interacative don't do anything
[ -z "$PS1" ] && return

function print_time {
	echo "start: $(gdate "+%T.%N")"
}

# ssh-agent
function sshagent_findsockets {
	# TODO: This should actually be /private/tmp on Mac.  Clearly not adding
	# value.  There's probably a better way.
	find /tmp -uid "$(id -u)" -type s -name agent.\* 2>/dev/null
}

function sshagent_testsocket {
	if [ ! -x "$(which ssh-add)" ]; then
		echo "ssh-add is not available; agent testing aborted"
		return 1
	fi

	if [ X"$1" != X ]; then
		export SSH_AUTH_SOCK=$1
	fi

	if [ X"$SSH_AUTH_SOCK" = X ]; then
		return 2
	fi

	if [ -S "$SSH_AUTH_SOCK" ]; then
		ssh-add -l >/dev/null
		if [ $? = 2 ]; then
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
	if sshagent_testsocket; then AGENTFOUND=1; fi

	# If there is no agent in the environment, search /tmp for
	# possible agents to reuse before starting a fresh ssh-agent
	# process.
	if [ $AGENTFOUND = 0 ]; then
		for agentsocket in $(sshagent_findsockets); do
			if [ $AGENTFOUND != 0 ]; then break; fi
			if sshagent_testsocket "$agentsocket"; then AGENTFOUND=1; fi
		done
	fi

	# If at this point we still haven't located an agent, it's time to
	# start a new one
	if [ $AGENTFOUND = 0 ]; then
		eval "$(ssh-agent)"
	fi

	# Clean up
	unset AGENTFOUND
	unset agentsocket
}

if [[ "$DEBUG" == "1" ]]; then print_time; fi
sshagent_init

if [ ! -S ~/.ssh/ssh_auth_sock ] && [ -S "$SSH_AUTH_SOCK" ]; then
	ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
fi

if [[ "$DEBUG" == "1" ]]; then print_time; fi
if [ -f "${HOME}/.gpg-agent-info" ]; then
	. "${HOME}/.gpg-agent-info"
	export GPG_AGENT_INFO
	export SSH_AUTH_SOCK
fi

# environment

# Ghostty shell integration
if [[ "$DEBUG" == "1" ]]; then print_time; fi
if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
	builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

## use vi mode for bash
if [[ "$DEBUG" == "1" ]]; then print_time; fi
set -o vi
bind -m vi-command 'Control-l: clear-screen'
bind -m vi-insert 'Control-l: clear-screen'
## Make ctrl+w only delete a word at a time
stty werase undef
bind '\C-w:unix-filename-rubout'

if [[ "$DEBUG" == "1" ]]; then print_time; fi
export BASH_SILENCE_DEPRECATION_WARNING=1
export CLICOLOR=1
# TODO: https://gehrcke.de/2022/11/gcloud-on-python-3-10-module-collections-has-no-attribute-mapping/
#export CLOUDSDK_PYTHON="/usr/bin/python2"
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --smart-case --follow --glob "!{.git,node_modules,vendor}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export GO111MODULE=auto
export GOBIN="$HOME/go/bin"
export GO_SRC_DIR="$HOME/go/src"
# TODO: Should be conditional.  I've let containers reduce my exposure surface.
#export GOOS=$(uname -s)
#export GOARCH=$(uname -m)
export GOPATH="$HOME/go"
export GOPROXY="proxy.golang.org,direct"
export GOSUMDB=sum.golang.org
export GPG_TTY=$(tty)
export TERRAFORM_CONFIG="$HOME/.terraform.d/credentials.tfrc.json"

## avoid duplicates
export HISTCONTROL=ignoredups:erasedups
# TODO: I recently just removed the limit altogether.  Follow up.
export HISTFILESIZE=
## append history entries..
shopt -s histappend
## after each command, save and reload history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# path
export PATH=~/.atuin/bin:~/.dotnet/tools:~/.dapr/bin:~/go/bin:~/.cargo/bin:~/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH

# linuxbrew
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# x11 forwarding
if [ "$(uname)" == "Darwin" ]; then
	export DISPLAY=:0
fi

# editor
if [[ "$DEBUG" == "1" ]]; then print_time; fi
export EDITOR=$(which nvim)

# completions
if [[ "$DEBUG" == "1" ]]; then print_time; fi
shopt -s nullglob
# TODO: I use [[]] and [] inconsistently.
if [[ -d "$HOME/.nix-profile/share/bash-completion/completions" ]]; then
	for i in "$HOME"/.nix-profile/share/bash-completion/completions/*; do
		source "$i"
	done
fi
[[ -f "/usr/local/etc/bash_completion" ]] && source /usr/local/etc/bash_completion
[[ -f "/usr/local/etc/profile.d/bash_completion.sh" ]] && source /usr/local/etc/profile.d/bash_completion.sh
if type brew &>/dev/null; then
	export HOMEBREW_PREFIX="$(brew --prefix)"
	[[ -f "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc" ]] && source "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
	[[ -f "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc" ]] && source "${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
	[[ -f "${HOMEBREW_PREFIX}/share/kube-ps1.sh" ]] && source "${HOMEBREW_PREFIX}/share/kube-ps1.sh"
	[[ -f "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh" ]] && source "${HOMEBREW_PREFIX}/opt/kube-ps1/share/kube-ps1.sh"
	if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
		source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
		for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
			[[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
		done
	fi
fi

[[ -x "$(command -v devbox)" ]] && source <(devbox completion bash)
[[ -x "$(command -v kind)" ]] && source <(kind completion bash)
[[ -x "$(command -v kubectl)" ]] && source <(kubectl completion bash)
[[ -x "$(command -v helm)" ]] && source <(helm completion bash)
[[ -x "$(command -v tilt)" ]] && source <(tilt completion bash)
[[ -x "$(command -v ng)" ]] && source <(ng completion script)

[[ -f '/usr/local/bin/aws_completer' ]] && complete -C '/usr/local/bin/aws_completer' aws
[[ -f '/usr/bin/aws_completer' ]] && complete -C '/usr/bin/aws_completer' aws

[[ -f "$HOME/.asdf/asdf.sh" ]] && source "$HOME"/.asdf/asdf.sh
[[ -f "$HOME/.asdf/completions/asdf.bash" ]] && source "$HOME"/.asdf/completions/asdf.bash
[[ -f "$HOME/.fzf.bash" ]] && source "$HOME"/.fzf.bash
[[ -f '/opt/homebrew/opt/fzf/shell/completion.bash' ]] && source /opt/homebrew/opt/fzf/shell/completion.bash
[[ -f '/opt/homebrew/opt/fzf/shell/key-bindings.bash' ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.bash
[[ -f '/usr/share/doc/fzf/examples/key-bindings.bash' ]] && source /usr/share/doc/fzf/examples/key-bindings.bash

# nix fzf
if [[ "$DEBUG" == "1" ]]; then print_time; fi
if command -v fzf-share >/dev/null; then
	source "$(fzf-share)/key-bindings.bash"
	source "$(fzf-share)/completion.bash"
fi

complete -o default -F __start_kubectl kc
complete -C $(asdf which terraform) terraform
#complete -C $(asdf which boundary) boundary

# prompt
aws_profile_prompt() {
	if [[ "$AWS_PROFILE" != "" ]]; then
		echo "($AWS_PROFILE)"
	fi
}
aws_region_prompt() {
	if [[ "$AWS_DEFAULT_REGION" != "" ]]; then
		echo "($AWS_DEFAULT_REGION)"
	fi
}
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
virtual_env() {
	if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
		echo "($(basename $VIRTUAL_ENV)) "
	fi
}
git_prompt() {
	if [[ $(git branch 2>/dev/null | grep '^*' | colrm 1 2) != "" ]]; then
		echo "("$(git branch 2>/dev/null | grep '^*' | colrm 1 2)")"
	fi
}
## TODO: add kube-ps1 and kube-tmuxp back in the mix?
if [[ "$DEBUG" == "1" ]]; then print_time; fi
if [[ $HOSTNAME =~ "USM" ]]; then
	PS1_USER="joey"
	PS1_HOST="work"
	PS1='$(virtual_env)'"["'$(date +"%H:%M:%S")'"] \[\e]0;${PS1_USER}@${PS1_HOST}: \w\a\]\[\033[01;32m\]${PS1_USER}@${PS1_HOST}\[\033[00m\] : \[\033[01;34m\]\w\[\033[00m\] "'$(git_prompt)$(tf_ws_prompt)$(aws_profile_prompt)$(aws_region_prompt)$(kube_ps1)$(nix_prompt)'" > "
else
	PS1='$(virtual_env)'"["'$(date +"%H:%M:%S")'"] \[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\] : \[\033[01;34m\]\w\[\033[00m\] "'$(git_prompt)$(tf_ws_prompt)$(aws_profile_prompt)$(aws_region_prompt)$(kube_ps1)$(nix_prompt)'" > "
fi

# aliases
ls --color=auto &>/dev/null && alias ls='ls --color=auto'
[[ -f /usr/local/bin/exa ]] && alias ls=exa

alias acd=argocd
alias ag="ag -f"
alias assume=". assume"
alias awswhoami="aws sts get-caller-identity"
#alias awsp="source _awsp"
alias brewup="ACCEPT_EULA=y brew bundle --global | indent"
alias cless="less -r"
alias cmore="more -r"
alias date_tag='date +timestamp_%Y%m%d%H%M%S'
alias dnsflush="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias dnswtf="scutil --dns"
alias ifcme="curl -4 ifconfig.me && echo"
alias kc=kubectl
alias kctx=kubectx
alias kns=kubens
alias ll="ls -lag"
alias mp=multipass
alias pipup="python -m pip install --upgrade pip"
alias vi=nvim
alias vimdiff="nvim -d"
alias watch="watch "

# random functions
function aws-list-instances() {
	aws ec2 describe-instances --region $1 --output=json | jq '.Reservations[].Instances[] | .InstanceId + ", " + .InstanceType + ", " + .PrivateDnsName + ", " + .PublicDnsName + ", " + .Placement.AvailabilityZone'
}
function awsr() {
	if [ $# -eq 1 ]; then
		export AWS_REGION="$1"
		export AWS_DEFAULT_REGION="$1"
		echo "AWS_REGION and AWS_DEFAULT_REGION set to $1"
	else
		echo "Usage: awsr <region>"
	fi
}
function kctxd() {
	if [[ -z "$1" ]]; then
		kubectl config set current-context none --kubeconfig ~/.kube/config
	else
		kubectl config set current-context $1 --kubeconfig ~/.kube/config
	fi
}
function goup() {
	num=$1
	while [ $num -ne 0 ]; do
		cd ..
		num=$(expr $num - 1)
	done
}
function pyup() {
	python3 -m venv venv
	cat <<EOT >.envrc
source venv/bin/activate
EOT
	direnv allow
}
function dirdiff() {
	# Shell-escape each path:
	DIR1=$(printf '%q' "$1")
	shift
	DIR2=$(printf '%q' "$1")
	shift
	nvim "$@" -c "DirDiff $DIR1 $DIR2"
}

# include private config
if [[ "$DEBUG" == "1" ]]; then print_time; fi
[[ -f "$HOME/.private.bash" ]] && source "$HOME"/.private.bash

# include work config
if [[ "$DEBUG" == "1" ]]; then print_time; fi
[[ -f "$HOME/.workrc.bash" ]] && source "$HOME"/.workrc.bash

# include extra functions
if [[ "$DEBUG" == "1" ]]; then print_time; fi
[[ -d "$HOME/configs/dotfiles/extras" ]] && for file in "$HOME"/configs/dotfiles/extras/*.sh; do source "$file"; done

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
export NIX_SHELL_PRESERVE_PROMPT=true
# TODO: direnv being enabled is causing new sessions to print "direnv:
# unloading" and I don't have time to dig right now.
# https://jackma.com/2019/11/23/one-kubectl-context-per-shell-session/
# kubeconfig per session
if [[ "$DEBUG" == "1" ]]; then print_time; fi
file="$(mktemp -t "kubectx.XXXXXX")"
export KUBECONFIG=~/.kube/config
export KUBECONFIG="${file}:${KUBECONFIG}"
cat <<EOF >"${file}"
apiVersion: v1
kind: Config
current-context: ""
EOF
export SHELL=$(which bash)
# ensure compatibility tmux <-> direnv
if [ -n "$TMUX" ] && [ -n "$DIRENV_DIR" ]; then
	unset "${!DIRENV_@}" # unset env vars starting with DIRENV_
fi
export DIRENV_LOG_FORMAT=""
. "$HOME/.cargo/env"
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
#eval "$(atuin init bash)"
if [[ "$DEBUG" == "1" ]]; then print_time; fi
eval "$(direnv hook bash)"

export PATH=/Users/josephfreeland/.groundcover/bin:${PATH}
