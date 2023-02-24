FROM ghcr.io/radiorabe/ubi9-minimal:0.2.2

ENV \
    # Path to be used in other layers to place s2i scripts into
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    APP_ROOT=/opt/app-root \
    # The $HOME is not set by default, but some applications needs this variable
    HOME=/opt/app-root/src \
    PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PLATFORM="el9"

COPY --from=registry.access.redhat.com/ubi9/s2i-core:1-373 \
     /usr/bin/base-usage \
     /usr/bin/container-entrypoint \
     /usr/bin/cgroup-limits \
     /usr/bin/fix-permissions \
     /usr/bin/prepare-yum-repositories \
     /usr/bin/rpm-file-permissions \
     /usr/bin/
COPY --from=registry.access.redhat.com/ubi9/s2i-core:1-373 \
     /opt/app-root/etc/scl_enable \
     /opt/app-root/etc/

RUN    microdnf install -y \
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
         xz \
    && microdnf clean all \
    && rpm-file-permissions \
    && useradd -u 1001 -r -g 0 -d ${HOME} -s /sbin/nologin \
       -c "Default Application User" default \
    && chown -R 1001:0 ${APP_ROOT}
    
WORKDIR ${HOME}

ENTRYPOINT ["container-entrypoint"]
CMD ["base-usage"]
