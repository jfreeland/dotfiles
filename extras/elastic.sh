function es-bulk() {
	curl -H content-type:application/x-ndjson -X POST \
		-H "Authorization: Basic ${ELASTIC_CREDENTIALS}" \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/_bulk?filter_path=took,errors,items.*.error" \
		-s -w "\n" --data-binary "@-" -v
}
function es-put-index() {
	curl -H content-type:application/x-ndjson -X PUT \
		-H "Authorization: Basic ${ELASTIC_CREDENTIALS}" \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/${1#/}?filter_path=took,errors,items.*.error" \
		-s -w "\n" --data-binary "@-"
}

function es-bulk-file() {
	curl -H content-type:application/x-ndjson -X POST \
		-H "Authorization: Basic ${ELASTIC_CREDENTIALS}" \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/_bulk?filter_path=took,errors,items.*.error" \
		-s -w "\n" -T $1 -v
}

function es-field-data() {
	curl -H "Authorization: Basic ${ELASTIC_CREDENTIALS}" -X POST \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/_cache/clear?fielddata=true"
}

function es-stats() {
	curl -H "Authorization: Basic ${ELASTIC_CREDENTIALS}" -X GET \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/_cat/nodes?v=true&h=name,node*,heap*"
}

function es-put() {
	curl -H content-type:application/x-ndjson -X PUT \
		-H "Authorization: Basic ${ELASTIC_CREDENTIALS}" \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/$1" \
		--data $2
}

function es-get() {
	curl -H "Authorization: Basic ${ELASTIC_CREDENTIALS}" -X GET \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/$1"
}

function es-post() {
	curl -H "Authorization: Basic ${ELASTIC_CREDENTIALS}" -X POST \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/$1"
}

function es-roll() {
	curl -H "Authorization: Basic ${ELASTIC_CREDENTIALS}" -X POST \
		"https://${ELASTIC_HOST}:${ELASTIC_PORT}/$1/_rollover"
}
