FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
        lua5.1 \
        luarocks \
        zip \
        bash \
        git \
        wget \
        unzip && \
    luarocks install luacheck

WORKDIR /app

COPY . .

CMD ["luacheck", "addon"]