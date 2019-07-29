FROM php:7.2-fpm

RUN mkdir -p /var/cache

RUN docker-php-ext-install pdo pdo_mysql bcmath opcache

RUN apt-get update && \
    apt-get install -y --no-install-recommends git zip unzip wget gettext build-essential zlib1g-dev \
    automake \
    cmake \
    g++ \
    librabbitmq-dev \
    libreadline-dev \
    pkg-config

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin/ --filename=composer

RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && apt-get install -y libpq-dev libmemcached-dev \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

RUN wget -O /tmp/igbinary.tgz https://pecl.php.net/get/igbinary-2.0.4.tgz \
    && tar -xvzf /tmp/igbinary.tgz -C /usr/src/php/ext/ \
    && mv /usr/src/php/ext/igbinary-2.0.4 /usr/src/php/ext/igbinary \
    && docker-php-ext-configure igbinary CFLAGS="-O2 -g" --enable-igbinary \
    && docker-php-ext-install igbinary \
    && docker-php-ext-configure memcached --enable-memcached-igbinary \
    && rm /tmp/igbinary.tgz


#####################################
# Install PHP GD
#####################################
RUN apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ --enable-gd-native-ttf --enable-gd-jis-conv \
    && docker-php-ext-install gd exif


RUN docker-php-ext-install zip


RUN mkdir /var/sf && chown -R www-data:www-data /var/sf


RUN git clone git://github.com/alanxz/rabbitmq-c.git \
    && cd rabbitmq-c \
    && mkdir build && cd build \
    && cmake -DENABLE_SSL_SUPPORT=OFF .. \
    && cmake --build . --target install  \
    && pecl install amqp \
    && docker-php-ext-enable amqp

WORKDIR /app




##########################################
# WARNING!# WARNING!# WARNING!# WARNING! #
##########################################
#     You must add new commands above    #
#    You must add new commands above     #
#     You must add new commands above    #
#    You must add new commands above     #
##########################################





#####################################
# xDebug:
#####################################
# XDEBUG: https://gist.github.com/chadrien/c90927ec2d160ffea9c4
# https://gist.github.com/chadrien/c90927ec2d160ffea9c4#gistcomment-1881975
ARG PHP_XDEBUG_ENABLED
RUN if [ ${PHP_XDEBUG_ENABLED:-false} = "true" ] ; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.default_enable       = 0"                       >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart     = 0"                       >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back  = 0"                       >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable      = 0"                       >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler       = dbgp"                    >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_dir  = /var/log/php-fpm"        >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_log           = /var/log/xdebug.log"     >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && touch /var/log/xdebug.log \
    && chmod 777 /var/log/xdebug.log \
;fi
