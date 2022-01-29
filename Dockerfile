FROM nginx:1.21.3

VOLUME [ "/code" ]

ENV ACCEPT_EULA=Y

WORKDIR /code

ADD start.sh /docker-entrypoint.d/40-start.sh
ADD scripts_init/* /scripts_init/
ADD scripts/* /scripts/

RUN ln -fs /usr/share/zoneinfo/America/Rio_Branco /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt update && \
    apt -y upgrade && \
    echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen && \
    apt install -y ca-certificates \
                   apt-transport-https \
                   lsb-release \
                   gnupg \
                   ntp \
                   curl \
                   wget \
                   dirmngr \
                   cron \
                   software-properties-common \
                   locales git \
                   openssh-client \
                   rsync \
                   gettext \
                   mariadb-client \
                   mutt \ 
                   sshpass \
                   gcc \
                   g++ \
                   make && \
    locale-gen && \
    curl -o /etc/apt/trusted.gpg.d/php.gpg -fSL "https://packages.sury.org/php/apt.gpg" && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl -s https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt -y update && \
    apt -y remove libgcc-8-dev && \
    apt -y install --allow-unauthenticated php8.0 \
                   php8.0-fpm \
                   php8.0-mysql \
                   php8.0-mbstring \
                   php8.0-xmlrpc \
                   php8.0-soap \
                   php8.0-gd \
                   php8.0-xml \
                   php8.0-intl \
                   php8.0-dev \
                   php8.0-curl \
                   php8.0-zip \
                   php8.0-imagick \
                   php8.0-pgsql \
                   php8.0-gmp \
                   php8.0-ldap \
                   php8.0-bcmath \
                   php8.0-bz2 \
                   php8.0-ctype \
                   php8.0-dev \
                   unixodbc-dev \
                   msodbcsql17 \
                   mssql-tools \
                   gcc \
                   g++ \
                   make \
                   autoconf \
                   libc-dev \
                   pkg-config \
                   git \
                   adoptopenjdk-8-hotspot && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    ntpd -q -g && \
    rm -rf /var/lib/apt/lists/* && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt clean && \
    chown -R www-data:www-data /code &&  \
    printf "# priority=10\nservice ntp start\n" > /docker-entrypoint.d/10-ntpd.sh && \
    chmod 755 /docker-entrypoint.d/10-ntpd.sh && \
    printf "# priority=30\nservice php8.0-fpm start\n" > /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php-fpm.sh && \
    printf "# priority=40\nservice cron start\n" > /docker-entrypoint.d/40-cron.sh && \
    chmod 755 /docker-entrypoint.d/10-ntpd.sh && \    
    chmod 755 /docker-entrypoint.d/30-php-fpm.sh && \
    chmod 755 /docker-entrypoint.d/40-start.sh && \
    chmod 755 /docker-entrypoint.d/40-cron.sh && \
    chmod 755 /scripts_init/* && \
    mkdir -p ~/.mutt/cache/headers && \
    mkdir /projeto && \
    mkdir ~/.mutt/cache/bodies && \
    touch ~/.mutt/certificates && \
    touch ~/.mutt/muttrc 
    
ADD config_cntr/php.ini /etc/php/8.0/fpm/php.ini
ADD config_cntr/www.conf /etc/php/8.0/fpm/pool.d/www.conf
ADD config_cntr/cron.list /
ADD config_cntr/nginx.conf /etc/nginx
ADD config_cntr/default.conf /etc/nginx/conf.d
ADD config_cntr/muttrc.template /
