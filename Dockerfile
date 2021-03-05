#FROM hub.artifactory.gcp.anz/alpine:3.12.3
FROM alpine/helm:3.5.2
# build args
#ARG HELM_VERSION=v3.5.2
#ARG BASE_URL="https://artifactory.gcp.anz/artifactory/helmcli"
#ARG ARTIFACTORY_VERSION=1.0.2

RUN apk add --update --no-cache curl bash git \
    && helm plugin install https://github/chartmuseum/helm-push

LABEL maintainer=ob-platform-engineering@anz.com \
    ci_name=Open-Banking-Platform \
    ci_group=OpenBanking-SRE

#ENV PATH=/usr/bin/helm:$PATH
#ENV HELM_PLUGINS=${HELM_PLUGINS_DIR}/

ENTRYPOINT ["helm"]
CMD ["--help"]