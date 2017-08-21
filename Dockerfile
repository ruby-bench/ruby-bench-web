FROM ruby:2.4

RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  nodejs

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler && bundle install

COPY . ./

EXPOSE 3000

ENTRYPOINT ["bundle", "exec"]

CMD ["unicorn", "-c", "config/unicorn.rb"]
