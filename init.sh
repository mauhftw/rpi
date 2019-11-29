#!/usr/bin/env bash
# This script is intended to be used to install rpi dependencies
# and setup media services

set -e

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Source common environment variables
source ${TOOL_ROOT}/configs/common/env.sh

# TODO: use some secret manager to override sensitive data

# Start-up services
docker-compose up -d
