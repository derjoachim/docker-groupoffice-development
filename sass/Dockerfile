FROM debian:buster-slim

RUN apt-get update && apt-get install -y curl

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update && apt-get install -y nodejs
RUN npm install npm -g && npm install -g sass

VOLUME /src

#ENTRYPOINT ["sass", "--watch", "./master/www/views/Extjs3/themes/Paper/src/style.scss:./master/www/views/Extjs3/themes/Paper/style.css", "./master/www/views/Extjs3/themes/Paper/src/style-mobile.scss:./master/www/views/Extjs3/themes/Paper/style-mobile.css", "./63/www/views/Extjs3/themes/Paper/src/style.scss:./63/www/views/Extjs3/themes/Paper/style.css", "./63/www/views/Extjs3/themes/Paper/src/style-mobile.scss:./63/www/views/Extjs3/themes/Paper/style-mobile.css"]

COPY entrypoint.sh /usr/local/bin

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]