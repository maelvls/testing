# Copyright 2021 The Jetstack contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Includes bazel, make, node, go, goversion, jq
ARG BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL maintainer="cert-manager-maintainers@googlegroups.com"

ARG NODE_VERSION
# install goversion, gcrane, gh cli, jq and node
RUN go install github.com/rsc/goversion@v1.2.0 && \
    go install github.com/google/go-containerregistry/cmd/gcrane@v0.6.0 && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y \
    gh=2.1.0 \
    jq=1.5+dfsg-2+b1 \
    nodejs=${NODE_VERSION}

# Add GOPATH/bin to PATH
ENV PATH=/root/go/bin:$PATH
