# syntax=docker/dockerfile:1

ARG GO_VERSION="1.19"
ARG RUNNER_IMAGE="gcr.io/distroless/static-debian11"

# --------------------------------------------------------
# Builder
# --------------------------------------------------------

FROM golang:${GO_VERSION}-alpine3.16 AS builder

RUN apk add --update --no-cache curl make git libc-dev bash gcc linux-headers eudev-dev

ADD . .

RUN CGO_ENABLED=1 LDFLAGS='-linkmode external -extldflags "-static"' make install

# Use minimal busybox from infra-toolkit image for final scratch image
FROM ghcr.io/strangelove-ventures/infra-toolkit:v0.0.6 AS busybox-min
RUN addgroup --gid 1000 -S relayer && adduser --uid 100 -S relayer -G relayer

# --------------------------------------------------------
# Runner
# --------------------------------------------------------

# Build final image from scratch
FROM ${RUNNER_IMAGE}

# Install chain binaries
COPY --from=builder /bin/rly /bin/

ENV HOME /relayer
WORKDIR $HOME

# ENTRYPOINT ["rly"]