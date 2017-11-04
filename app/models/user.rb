class User < ApplicationRecord
  # acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :charges
  has_one :avatar

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

  def avatar_url(size = :sm)
    if avatar.present?
      url = avatar.image[size].url(public: true)
    else
      width = Avatar.sizes[size]
      hash = Digest::MD5.hexdigest(email.try(:downcase) || 'noemail')
      url = "https://secure.gravatar.com/avatar/#{hash}?d=blank&s=#{width}"
    end
    url
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
