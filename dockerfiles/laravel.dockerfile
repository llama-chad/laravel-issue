FROM php:fpm-alpine

ARG UID
ARG GID
ENV UID=${UID}
ENV GID=${GID}

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN if ! getent group ${GID} >/dev/null 2>&1; then addgroup -g ${GID} --system laravel; fi
RUN if ! getent passwd ${UID} >/dev/null 2>&1; then \
    GROUP_NAME=$(getent group ${GID} | cut -d: -f1) && \
    adduser -G ${GROUP_NAME} --system -D -s /bin/sh -u ${UID} laravel; \
    fi

RUN docker-php-ext-install pdo pdo_mysql

RUN apk update && apk add unixodbc-dev autoconf gcc make gnupg g++ php84-openssl php84-pdo

# Add PostgreSQL client library to persistent deps
RUN apk add --virtual .persistent-deps freetds unixodbc postgresql-libs
RUN apk add --virtual .build-deps $PHPIZE_DEPS unixodbc-dev freetds-dev postgresql-dev

WORKDIR /tmp

#Download the desired package(s)
RUN curl -O https://download.microsoft.com/download/fae28b9a-d880-42fd-9b98-d779f0fdd77f/msodbcsql18_18.5.1.1-1_amd64.apk && \
    curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/mssql-tools18_18.4.1.1-1_amd64.apk && \
    curl -O https://download.microsoft.com/download/fae28b9a-d880-42fd-9b98-d779f0fdd77f/msodbcsql18_18.5.1.1-1_amd64.sig && \
    curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/mssql-tools18_18.4.1.1-1_amd64.sig

RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import - && \
    gpg --verify msodbcsql18_18.5.1.1-1_amd64.sig msodbcsql18_18.5.1.1-1_amd64.apk && \
    gpg --verify mssql-tools18_18.4.1.1-1_amd64.sig mssql-tools18_18.4.1.1-1_amd64.apk

#Install the package(s)
RUN apk add --allow-untrusted msodbcsql18_18.5.1.1-1_amd64.apk && \
    apk add --allow-untrusted mssql-tools18_18.4.1.1-1_amd64.apk

RUN pecl install sqlsrv pdo_sqlsrv

RUN docker-php-ext-enable --ini-name 20-sqlsrv.ini sqlsrv && \
    docker-php-ext-enable --ini-name 20-pdo_sqlsrv.ini pdo_sqlsrv

RUN docker-php-ext-install pgsql pdo_pgsql

RUN apk del .build-deps

RUN apk add samba-dev libldap openldap-dev

RUN docker-php-ext-install ldap

RUN docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install pcntl

RUN pecl install --onlyreqdeps --force redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN echo 'memory_limit = 4G' > /usr/local/etc/php/conf.d/memory.ini

RUN apk update && apk add --no-cache \
    nodejs \
    npm

RUN curl -L https://unpkg.com/@pnpm/self-installer | node

EXPOSE 6274 6277 9000

USER laravel

RUN composer global require laravel/installer

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]