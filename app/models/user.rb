# frozen_string_literal: true

class User < ApplicationRecord
  include Pay::Billable
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
  has_one_attached :avatar
  # set optional: true if you don't want the default Rails 5 belongs_to presence validation
  belongs_to :product

  validates :email, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :first_name, presence: true
  validates :last_name, presence: true

  delegate :name, to: :product, prefix: true

  before_save :set_name

  # Send mail through activejob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # Allows features to be flipped for individuals
  def flipper_id
    "User:#{id}"
  end

  # Assumes user has just one subscription
  def get_subscription
    Product.find_each.map(&:name).each do |product_name|
      return subscription(name: product_name)
    end
  end

  def subscribed_to_any?
    Product.find_each.map(&:name).each do |product_name|
      return true if subscribed?(name: product_name)
    end
    false
  end

  def on_trial_or_subscribed_to_any?
    return true if on_trial?
    subscribed_to_any?
  end

  private
    def set_name
      self.name = [first_name, last_name].join(" ").strip
    end
end
