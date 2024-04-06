LOCATION=europe-west3-docker.pkg.dev
PROJECT_ID=prometheus-devops-course
REPOSITORY=gcr-docker-demo
APP=${shell basename $(shell git remote get-url origin)}
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=${shell uname | tr '[:upper:]' '[:lower:]'}
TARGETARCH=${shell dpkg --print-architecture}

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v	

get:
	go get

#build: format get
#	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/serhii-cherkez/bot/cmd.appVersion=${VERSION}

linux: format get
	CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/serhii-cherkez/bot/cmd.appVersion=${VERSION}
	docker build . --build-arg="BUILD=linux" -t ${LOCATION}/${PROJECT_ID}/${REPOSITORY}/${APP}:${VERSION}-${TARGETARCH}

macos: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=${TARGETARCH} go build -v -o kbot -ldflags "-X="github.com/serhii-cherkez/bot/cmd.appVersion=${VERSION}
	docker build . --build-arg="BUILD=macos" -t ${LOCATION}/${PROJECT_ID}/${REPOSITORY}/${APP}:${VERSION}-${TARGETARCH}

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -v -o kbot -ldflags "-X="github.com/serhii-cherkez/bot/cmd.appVersion=${VERSION}
	docker build . --build-arg="BUILD=windows" -t ${LOCATION}/${PROJECT_ID}/${REPOSITORY}/${APP}:${VERSION}-amd64 

arm: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/serhii-cherkez/bot/cmd.appVersion=${VERSION}
	docker build . --build-arg="BUILD=arm" -t ${LOCATION}/${PROJECT_ID}/${REPOSITORY}/${APP}:${VERSION}-arm

#image:
#	docker build . --build-arg="BUILD=build" -t ${LOCATION}/${PROJECT_ID}/${REPOSITORY}/${APP}:${VERSION}-${TARGETARCH}
	

push:
	docker push ${LOCATION}/${PROJECT_ID}/${REPOSITORY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi -f ${LOCATION}/${PROJECT_ID}/${REPOSITORY}/${APP}:${VERSION}-${TARGETARCH}