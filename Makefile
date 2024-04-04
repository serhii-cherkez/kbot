VERSION:1.0.5

format:
	gofmt -s -w ./

build:
	go build -v -o kbot -ldflags "-X="github.com/serhii-cherkez/bot/cmd.appVersion={$VERSION}