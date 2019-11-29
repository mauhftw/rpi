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
&& apt-get install -y
git

# Clone repo
git clone git@github.com:mauhftw/rpi.git \

# Setup system dependencies
${TOOL_ROOT}/rpi/setup.sh
