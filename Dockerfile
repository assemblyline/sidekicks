FROM assemblyline/alpine-ruby

ENV PATH /usr/src/sidekicks/bin:$PATH

# We can't build native extensions on alpine so we install a packaged nokogiri
RUN apk-install ruby-nokogiri

WORKDIR /usr/src/sidekicks

# Install Ruby Deps
COPY Gemfile /usr/src/sidekicks/
COPY Gemfile.lock /usr/src/sidekicks/
RUN bundle install

COPY . /usr/src/sidekicks

# Run the unit tests
RUN bundle exec rake