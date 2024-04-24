REPOSITORY=ghcr.io
NAMESPACE=serhii-cherkez
APP=${shell basename $(shell git remote get-url origin)}
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64

format:
	go fmt -n -x ./

lint:
	golint

test:
	go test -v	

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/serhii-cherkez/kbot/cmd.appVersion=${VERSION}

image: build
	docker build . --build-arg="BUILD=build" -t ${REPOSITORY}/${NAMESPACE}:${VERSION}-${TARGETARCH}

push:
	docker push ${REPOSITORY}/${NAMESPACE}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi -f ${REPOSITORY}/${NAMESPACE}:${VERSION}-${TARGETARCH}