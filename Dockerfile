FROM docker.io/library/alpine:3.12.1 as elm
RUN wget -O - 'https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz' \
    | gunzip -c >/usr/local/bin/elm
RUN chmod +x /usr/local/bin/elm
RUN apk add --no-cache npm
RUN npm install --unsafe-perm -g elm-test@0.19.1-revision4 elm-format http-server esbuild
ENV HOME /elm
WORKDIR /elm
VOLUME /elm

