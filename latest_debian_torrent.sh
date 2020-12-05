#!/bin/bash -x
	STABLE="$(lynx --dump https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/ | awk '/\.torrent$/ {print $NF}' | grep -m1 -oP "\d{2}\.\d?\.\d?")"
	UPSTREAM="$(grep * /etc/debian_version)"

check_4_new() {
	if [[ ${$STABLE} != ${UPSTREAM} ]] ; then
		fetch_CDs
		fetch_DVDs
	fi
}

fetch_CDs() {
	lynx --dump https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/ | awk '/\.torrent$/ {print $NF}' | while read; do wget -c -P ~/.torrents/ ${REPLY} ; done
	}

fetch_DVDs(){ 
	lynx --dump https://cdimage.debian.org/debian-cd/current/amd64/bt-dvd/ | awk '/\.torrent$/ {print $NF}' | while read; do wget -c -P ~/.torrents/ ${REPLY} ; done
	}	

fetch_CDs
fetch_DVDs