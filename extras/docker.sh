function ds() {
	function search() {
		echo "looking for ${1}..."
		NAME=$(curl -s "${DOCKER_REGISTRY}/v2/_catalog?n=1000" | jq -r '.repositories[]' | grep "${1}")
		while IFS= read -r line; do
			echo "$line"
			tags=$(curl -s "${DOCKER_REGISTRY}/v2/${line}/tags/list" | jq -r '.tags[]' | sort)
			while IFS= read -r t; do
				echo "  $t"
			done <<<"$tags"
		done <<<"$NAME"
	}

	if [ $# -eq 0 ]; then
		curl -s "${DOCKER_REGISTRY}/v2/_catalog?n=1000" | jq -r '.repositories[]'
	else
		search "$1"
	fi
}
