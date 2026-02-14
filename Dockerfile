FROM golang:1.21-alpine AS builder
WORKDIR /app
RUN apk add --no-cache git
COPY BillionMail/ .
RUN go mod init github.com/alaouiii/BillionMail || true
RUN go mod tidy
RUN go build -o billionapp ./core/main.go

FROM alpine:latest
RUN apk add --no-cache ca-certificates
WORKDIR /root/
COPY --from=builder /app/billionapp .
EXPOSE 8080
CMD ["./billionapp"]
