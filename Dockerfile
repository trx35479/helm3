FROM alpine:3.12.3

ENV VERSION v3.5.2

WORKDIR /

# Enable SSL
RUN apk --update add --no-cache python3 py3-pip ca-certificates wget curl tar jq

# Install gcloud and kubectl
# kubectl will be available at /google-cloud-sdk/bin/kubectl
# This is added to $PATH
ENV HOME /
ENV PATH /google-cloud-sdk/bin:$PATH
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip
RUN google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --additional-components app kubectl alpha beta
# Disable updater check for the whole installation.
# Users won't be bugged with notifications to update to the latest version of gcloud.
RUN google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true

# Install Helm
ENV FILENAME helm-${VERSION}-linux-amd64.tar.gz
ENV HELM_URL https://get.helm.sh/${FILENAME}

RUN echo $HELM_URL

RUN curl -o /tmp/$FILENAME ${HELM_URL} \
    && tar -zxvf /tmp/${FILENAME} -C /tmp \
    && mv /tmp/linux-amd64/helm /bin/helm \
    && rm -rf /tmp

# Helm plugins require git
# helm-diff requires bash, curl
RUN apk --update add git bash

# Install envsubst [better than using 'sed' for yaml substitutions]
ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl"

RUN set -x && \
    apk add --update $RUNTIME_DEPS && \
    apk add --virtual build_deps $BUILD_DEPS &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

# Install Helm plugins
# workaround for an issue in updating the binary of `helm-diff`
ENV HELM_PLUGIN_DIR /.helm/plugins/helm-diff
# Plugin is downloaded to /tmp, which must exist
RUN mkdir /tmp
RUN helm plugin install https://github.com/viglesiasce/helm-gcs.git
RUN helm plugin install https://github.com/databus23/helm-diff
RUN helm plugin install https://github.com/helm/helm-2to3
RUN helm plugin install https://github.com/belitre/helm-push-artifactory-plugin --version 1.0.2

ENTRYPOINT ["helm"]
CMD ["--help"]