# Stage 1: Build
FROM golang:1.22-alpine AS builder

ARG VERSION=dev

WORKDIR /app

COPY go.mod ./
COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-X main.version=${VERSION}" \
    -o server \
    .

# Stage 2: Final image
FROM gcr.io/distroless/static:nonroot

COPY --from=builder /app/server /server

USER nonroot

EXPOSE 8080

ENTRYPOINT ["/server"]
