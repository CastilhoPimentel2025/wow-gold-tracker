FROM alpine:latest

RUN apk add --no-cache \
    lua5.1 \
    luarocks \
    zip \
    bash

RUN luarocks install luacheck

WORKDIR /app

COPY . .

CMD ["luacheck", "addon"]