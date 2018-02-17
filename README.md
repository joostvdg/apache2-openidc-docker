# apache2-openidc-docker

[![GitHub release](https://img.shields.io/github/release/joostvdg/apache2-openidc-docker.svg)]()
[![license](https://img.shields.io/github/license/joostvdg/apache2-openidc-docker.svg)]()
[![Docker Pulls](https://img.shields.io/docker/pulls/caladreas/apache2-openidc-docker.svg)]()
[![](https://images.microbadger.com/badges/image/caladreas/apache2-openidc-docker.svg)](https://microbadger.com/images/caladreas/apache2-openidc-docker "Get your own image badge on microbadger.com")

Naieve docker container configuration for Apache2 with OpenIDC integration.

This image is based on the work of others: [Reposoft](https://github.com/Reposoft/openidc-keycloak-test) ([hzandbelt@pingidentity.com](https://github.com/Reposoft/openidc-keycloak-test/tree/master/openidc-jessie), [solsson](https://github.com/solsson)).

Their work has been adapted to suit my personal need for being able to host [MKDocs](http://www.mkdocs.org/) sites in a docker container that can use [Keycloak](http://www.keycloak.org/) as single sign-on solution.

Many thanks to [Zmartzone](https://github.com/zmartzone/mod_auth_openidc) for their mod_auth_openidc module for Apache2.

## Other resources

* https://github.com/zmartzone/mod_auth_openidc/wiki/Keycloak
* https://github.com/Reposoft/openidc-keycloak-test/tree/master/openidc-jessie
* https://hub.docker.com/r/solsson/httpd-openidc/~/dockerfile/
* https://github.com/zmartzone/mod_auth_openidc/wiki#11-where-can-i-get-binary-packages
* https://github.com/krallin/tini

## How to use

This can be done for any website you want to host or what else you want to do with apache2.

My usecase is to host MKDocs (with [MKDocs Material]()) websites, so thats my example.
I'm sure you can extrapolate the rest from there.

```dockerfile
######################################################
################## MULTI-STAGE BUILD
##################
## BUILD
FROM caladreas/mkdocs-docker-build-container:2.0.0 as build
WORKDIR /src
ENV LAST_UPDATE=20180209
ADD . /src
RUN ls -lath /src
RUN mkdocs build
RUN ls -lath /src/site
##################

##################
## RUN
FROM caladreas/apache2-openidc-docker:0.1.0
COPY --from=build /src/site /var/www/html/
##################
######################################################
```