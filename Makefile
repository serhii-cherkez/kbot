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

image:
	docker build . --build-arg="BUILD=build" -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -rf kbot
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}