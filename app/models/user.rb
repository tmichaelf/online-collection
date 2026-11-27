class User < ApplicationRecord
  USERNAME_FORMAT = /\A[a-z0-9][a-z0-9_-]{1,29}\z/

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :collection_items, dependent: :destroy
  has_many :titles, through: :collection_items

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :username, with: ->(u) { u.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: true, format: { with: USERNAME_FORMAT, message: "must be 2–30 lowercase letters, numbers, dashes or underscores" }
  validates :password, length: { minimum: 8 }, allow_nil: true

  def self.demo
    find_by(username: Rails.configuration.x.demo_collector)
  end

  def to_param
    username
  end
end
