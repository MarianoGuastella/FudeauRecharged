#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../config/database'

# Load migration extension
Sequel.extension :migration

# Migration runner
class MigrationRunner
  def self.run!
    migration_dir = File.expand_path('../db/migrations', __dir__)
    
    if Dir.exist?(migration_dir)
      puts "Running migrations from: #{migration_dir}"
      
      Sequel::Migrator.run(DB, migration_dir)
      puts "Migrations completed successfully!"
    else
      puts "No migrations directory found"
    end
  rescue => e
    puts "Migration failed: #{e.message}"
    puts e.backtrace.join("\n")
    raise e
  end
end

# Run migrations if this file is executed directly
MigrationRunner.run! if __FILE__ == $PROGRAM_NAME