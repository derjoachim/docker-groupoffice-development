#!/bin/sh
set -e

# These packages are needed apt-get install -y iproute2 host
echo "Setting up host.docker.internal"

# For supporting host.docker.internal on Linux. See https://github.com/docker/for-linux/issues/264
if ! host -t A "host.docker.internal" > /dev/null
then
    echo "Adding host.docker.internal to /etc/hosts"
    ip -4 route list match 0/0 | awk '{print $3 " host.docker.internal"}' >> /etc/hosts
else
    echo "host.docker.internal already defined"
fi

DIR="$(pwd)";

if [ ! -d "/usr/local/share/src/www/vendor" ]; then
  echo "Building after first start"
  /usr/local/share/src/scripts/build.sh;
fi

cd $DIR;

echo "Calling original with $@"
# call original
docker-go-entrypoint.sh "$@"
