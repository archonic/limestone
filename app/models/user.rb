class User < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :charges
  has_one_attached :avatar

  # If you create new roles and have existing data,
  # add the role at the end so you don't corrupt existing role integers
  enum role: %i[trial removed user admin]
  after_initialize :setup_new_user, if: :new_record?

  validates :first_name, presence: true
  validates :last_name, presence: true

  before_save :set_full_name

  def setup_new_user
    self.role ||= :trial
    self.trial_ends_at = Time.current + $trial_period_days.days
  end

  def subscribed?
    stripe_subscription_id?
  end

  # Send mail through activejob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def trial_role?
    role == 'trial'
  end

  def removed_role?
    role == 'removed'
  end

  def user_role?
    role == 'user'
  end

  def admin_role?
    role == 'admin'
  end

  def trial_expired?
    role == 'trial' &&
    trial_ends_at < Time.current
  end

  protected

  def set_full_name
    self.full_name = [first_name, last_name].join(' ').strip
  end
end
