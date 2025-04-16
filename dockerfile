# ---- Stage 1: Build Zabbix from source ----
FROM alpine:latest AS builder

# Install build dependencies
RUN apk add --no-cache \
    git cmake gcc g++ make curl curl-dev \
    openssl-dev mariadb-connector-c-dev libevent-dev \
    libxml2-dev pcre2-dev libcurl go autoconf automake \
    libtool bison fping linux-headers bash

WORKDIR /src
COPY . /src

# Configure, build, and install Zabbix
RUN ./configure \
      --enable-server \
      --with-mysql \
      --with-libcurl \
      --with-openssl \
      --with-libxml2 \
      --with-libpcre2 \
      --enable-agent && \
    make -j$(nproc) && \
    make install

# Copy SQL files
RUN mkdir -p /zabbix-sql && \
    cp database/mysql/schema.sql /zabbix-sql/ && \
    cp database/mysql/images.sql /zabbix-sql/ && \
    cp database/mysql/data.sql /zabbix-sql/

# ---- Stage 2: Runtime container ----
FROM alpine:latest

# Install runtime dependencies
RUN apk add --no-cache \
    libevent mariadb-client mariadb-connector-c \
    libxml2 libcurl openssl pcre2 bash fping

# Copy binaries and SQL from builder
COPY --from=builder /usr/local/ /usr/local/
COPY --from=builder /zabbix-sql /usr/local/share/zabbix/database/mysql/

# Add user and required dirs
RUN addgroup -S zabbix && adduser -S -D zabbix && \
    mkdir -p /var/log/zabbix /var/run/zabbix /var/lib/zabbix && \
    chown -R zabbix:zabbix /var/log/zabbix /var/run/zabbix /var/lib/zabbix

# Set default command
CMD ["/usr/local/sbin/zabbix_server", "-f"]

