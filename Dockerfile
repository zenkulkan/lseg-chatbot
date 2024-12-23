# Use an official Ruby image as the base
FROM ruby:3.2.0

# Install Redis server
RUN apt-get update -qq && apt-get install -y redis-server

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install dependencies
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose ports 3000 (Rails) and 6379 (Redis)
EXPOSE 3000
EXPOSE 6379

# Start Redis server and Rails server in parallel
CMD ["sh", "-c", "redis-server --daemonize yes && rails server -b 0.0.0.0"]`
