#FROM ruby:1.9.3
FROM ruby:2.1
WORKDIR /usr/local/app
ADD Gemfile Gemfile
ADD barthes.gemspec barthes.gemspec
ADD lib/barthes/version.rb lib/barthes/version.rb
RUN bundle install
