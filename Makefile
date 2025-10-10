# Restaurant API Makefile

.PHONY: help install setup test server migrate seed clean docker-build docker-run lint lint-fix console check logs

# Default target
help:
	@echo "Available commands:"
	@echo "  install     - Install Ruby dependencies"
	@echo "  setup       - Complete setup (install + migrate + seed)"
	@echo "  migrate     - Run database migrations"
	@echo "  seed        - Populate database with sample data"
	@echo "  test        - Run the test suite"
	@echo "  server      - Start the development server"
	@echo "  server-dev  - Start server with auto-reload"
	@echo "  clean       - Clean database and temporary files"
	@echo "  docker-build - Build Docker image"
	@echo "  docker-run  - Run with Docker Compose"
	@echo "  lint        - Run RuboCop linter"
	@echo "  lint-fix    - Run RuboCop with auto-fix"
	@echo "  console     - Start interactive Ruby console"
	@echo "  check       - Check if all dependencies are satisfied"
	@echo "  logs        - Show development logs"

# Install dependencies
install:
	bundle install

# Complete setup
setup: install migrate seed
	@echo "Setup complete! You can now run 'make server' to start the application"

# Run database migrations
migrate:
	bundle exec ruby lib/migrate.rb

# Populate database with sample data
seed:
	bundle exec ruby lib/seeds.rb

# Run tests
test:
	RACK_ENV=test bundle exec rspec

# Start development server
server:
	bundle exec puma -p 4567 config.ru

# Start development server with auto-reload
server-dev:
	bundle exec rerun 'bundle exec puma -p 4567 config.ru'

# Clean database and temporary files
clean:
	rm -f db/*.sqlite3
	mkdir -p tmp log
	rm -rf tmp/*
	@echo "Database and temporary files cleaned"

# Docker commands
docker-build:
	docker build -t restaurant-api .

docker-run:
	docker-compose up app

# Linting
lint:
	bundle exec rubocop

lint-fix:
	bundle exec rubocop -a

# Development helpers
console:
	bundle exec irb -r ./app.rb

logs:
	@if [ -f log/development.log ]; then tail -f log/development.log; else echo "No log file found. Start the server first."; fi

# Check if all dependencies are satisfied
check:
	@echo "Checking Ruby version..."
	@ruby --version
	@echo "Checking bundle install..."
	@bundle check || (echo "Run 'make install' first" && exit 1)
	@echo "Checking database..."
	@if [ -f db/development.sqlite3 ]; then echo "Database exists"; else echo "Run 'make migrate' first"; fi
	@echo "All checks passed!"