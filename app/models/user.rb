# frozen_string_literal: true

class User < ApplicationRecord
  include Pay::Billable
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable
  has_many :invoices, dependent: :destroy
  has_one_attached :avatar
  # set optional: true if you don't want the default Rails 5 belongs_to presence validation
  belongs_to :plan

  validates :email, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :first_name, presence: true
  validates :last_name, presence: true

  # If you create new roles and have existing data,
  # add the role at the end so you don't corrupt existing role integers
  enum role: %i(basic pro admin)
  after_initialize :setup_new_user, if: :new_record?

  delegate :cost, to: :plan
  delegate :name, to: :plan, prefix: true

  before_save :set_name

  # Send mail through activejob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # Allows features to be flipped for individuals
  def flipper_id
    "User:#{id}"
  end

  private

    def setup_new_user
      # TODO set default in PG
      self.role ||= :basic

    end

    def set_name
      self.name = [first_name, last_name].join(" ").strip
    end
end
