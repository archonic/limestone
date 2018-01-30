class User < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :invoices
  has_one_attached :avatar
  # set optional: true if you don't want the default Rails 5 belongs_to presence validation
  belongs_to :plan

  validates :email, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :first_name, presence: true
  validates :last_name, presence: true

  # If you create new roles and have existing data,
  # add the role at the end so you don't corrupt existing role integers
  enum role: %i[trial removed user admin]
  after_initialize :setup_new_user, if: :new_record?

  delegate :cost, to: :plan

  before_save :set_full_name

  def setup_new_user
    self.role ||= :trial
    self.current_period_end = Time.current + $trial_period_days.days
  end

  def subscribed?
    self.user? &&
    stripe_subscription_id.present?
  end

  # Send mail through activejob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def trial_expired?
    self.trial? &&
    current_period_end < Time.current
  end

  protected

  def set_full_name
    self.full_name = [first_name, last_name].join(' ').strip
  end
end
