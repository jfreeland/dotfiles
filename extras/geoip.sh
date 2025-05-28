geoip() {
	docker run -it --rm -e GEOIPUPDATE_EDITION_IDS="GeoIP2-City" -e GEOIPUPDATE_ACCOUNT_ID="${GEOIPUPDATE_ACCOUNT_ID}" -e GEOIPUPDATE_LICENSE_KEY="${GEOIPUPDATE_LICENSE_KEY}" -e GEOIPUPDATE_FREQUENCY="0" -e GEOIPUPDATE_DB_DIR="/usr/share/geoip" -v ./geoip:/usr/share/geoip ghcr.io/maxmind/geoipupdate:v7.0.1
}
