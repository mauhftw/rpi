#!/usr/bin/env bash
# This script is intended to be used to install rpi dependencies
# and setup media services

set -e

# Check if script is being run as root
if [[ $UID != 0 ]]; then
    echo "You must run this script as root"
    exit 1
fi


# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Install system deps
apt-get update \
&& apt-get install -y git

# Check if rpi repo exists, clone the repo
if find . -type d -name 'rpi' -exec rm -rf {} +; then
    git clone https://github.com/mauhftw/rpi.git
fi

# Setup system dependencies
${TOOL_ROOT}/rpi/setup.sh
