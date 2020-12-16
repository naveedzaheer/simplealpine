# BUILD STAGE
#
	FROM golang:1.8.3-alpine3.6 AS confd-build-stage
	WORKDIR /go/src/github.com/kei-sato
	RUN apk --update add git bash
	RUN git clone --depth 1 https://github.com/kei-sato/http-echo.git \
	    && cd http-echo \
	    && go build -o bin/http-echo . \
	    && chmod +x bin/http-echo


# PACKAGING STAGE
#
	FROM alpine

	RUN apk --update add openssh tini  \
	    && rm -rf /var/cache/apk/* \
	    && rm -rf /root/.cache

	COPY --from=confd-build-stage /go/src/github.com/kei-sato/http-echo/bin/http-echo /usr/local/bin/

	COPY ./ssh-config /etc/ssh
	COPY ./entrypoint.sh /entrypoint.sh

	ENTRYPOINT ["/sbin/tini", "--"]
	EXPOSE 2222 80

	CMD ["/entrypoint.sh"]
