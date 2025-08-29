#!/bin/bash

# Prepare the environment for MPI e2e tests

# @author  Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

. $DIR/conf.sh

# Always install the correct version of ciux
go install github.com/k8s-school/ciux@"$ciux_version"

# Install dependencies using ciux
ciux ignite -l e2e "$DIR"