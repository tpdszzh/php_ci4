# 基于 PHP 8.1 + Apache 官方镜像
FROM php:8.1-apache

# 启用 Apache 的 URL 重写模块（CI4 需要）
RUN a2enmod rewrite

# 更新 APT 并安装系统依赖及所需的开发包
# 注意：libcurl4-openssl-dev 和 pkg-config 用于满足 libcurl >=7.29.0 的依赖
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libonig-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libcurl4-openssl-dev \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

# 配置并安装 GD 扩展
# 注意：显式指定 freetype 的路径，通常在 Debian/Ubuntu 下 freetype 的头文件位于 /usr/include/freetype2
RUN docker-php-ext-configure gd --with-freetype=/usr/include/freetype2 --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd

# 安装其它 PHP 扩展：intl、mbstring、pdo、pdo_mysql、mysqli、xml、zip、curl
RUN docker-php-ext-install intl mbstring pdo pdo_mysql mysqli xml zip curl

# 通过 PECL 安装 Xdebug（可选）并启用
RUN pecl install xdebug && docker-php-ext-enable xdebug

# 安装 Composer（从官方 Composer 镜像复制）
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# 设置工作目录
WORKDIR /var/www/html

# 可选：通过 Composer 创建 CodeIgniter4 项目（取消下面注释即可）
# RUN composer create-project codeigniter4/appstarter .

# 修改 /var/www/html 目录的权限，确保 Apache 有足够的读写权限
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# 暴露 80 端口
EXPOSE 80