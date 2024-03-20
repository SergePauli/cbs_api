# /path/to/app/Dockerfile
FROM ruby:2.7.3

# Добавляем сертификат прокси в доверенные
#ADD squid.crt /usr/local/share/ca-certificates
#RUN update-ca-certificates
# Соберем все во временной директории
WORKDIR /tmp
ADD Gemfile* ./
#RUN git config --global http.sslverify false

RUN bundle install
# Копирование кода приложения в контейнер
ENV APP_HOME /app
COPY . $APP_HOME
WORKDIR $APP_HOME

# Проброс порта 5000
EXPOSE 5000

# Запуск по умолчанию сервера в продакшин
CMD ["rails", "server","-e=production"]