# syntax=docker/dockerfile:1
FROM ruby:3.3.0

# Rails app lives here
WORKDIR /newapp

# Set development environment
ENV RAILS_ENV="development" \
BUNDLE_DEPLOYMENT="1" \
BUNDLE_PATH="/usr/local/bundle" \
BUNDLE_WITHOUT=""

# Install packages needed to build gems and node modules
RUN apt-get update -qq && apt-get install -y -no-install-recommends -y build-essential curl git libpq-dev libvips node-gyp pkg-config npm yarn postgresql-client

# Install JavaScript dependencies
ARG NODE_VERSION=24.0.2
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

COPY Gemfile /newapp/Gemfile
COPY Gemfile.lock /newapp/Gemfile.lock
RUN yarn add bootstrap
RUN bundle install

# Install node modules
COPY yarn.lock package.json ./
RUN yarn install

# Set directory ownership
RUN chown -R $USER:$USER .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000