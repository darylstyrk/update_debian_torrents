#!/bin/bash

# URL for the Debian CD torrents
URL_CD="https://cdimage.debian.org/debian-cd/current/amd64/bt-cd/"
# URL for the Debian DVD torrents
URL_DVD="https://cdimage.debian.org/debian-cd/current/amd64/bt-dvd/"
# Directory to store the downloaded torrents
TORRENT_DIR="$HOME/.torrents/"

# Function to ensure required packages are installed
# It checks if the packages 'lynx' and 'wget' are installed, and if not, attempts to install them.
ensure_packages() {
  for package in lynx wget; do
    if ! dpkg -s "$package" &> /dev/null; then
      echo "$package is not installed. Attempting to install."
      apt-get install -y "$package" || { echo "Failed to install $package"; exit 1; }
    else
      echo "$package is already installed."
    fi
  done
}

# Function to check if the torrent directory is empty
# It checks if the directory defined by the TORRENT_DIR variable is empty.
# Returns true if the directory is empty, false otherwise.
is_torrent_dir_empty() {
  [ -z "$(ls -A "$TORRENT_DIR")" ]
}

# Function to fetch torrents from a given URL
# It fetches the torrents from the URL passed as an argument.
# Uses 'lynx' to dump the webpage content, 'awk' to filter out the torrent links,
# 'sort' to remove duplicates, and 'wget' to download the torrents.
# Arguments:
#   $1 - The URL to fetch torrents from
fetch_torrents() {
  echo "Fetching torrents from $1"
  lynx --dump "$1" | awk '/\.torrent$/ {print $NF}' | sort -u | xargs -I {} wget -c -P "$TORRENT_DIR" {} || { echo "Failed to fetch torrents"; exit 1; }
}

# Function to check for new Debian version and fetch the torrents if needed
# It checks for a new Debian version by comparing the current Debian version with the version available on the Debian CD torrent page.
# If the versions do not match, or if the torrent directory is empty, it fetches the torrents from the CD and DVD torrent pages.
check_4_new() {
  echo "Checking for new Debian version..."
  STABLE=$(lynx --dump "$URL_CD" | awk '/\.torrent$/ {print $NF}' | grep -m1 -oP "\d{2}\.\d?" || { echo "Failed to determine stable version"; exit 1; })
  CURRENT=$(</etc/debian_version)
  echo "Stable version: $STABLE, Current version: $CURRENT"
  if [[ $STABLE != $CURRENT ]] || is_torrent_dir_empty; then
    fetch_torrents "$URL_CD"
    fetch_torrents "$URL_DVD"
  else
    echo "Current version matches stable version and torrents are already downloaded. Exiting."
  fi
}

# Ensure required packages are installed
ensure_packages

# Call the check_4_new function
check_4_new