### Build Hardened Malloc
FROM alpine:latest as hmalloc-builder

ARG HARDENED_MALLOC_VERSION=2024060400
ARG CONFIG_NATIVE=false
ARG VARIANT=default

RUN apk -U upgrade \
    && apk --no-cache add build-base git gnupg openssh-keygen
    
RUN cd /tmp \
    && git clone --depth 1 --branch ${HARDENED_MALLOC_VERSION} https://github.com/GrapheneOS/hardened_malloc \
    && cd hardened_malloc \
    && wget -q https://grapheneos.org/allowed_signers -O grapheneos_allowed_signers \
    && git config gpg.ssh.allowedSignersFile grapheneos_allowed_signers \
    && git verify-tag $(git describe --tags) \
    && make CONFIG_NATIVE=${CONFIG_NATIVE} VARIANT=${VARIANT}

### Build Production
FROM tomcat:9

LABEL maintainer="Thien Tran contact@tommytran.io"

RUN apt update \
    && apt full-upgrade -y
RUN apt install -y aapt wget sed postgresql-client \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/tomcat/conf/Catalina/localhost
RUN mkdir -p /usr/local/tomcat/ssl

COPY --from=hmalloc-builder /tmp/hardened_malloc/out/libhardened_malloc.so /usr/local/lib/
COPY docker-entrypoint.sh /
COPY tomcat_conf/server.xml /usr/local/tomcat/conf/server.xml 
ADD templates /opt/hmdm/templates/

ENV HMDM_VARIANT=os
ENV DOWNLOAD_CREDENTIALS=
ENV SERVER_VERSION=5.27.1
ENV CLIENT_VERSION=5.27
ENV HMDM_URL=https://h-mdm.com/files/hmdm-${SERVER_VERSION}-${HMDM_VARIANT}.war

# Available values: en, ru (en by default)
ENV INSTALL_LANGUAGE=en

# Different for open source and premium versions!
ENV SHARED_SECRET=changeme-C3z9vi54

ENV PROTOCOL=https

# Comment it to use custom certificates
ENV HTTPS_LETSENCRYPT=true
# Mount the custom certificate path if custom certificates must be used
# ENV_HTTPS_CERT_PATH is the path to certificates and keys inside the container
#ENV HTTPS_CERT_PATH=/cert
ENV HTTPS_CERT=cert.pem
ENV HTTPS_FULLCHAIN=fullchain.pem
ENV HTTPS_PRIVKEY=privkey.pem

ENV LD_PRELOAD="/usr/local/lib/libhardened_malloc.so"

EXPOSE 8080/tcp 8443/tcp 31000/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]
