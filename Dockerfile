# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build binary
RUN go build -o tasky main.go

# Stage 2: Runtime
FROM alpine:3.18

WORKDIR /root/

# Add Wiz exercise file
COPY wizexercise.txt /wizexercise.txt

# Copy binary + assets
COPY --from=builder /app/tasky .
COPY --from=builder /app/assets ./assets

EXPOSE 3000

CMD ["./tasky"]
