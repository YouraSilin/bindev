FROM ruby:3.3.0

# Install OS-level dependencies
RUN apt-get update -qq && apt-get install -y npm postgresql-client
WORKDIR /newapp

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
COPY Gemfile /newapp/Gemfile
COPY Gemfile.lock /newapp/Gemfile.lock
RUN gem install bundler -v 2.4.15
RUN bundle install

# Cleanup cache
RUN bundle clean --force \
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

# Add JavaScript dependencies
COPY package.json /newapp/package.json
RUN yarn install && yarn add bootstrap

# Copy the rest of the application code
COPY . .

# Set directory ownership
RUN chown -R root:root /newapp

# Add entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000