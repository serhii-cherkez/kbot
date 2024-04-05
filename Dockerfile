FROM golang:1.22 as builder
WORKDIR /go/src/app
COPY . .
RUN CGO_ENABLED=0 make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]