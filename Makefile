.PHONY: all build clean run proto generate test

all: build

build:
	go build -o tui-server ./cmd/server

clean:
	rm -f tui-server
	rm -f proto/*.pb.go

run: build
	./tui-server

proto:
	rm -f proto/*.pb.go
	buf generate

generate: proto

test:
	go test ./...

lint:
	golangci-lint run ./...
