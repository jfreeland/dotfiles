if [[ -f "$HOME/.bashrc" ]]; then
	source "$HOME/.bashrc"
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#condaup() {
#	__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
#	if [ $? -eq 0 ]; then
#		eval "$__conda_setup"
#	else
#		if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
#			. "/opt/anaconda3/etc/profile.d/conda.sh"
#		else
#			export PATH="/opt/anaconda3/bin:$PATH"
#		fi
#	fi
#	unset __conda_setup
#}
# <<< conda initialize <<<

#. "$HOME/.atuin/bin/env"
