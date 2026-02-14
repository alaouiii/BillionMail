FROM php:8.1-apache

# تثبيت الإضافات
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# نسخ كاع الملفات
COPY . /var/www/html/

# هاد السطر كيتأكد بلي Apache كيشوف المجلد الصحيح حتى لو كان وسط مجلد آخر
# غادي نصلحو الصلاحيات ونخليو Apache يقرأ كولشي
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# تفعيل خاصية Dir Listing (غير باش نتأكدو فين كاينين الملفات)
RUN echo "<Directory /var/www/html/> \n\
    Options Indexes FollowSymLinks \n\
    AllowOverride All \n\
    Require all granted \n\
    </Directory>" > /etc/apache2/conf-available/docker-php.conf \
    && a2enconf docker-php

EXPOSE 80
