# build stage
FROM golang:alpine AS builder

WORKDIR /app

COPY go.mod main.go ./

RUN go mod download

RUN go build -o /hello

# run stage
FROM alpine:latest AS runner

WORKDIR /app

COPY --from=builder /hello /app/hello

EXPOSE 80

CMD ["./hello"]
