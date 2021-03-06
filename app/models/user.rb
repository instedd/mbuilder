class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :confirmed_at
  # attr_accessible :title, :body

  has_many :applications, dependent: :destroy
  has_many :identities, dependent: :destroy

  after_save :touch_lifespan
  after_destroy :touch_lifespan

  private

  def touch_lifespan
    Telemetry::Lifespan.touch_user(self)
  end
end
