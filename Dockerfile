FROM ruby

ENV APP_ROOT /usr/src/slaq

WORKDIR $APP_ROOT

COPY . $APP_ROOT

RUN bundle install --path vendor/bundle

CMD ["bundle", "exec", "ruby", "lib/slaq.rb"]
