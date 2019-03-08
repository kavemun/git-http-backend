FROM golang:alpine as builder

ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go

COPY . /go/src/github.com/asim/git-http-backend

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		git \
		gcc \
		libc-dev \
		libgcc \
		make \
	&& cd /go/src/github.com/asim/git-http-backend \
	&& make static \
	&& mv git-http-backend /usr/bin/git-http-backend \
	&& apk del .build-deps \
	&& rm -rf /go \
	&& echo "Build complete."

FROM alpine:3.9

RUN apk add --no-cache git

COPY --from=builder /usr/bin/git-http-backend /usr/bin/git-http-backend

VOLUME [ "/repositories" ]

ENTRYPOINT [ "git-http-backend" ]
CMD [ "--git_bin_path=/usr/bin/git", "--project_root=/repositories" ]
