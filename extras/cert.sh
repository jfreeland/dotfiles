# https://github.com/alphabet5/zshrc/blob/43eafd41c7e304d7ed9f773cf854347afbfeaf0a/fun/cert.sh

cert() {
  host="$1"
  port="${2:-443}"
  openssl s_client -showcerts -verify 5 -connect "$host":"$port" 2>&1
}
