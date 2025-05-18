    # syntax = docker/dockerfile:1

    # Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
    ARG RUBY_VERSION=3.3.0
    FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

    # Rails app lives here
    WORKDIR /newapp

    # Set development environment
    ENV RAILS_ENV="development" \
        BUNDLE_DEPLOYMENT="1" \
        BUNDLE_PATH="/usr/local/bundle" \
        BUNDLE_WITHOUT=""

    # Install packages needed to build gems and node modules
    RUN apt-get update -qq && \
        apt-get install --no-install-recommends -y build-essential curl git libpq-dev libvips node-gyp pkg-config python-is-python3

    # Install JavaScript dependencies
    ARG NODE_VERSION=24.0.2
    ARG YARN_VERSION=1.22.22
    ENV PATH=/usr/local/node/bin:$PATH
    RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
        /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
        npm install -g yarn@$YARN_VERSION && \
        rm -rf /tmp/node-build-master

    # Install application gems
    COPY Gemfile Gemfile.lock ./
    RUN npm install --global yarn
    RUN yarn add bootstrap
    RUN bundle install

    # Install node modules
    COPY yarn.lock package.json ./
    RUN yarn install

    # Copy application code
    COPY . .

    # Install packages needed for deployment, including Yarn
    RUN apt-get update -qq && \
        apt-get install --no-install-recommends -y curl libvips postgresql-client \
        && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
        && apt-get install -y nodejs && \
        npm install -g yarn \
        && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set directory ownership
RUN chown -R $USER:$USER .

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000