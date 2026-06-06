FROM quay.io/sclorg/s2i-core-c9s:20260407@sha256:78057bb349d738bdfaf72afb77d26c0b592d1c06746e6b82909aa97f135e55f3 AS base
FROM ghcr.io/radiorabe/ubi9-minimal:0.11.5@sha256:2c50f165eccd206b3ff9c117c05df3b2263000b60cdd3ea24810b1c38bbe36b8

ENV \
    # Path to be used in other layers to place s2i scripts into
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    APP_ROOT=/opt/app-root \
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PLATFORM="el9"

COPY --from=base \
     /usr/bin/base-usage \
     /usr/bin/container-entrypoint \
     /usr/bin/cgroup-limits \
     /usr/bin/fix-permissions \
     /usr/bin/prepare-yum-repositories \
     /usr/bin/rpm-file-permissions \
     /usr/bin/

RUN <<-EOR
    set -xe
    microdnf install -y \
         bsdtar \
         findutils \
         gettext \
         glibc-locale-source \
         glibc-langpack-en \
         groff-base \
         rsync \
         scl-utils \
         shadow-utils \
         tar \
         unzip \
         xz
    microdnf clean all
    rpm-file-permissions
    mkdir -p ${APP_ROOT}
    useradd -u 1001 -r -g 0 -d ${HOME} -c "Default Application User" default
    chown -R 1001:0 ${APP_ROOT}
EOR

WORKDIR ${HOME}

ENTRYPOINT ["container-entrypoint"]
CMD ["base-usage"]
