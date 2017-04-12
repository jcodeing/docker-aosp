#!/bin/bash
set -ex

# This script designed to be used a docker ENTRYPOINT [Custom Replace original]
# default Root

# Example:
#
#  docker run -ti --rm -v ../docker_entrypoint.sh:/root/docker_entrypoint.sh imagename bash
#

echo "..Docker Entrypoint Custom.."

bash