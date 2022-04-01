#!/bin/bash

#   Copyright The containerd Authors.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Inspired from: https://github.com/containerd/containerd/blob/v1.6.1/contrib/Dockerfile.test.d/cri-in-userns/docker-entrypoint.sh

set -eu -o pipefail

# Check 4294967295 to detect UserNS (https://github.com/opencontainers/runc/blob/v1.0.0/libcontainer/userns/userns_linux.go#L29-L32)
if grep -Eq "0[[:space:]]+0[[:space:]]+4294967295" /proc/self/uid_map; then
    echo >&2 "ERROR: Needs to be executed in UserNS (i.e., rootless Docker/Podman/nerdctl)"
    exit 1
fi

if [ ! -f "/sys/fs/cgroup/cgroup.controllers" ]; then
    echo >&2 "ERROR: Needs cgroup v2: https://rootlesscontaine.rs/getting-started/common/cgroup2/#enabling-cgroup-v2"
    exit 1
fi

for f in cpu memory pids; do
    if ! grep -qw "$f" "/sys/fs/cgroup/cgroup.controllers"; then
        echo >&2 "ERROR: Needs cgroup v2 controller ${f} to be delegated: https://rootlesscontaine.rs/getting-started/common/cgroup2/#enabling-cpu-cpuset-and-io-delegation"
        exit 1
    fi
done

echo >&2 "Enabling cgroup v2 nesting"
# https://github.com/moby/moby/blob/v20.10.7/hack/dind#L28-L38
mkdir -p /sys/fs/cgroup/init
xargs -rn1 </sys/fs/cgroup/cgroup.procs >/sys/fs/cgroup/init/cgroup.procs || :
sed -e 's/ / +/g' -e 's/^/+/' </sys/fs/cgroup/cgroup.controllers \
    >/sys/fs/cgroup/cgroup.subtree_control

set -x
echo >&2 "Running containerd in background"
containerd &

echo >&2 "Waiting for containerd"
until ctr plugins list; do sleep 3; done

exec "$@"
