# syntax=docker/dockerfile:1
FROM rustlang/rust:nightly AS builder

ARG BINARY=nexus-cli

WORKDIR /app

COPY cli cli
COPY tools tools
COPY sdk sdk
COPY toolkit-rust toolkit-rust

COPY Cargo.lock Cargo.lock
COPY Cargo.toml Cargo.toml

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target/release \
    --mount=type=ssh <<EOT
    cargo build \
    -Zgit=shallow-deps,shallow-index \
    --profile release \
    --bin ${BINARY} 
    cp -t /app \
        target/release/${BINARY}
EOT

FROM gcr.io/distroless/cc-debian12

ARG BINARY=nexus-cli

COPY --from=builder /app/${BINARY} /

ENV PORT=8080
