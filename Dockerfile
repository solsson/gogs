FROM golang:1.12.7-alpine@sha256:87e527712342efdb8ec5ddf2d57e87de7bd4d2fedf9f6f3547ee5768bb3c43ff AS binarybuilder
# Install build deps
RUN apk --no-cache --no-progress add --virtual build-deps build-base git
WORKDIR /go/src/github.com/gogs/gogs
COPY . .
RUN make build TAGS="sqlite"

FROM alpine:3.10@sha256:6a92cd1fcdc8d8cdec60f33dda4db2cb1fcdcacf3410a8e05b3741f44a9b5998
# Install system utils & Gogs runtime dependencies
RUN apk --no-cache --no-progress add \
    bash \
    ca-certificates \
    curl \
    git \
    tzdata

ENV GOGS_CUSTOM /data/gogs

WORKDIR /app/gogs
COPY docker ./docker
COPY templates ./templates
COPY public ./public
COPY --from=binarybuilder /go/src/github.com/gogs/gogs/gogs .

RUN ./docker/finalize.sh

RUN mkdir /data /data/gogs /data/gogs/conf /data/logs \
  && chown -R git /data
USER git:git

EXPOSE 3000
ENTRYPOINT ["/app/gogs/gogs","web"]
