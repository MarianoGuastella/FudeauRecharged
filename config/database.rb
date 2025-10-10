# frozen_string_literal: true

require 'sequel'
require 'sqlite3'
require 'dotenv/load'

# Database configuration
module DatabaseConfig
  def self.connection
    @connection ||= Sequel.connect(
      adapter: 'sqlite',
      database: database_path,
      test: false,
    )
  end

  def self.test_connection
    @test_connection ||= Sequel.connect(
      adapter: 'sqlite',
      database: ':memory:',
      test: true,
    )
  end

  def self.database_path
    return ':memory:' if ENV['RACK_ENV'] == 'test'

    db_dir = File.expand_path('../db', __dir__)
    FileUtils.mkdir_p(db_dir)

    File.join(db_dir, "#{ENV.fetch('RACK_ENV', 'development')}.sqlite3")
  end

  def self.current_connection
    ENV['RACK_ENV'] == 'test' ? test_connection : connection
  end
end

# Initialize database connection
DB = DatabaseConfig.current_connection

# Enable foreign keys
DB.run('PRAGMA foreign_keys = ON') if DB.adapter_scheme == :sqlite
