FROM php:7.3-fpm-stretch

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

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
    zip \
    nodejs \
    #npm \
    libssl-dev && \
    rm -r /var/lib/apt/lists/*

# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
# RUN apt-get update && apt-get install -y --fix-missing \
#     nodejs

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

#RUN cd /usr/src && \
#    curl -sS http://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Drush
RUN composer global require drush/drush:8
RUN ln -nsf /root/.composer/vendor/bin/drush /usr/local/bin/drush

# ADD xdebug.ini  /etc/php7.3/conf.d/

# RUN echo "upload_max_filesize = 500M\n" \
#          "post_max_size = 500M\n" \
#          > /usr/local/etc/php/conf.d/maxsize.ini

USER www-data
WORKDIR /var/www/
VOLUME /var/www/