# https://github.com/alphabet5/zshrc/blob/43eafd41c7e304d7ed9f773cf854347afbfeaf0a/fun/jira.sh
#
jira() {
  python3.12 "$HOME"/configs/rtx/python/j.py "$@"
}
