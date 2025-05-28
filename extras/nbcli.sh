# https://github.com/alphabet5/zshrc/blob/43eafd41c7e304d7ed9f773cf854347afbfeaf0a/fun/nbcli.sh

function nb() {
	"$HOME"/configs/dotfiles/extras/python/nb.py "$@"
}

function nb-device() {
	curl -H "Authorization: Token $NETBOX_TOKEN" \
		-H "Content-Type: application/json" "$NETBOX_URL/api/dcim/devices/${1}/" 2>/dev/null | jq
}

function nb-interface() {
	curl -H "Authorization: Token $NETBOX_TOKEN" \
		-H "Content-Type: application/json" "$NETBOX_URL/api/dcim/interfaces/${1}/" 2>/dev/null | jq
}

function nb-devices() {
	curl -H "Authorization: Token $NETBOX_TOKEN" \
		-H "Content-Type: application/json" "$NETBOX_URL/api/dcim/devices/?limit=0" 2>/dev/null | jq
}
