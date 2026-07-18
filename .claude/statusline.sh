#!/bin/bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

user=$(whoami)
host=$(hostname -s)
time=$(date +"%H:%M:%S")

cd "$cwd" 2>/dev/null

# virtual_env: "(venv) " when inside a direnv-managed venv
venv=""
if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
	venv="($(basename "$VIRTUAL_ENV")) "
fi

# git_prompt: "(branch)"
git_info=""
branch=$(git --no-optional-locks branch 2>/dev/null | grep '^\*' | colrm 1 2)
[[ -n "$branch" ]] && git_info="($branch)"

# tf_ws_prompt: "(workspace)" when not "default"
tf_info=""
if [[ -f ".terraform/environment" ]]; then
	tfws=$(cat .terraform/environment)
	[[ "$tfws" != "default" ]] && tf_info="($tfws)"
fi

# aws_profile_prompt / aws_region_prompt
aws_profile_info=""
[[ -n "$AWS_PROFILE" ]] && aws_profile_info="($AWS_PROFILE)"
aws_region_info=""
[[ -n "$AWS_DEFAULT_REGION" ]] && aws_region_info="($AWS_DEFAULT_REGION)"

# kube_ps1 approximation: current kubectl context
kube_info=""
if command -v kubectl >/dev/null 2>&1; then
	ctx=$(kubectl config current-context 2>/dev/null)
	[[ -n "$ctx" ]] && kube_info="($ctx)"
fi

# nix_prompt: "(nix)" when inside a nix shell
nix_info=""
[[ -n "$IN_NIX_SHELL" ]] && nix_info="(nix)"

# Context-usage bar (from the previous statusline)
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '▓')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '░')"

printf '%s[%s] \033[01;32m%s@%s\033[00m : \033[01;34m%s\033[00m %s%s%s%s%s%s [%s] %s %s%%\n' \
	"$venv" "$time" "$user" "$host" "$cwd" \
	"$git_info" "$tf_info" "$aws_profile_info" "$aws_region_info" "$kube_info" "$nix_info" \
	"$MODEL" "$BAR" "$PCT"
