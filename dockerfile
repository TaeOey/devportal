FROM php:7.3.6-fpm

RUN apt-get update && apt-get install -y --fix-missing \
    apt-utils \
    mysql-client \
    imagemagick \
    graphviz \
    git \
    libpng-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libxml2-dev \
    libxslt1-dev \
    wget \
    linux-libc-dev \
    libyaml-dev \
    zlib1g-dev \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    libssl-dev && \
    rm -r /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get install -y --fix-missing \
    nodejs

RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install \
    mysqli \
    pdo_mysql \
    gd \
    mbstring \
    xsl \
    opcache \
    calendar \
    intl \
    exif \
    ftp \
    bcmath \
    xml \
    json \
    zip

RUN cd /usr/src && \
    curl -sS http://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install Drush
RUN composer global require drush/drush:8.0.0-rc3
RUN ln -nsf /root/.composer/vendor/bin/drush /usr/local/bin/drush

# ADD xdebug.ini  /etc/php7.3/conf.d/

# RUN echo "upload_max_filesize = 500M\n" \
#          "post_max_size = 500M\n" \
#          > /usr/local/etc/php/conf.d/maxsize.ini

#ADD https://download.octopusdeploy.com/octopus-tools/6.13.1/OctopusTools.6.13.1.debian.8-x64.tar.gz /tmp/
#RUN tar -xvf /tmp/OctopusTools.6.13.1.debian.8-x64.tar.gz
#RUN tar -xvf /tmp/octo.tar -C /tmp/octo
#COPY /tmp/octo /tmp

USER www-data
WORKDIR /var/www/html
VOLUME /var/www/html