# frozen_string_literal: true

require 'bcrypt'
require 'sequel'
require_relative '../../config/database'

class User < Sequel::Model
  include BCrypt

  plugin :timestamps, update_on_create: true
  plugin :json_serializer
  plugin :validation_helpers

  def validate
    super
    validates_presence [:email, :password_hash, :name]
    validates_unique :email
    validates_format(/\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i, :email)
  end

  def password=(new_password)
    self.password_hash = Password.create(new_password)
  end

  def authenticate?(password)
    Password.new(password_hash) == password
  end

  def to_hash_with_associations
    to_hash.except(:password_hash)
  end

  def self.by_id(id)
    where(id: id).first
  end
end
