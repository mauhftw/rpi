#!/usr/bin/env bash
# This script is intended to be used to install rpi dependencies
# and setup media services

set -e

# Check if script is being run as root
if [[ $UID != 0 ]]; then
    echo "You must run this script as root"
    exit 1
fi

# Set external disk name
EXTERNAL_DISK="${EXTERNAL_DISK:-"Seagate"}"

# Set locale vars
LOCALE_VARS="LANGUAGE LC_ALL LANG LC_TYPE"

# Set locale type
LOCALE_TYPE="${LOCALE_TYPE:-"en_US.UTF-8"}"

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Set DHCP_CONFIG_FILE, the location of the directory this script is housed in
readonly DHCP_CONFIG_FILE=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )/configs/system/dhcpcd.conf

# Set TRANSMISSION_CONFIG_FILE, the location of the directory this script is housed in
readonly TRANSMISSION_CONFIG_FILE=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )/configs/transmission/settings.json

# Set TRANSMISSION_TMP_CONFIG_FILE, the location of the directory this script is housed in
readonly TRANSMISSION_TMP_CONFIG_FILE=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )/configs/transmission/settings.tmp.json

# Source common environment variables
source ${TOOL_ROOT}/configs/common/env.sh

# Install system deps
apt-get update \
&& apt-get install -y \
apt-transport-https \
ca-certificates \
gnupg2 \
software-properties-common \
htop \
curl \
vim \
jq \
iftop \
git \
tmux \
python3 \
python3-pip \
libffi-dev \
python-backports.ssl-match-hostname \
libssl-dev

# Install pip3
(
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3 get-pip.py
)

# Install docker
curl -sSL https://get.docker.com | sh

# Install docker-compose
runuser -l ${USERNAME} -c "pip3 install docker-compose --user"

# Give docker group permissions
usermod -aG docker ${USERNAME}

# Set static IP configs
envsubst < ${DHCP_CONFIG_FILE} > /etc/dhcpcd.conf

# Set transmission configs
envsubst < ${TRANSMISSION_TMP_CONFIG_FILE} > ${TRANSMISSION_CONFIG_FILE}

# Turn on dhcp server
service dhcpcd start \
&& systemctl enable dhcpcd

# Mount Seagate external disk
DEV=$(lsblk -o VENDOR,NAME -l | grep ${EXTERNAL_DISK} | awk '{print $2}')
echo "/dev/${DEV} /mnt/media ext4 defaults 0 0" >> /etc/fstab
mount -av

# Add Python bin to pi's PATH
runuser -l ${USERNAME} -c  "echo export PATH=${PATH}:~/.local/bin/ >> ~/.bashrc"

# Enable SSH on boot
update-rc.d ssh defaults
update-rc.d ssh enable

# Set locales
for VAR in $(echo ${LOCALE_VARS}); do
    runuser -l ${USERNAME} -c  "echo export ${VAR}=${LOCALE_TYPE}";
done

# restart system
init 6
