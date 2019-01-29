# Copyright 2017 The Kubernetes Authors.
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

# builder image
FROM golang as builder

WORKDIR /go/src/github.com/kubernetes-incubator/external-dns
COPY . .
RUN make dep
RUN mkdir -p $GOPATH/src/golang.org/x/sys && \
mkdir -p $GOPATH/src/golang.org/x/net && \
mkdir -p $GOPATH/src/golang.org/x/time && \
mkdir -p $GOPATH/src/golang.org/x/oauth2 && \
mkdir -p $GOPATH/src/google.golang.org/genproto && \
mkdir -p $GOPATH/src/golang.org/protobuf && \
mkdir -p $GOPATH/src/github.com/golang/protobuf && \
mkdir -p $GOPATH/src/golang.org/x/crypto && \
mkdir -p $GOPATH/src/golang.org/x/text && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-sys/* $GOPATH/src/golang.org/x/sys/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-net/* $GOPATH/src/golang.org/x/net/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-time/* $GOPATH/src/golang.org/x/time/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-oauth2/* $GOPATH/src/golang.org/x/oauth2/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-google-go--genproto/* $GOPATH/src/google.golang.org/genproto/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-protobuf/* $GOPATH/src/golang.org/protobuf/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-protobuf/* $GOPATH/src/github.com/golang/protobuf/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-crypto/* $GOPATH/src/golang.org/x/crypto/. && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-text/* $GOPATH/src/golang.org/x/text/. && \
mkdir -p $GOPATH/src/cloud.google.com/go && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-googleapis-google--cloud--go/* $GOPATH/src/cloud.google.com/go/. && \
mkdir -p $GOPATH/src/google.golang.org/api && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-googleapis-google--api--go--client/* $GOPATH/src/google.golang.org/api/. && \
mkdir -p $GOPATH/src/google.golang.org/appengine && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-golang-appengine/* $GOPATH/src/google.golang.org/appengine/. && \
mkdir -p $GOPATH/src/google.golang.org/genproto && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-google-go--genproto/. $GOPATH/src/google.golang.org/genproto/. && \
mkdir -p $GOPATH/src/google.golang.org/grpc && \
cp -rf $GOPATH/pkg/dep/sources/https---github.com-grpc-grpc--go/* $GOPATH/src/google.golang.org/grpc/.
RUN make test
RUN make build

# final image
FROM alpine:latest
LABEL maintainer="Team Teapot @ Zalando SE <team-teapot@zalando.de>"

COPY --from=builder /go/src/github.com/kubernetes-incubator/external-dns/build/external-dns /bin/external-dns
COPY --from=builder /usr/local/go/lib/time/zoneinfo.zip /usr/local/go/lib/time/zoneinfo.zip

USER nobody

ENTRYPOINT ["/bin/external-dns"]
