FROM golang:1.24-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o tui-server ./cmd/server

FROM alpine:latest

RUN apk --no-cache add ca-certificates python3

WORKDIR /root/

COPY --from=builder /app/tui-server .
COPY web /root/web
COPY start.sh .

RUN chmod +x start.sh

EXPOSE 2222 8080

CMD ["./start.sh"]
