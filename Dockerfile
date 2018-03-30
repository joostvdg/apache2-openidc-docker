FROM debian:jessie

## LABELS
LABEL authors="hzandbelt@pingidentity.com, Joost van der Griendt <joostvdg@gmail.com>"
LABEL version="0.2.0"
LABEL description="Apache 2 with OpenIDC"
## LABELS

## ENV
ENV DEBIAN_FRONTEND noninteractive
ENV LAST_CHANGE 2018167021513
ENV DEFAULT_SITE_LOC=/etc/apache2/sites-available/ \
    DEFAULT_SITE=000-default.conf \
    OIDC_PASS_PHRASE=""\ 
    OIDC_METADATA_URL=""\
    OIDC_CLIENT_ID=""\
    OIDC_CLIENT_SECRET=""\
    OIDC_REDIRECT_URL=""\
    OIDC_REMOTE_USER_CLAIM="preferred_username"
ENV CJOSE_VERSION 0.5.1
ENV CJOSE_PKG libcjose0_${CJOSE_VERSION}-1.jessie.1_amd64.deb 
ENV TINI_VERSION v0.16.1 
ENV MOD_AUTH_OPENIDC_VERSION 2.3.0 
ENV MOD_AUTH_OPENIDC_PKG libapache2-mod-auth-openidc_${MOD_AUTH_OPENIDC_VERSION}-1.jessie.1_amd64.deb 
EXPOSE 80
## ENV

## PREPARE TINI
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
## PREPARE TINI

## PREPARE APACHE2 
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates libjansson4 apache2 libhiredis0.10 curl=7.* && rm -rf /var/lib/apt/lists/*
RUN curl -s -L -o ~/${CJOSE_PKG} https://github.com/zmartzone/mod_auth_openidc/releases/download/v2.3.0/${CJOSE_PKG}
RUN dpkg -i ~/${CJOSE_PKG} && echo ok || echo ko
RUN curl -s -L -o ~/${MOD_AUTH_OPENIDC_PKG} https://github.com/zmartzone/mod_auth_openidc/releases/download/v${MOD_AUTH_OPENIDC_VERSION}/${MOD_AUTH_OPENIDC_PKG}
RUN dpkg -i ~/${MOD_AUTH_OPENIDC_PKG} && echo ok || echo ko

ADD 000-default.conf ${DEFAULT_SITE_LOC}/${DEFAULT_SITE}
RUN a2enmod proxy \
    && a2enmod proxy_http \
    && a2enmod ssl \
    && a2enmod rewrite \
    && a2enmod auth_openidc \
    && service apache2 stop
## PREPARE APACHE2 

## RUNTIME PREPARATION
COPY httpd-foreground.sh /usr/local/bin/
RUN chmod +x  /usr/local/bin/httpd-foreground.sh
CMD /usr/local/bin/httpd-foreground.sh
ENTRYPOINT ["/tini", "-vv","-g", "--"]
## RUNTIME PREPARATION

# Invalid Mutex directory in argument file:/var/lock/apache2
RUN mkdir -p /var/lock/apache2
# AH00100: apache2: could not log pid to file /var/run/apache2/apache2.pid
RUN mkdir -p /var/run/apache2
RUN a2enmod headers