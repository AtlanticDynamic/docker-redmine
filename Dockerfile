FROM debian:jessie
MAINTAINER rterhaar@atlanticdynamic.com

ENV REDMINE_VERSION=3.3.3 \
    REDMINE_USER="redmine" \
    REDMINE_HOME="/home/redmine" \
    REDMINE_LOG_DIR="/var/log/redmine" \
    REDMINE_CACHE_DIR="/etc/docker-redmine" \
    REDMINE_MIGRATE_DB="false" \
    RAILS_ENV=production

ENV REDMINE_INSTALL_DIR="${REDMINE_HOME}/redmine" \
    REDMINE_DATA_DIR="${REDMINE_HOME}/data" \
    REDMINE_BUILD_DIR="${REDMINE_CACHE_DIR}/build" \
    REDMINE_RUNTIME_DIR="${REDMINE_CACHE_DIR}/runtime"

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y vim.tiny wget sudo net-tools ca-certificates unzip apt-transport-https \
 && rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor logrotate nginx mysql-client postgresql-client \
      imagemagick subversion git cvs bzr mercurial darcs rsync ruby2.1 locales openssh-client \
      gcc g++ make patch pkg-config gettext-base ruby2.1-dev libc6-dev zlib1g-dev libxml2-dev \
      libmysqlclient18 libpq5 libyaml-0-2 libcurl3 libssl1.0.0 uuid-dev xz-utils \
      libxslt1.1 libffi6 zlib1g gsfonts rubygems \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && gem install --no-document bundler \
 && rm -rf /var/lib/apt/lists/*

COPY assets/build/ ${REDMINE_BUILD_DIR}/
RUN bash ${REDMINE_BUILD_DIR}/install.sh

COPY assets/runtime/ ${REDMINE_RUNTIME_DIR}/
COPY assets/tools/ /usr/bin/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80/tcp 443/tcp

VOLUME ["${REDMINE_DATA_DIR}", "${REDMINE_LOG_DIR}"]
WORKDIR ${REDMINE_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:start"]
