FROM alpine/helm:3.5.2

WORKDIR /helm

RUN apk add --update --no-cache curl bash git \
    && helm plugin install https://github/belitre/helm-push-artifactory-plugin.git --version 1.0.2

ENTRYPOINT ["helm"]
CMD ["--help"]