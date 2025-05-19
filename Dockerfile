FROM ruby:3.3.0

# Install OS-level dependencies
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
  build-essential curl git libpq-dev libvips node-gyp pkg-config npm yarn postgresql-client

# Install Node.js and Yarn
ARG NODE_VERSION=24.0.2
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Set working directory and copy Gemfile for dependency installation
WORKDIR /newapp
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle config set frozen false
RUN bundle install

# Add JavaScript dependencies
COPY package.json ./
RUN yarn install && yarn add bootstrap

# Copy the rest of the application code
COPY . .

# Set environment variables
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=""

# Set directory ownership
RUN chown -R $USER:$USER .

# Add entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000