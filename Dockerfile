# Use Ruby 3.0.2 slim image
FROM ruby:3.0.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    sqlite3 \
    libsqlite3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install Ruby dependencies
RUN bundle config --global frozen 1 && \
    bundle install

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p db tmp log

# Set environment variables
ENV RACK_ENV=production
ENV PORT=4567

# Expose port
EXPOSE 4567

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:$PORT/health || exit 1

# Run database migrations and start the server
CMD ["sh", "-c", "bundle exec ruby lib/migrate.rb && bundle exec puma -p $PORT -e $RACK_ENV config.ru"]