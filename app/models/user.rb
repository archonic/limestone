class User < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :charges
  has_one_attached :avatar

  enum role: %i[trial user admin]
  after_initialize :set_default_role, if: :new_record?

  validates :first_name, presence: true
  validates :last_name, presence: true

  before_save :set_full_name

  def set_default_role
    self.role ||= :trial
  end

  def subscribed?
    stripe_subscription_id?
  end

  # Send mail through activejob
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  protected

  def set_full_name
    self.full_name = [first_name, last_name].join(' ').strip
  end
end
