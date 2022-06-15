FROM nginx:1.21.6

VOLUME [ "/code" ]

ENV ACCEPT_EULA=Y

WORKDIR /code

ADD start.sh /docker-entrypoint.d/40-start.sh
ADD scripts_init/* /scripts_init/

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
                   make \
                   unzip && \
    locale-gen && \
    curl -o /etc/apt/trusted.gpg.d/php.gpg -fSL "https://packages.sury.org/php/apt.gpg" && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl -s https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt -y update && \
    apt -y remove libgcc-8-dev && \
    apt -y install --allow-unauthenticated vim php7.4 \
                   php7.4-fpm \
                   php7.4-mysql \
                   php7.4-mbstring \
                   php7.4-xmlrpc \
                   php7.4-soap \
                   php7.4-gd \
                   php7.4-xml \
                   php7.4-sqlite3 \
                   php7.4-intl \
                   php7.4-dev \
                   php7.4-curl \
                   php7.4-cli \
                   php7.4-zip \
                   php7.4-imagick \
                   php7.4-pgsql \
                   php7.4-gmp \
                   php7.4-ldap \
                   php7.4-bcmath \
                   php7.4-bz2 \
                   php7.4-ctype \
                   php7.4-opcache \                   
                   php7.4-phar \                   
                   php7.4-readline \               
                   unixodbc-dev \
                   msodbcsql18 \
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
    printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.4/mods-available/sqlsrv.ini && \
    printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini && \
    phpenmod -v 7.4 sqlsrv pdo_sqlsrv && \
    ntpd -q -g && \
    rm -rf /var/lib/apt/lists/* && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt clean && \
    chown -R www-data:www-data /code &&  \
    printf "# priority=10\nservice ntp start\n" > /docker-entrypoint.d/10-ntpd.sh && \
    chmod 755 /docker-entrypoint.d/10-ntpd.sh && \
    printf "# priority=30\nservice php7.4-fpm start\n" > /docker-entrypoint.d/30-php-fpm.sh && \
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
    
ADD config_cntr/php.ini /etc/php/7.4/fpm/php.ini
ADD config_cntr/www.conf /etc/php/7.4/fpm/pool.d/www.conf
ADD config_cntr/nginx.conf /etc/nginx
ADD config_cntr/default.conf /etc/nginx/conf.d
ADD config_cntr/muttrc.template /
ADD config_cntr/drivers/* /usr/lib/php/20210902/
