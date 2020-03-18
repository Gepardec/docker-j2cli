#!/bin/bash

source bashrc

set -e
docker-j2cli-build --no-cache
docker-j2cli sh -c "command -v j2"
set +e