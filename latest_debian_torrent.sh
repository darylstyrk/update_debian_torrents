#!/bin/bash 
	STABLE="$(lynx --dump https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/ | awk '/\.torrent$/ {print $NF}' | grep -m1 -oP "\d{2}\.\d?")"
	UPSTREAM="$(</etc/debian_version)"

check_4_new() {
	if [[ ${STABLE} != "${UPSTREAM}" ]] ; then
		fetch_CDs
		fetch_DVDs
	fi
}

fetch_CDs() {
	lynx --dump https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/ | awk '/\.torrent$/ {print $NF}' | sort -u | while read -r; do wget -c -P ~/.torrents/ "${REPLY}" ; done
	}

fetch_DVDs(){ 
	lynx --dump https://cdimage.debian.org/debian-cd/current/amd64/bt-dvd/ | awk '/\.torrent$/ {print $NF}' | sort -u | while read -r; do wget -c -P ~/.torrents/ "${REPLY}" ; done
	}	

check_4_new
