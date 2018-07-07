FROM ruby

MAINTAINER grezar.dev@gmail.com

ENV APP_DIR /app
ENV LANG en_US.UTF-8
ENV RUBYOPT -EUTF-8

RUN mkdir $APP_DIR

WORKDIR $APP_DIR

COPY Gemfile $APP_DIR
COPY Gemfile.lock $APP_DIR

RUN echo 'gem: --no-document' >> ~/.gemrc && \
    bundle install --path vendor/bundle

COPY . $APP_DIR

CMD ["bundle", "exec", "foreman", "start"]
