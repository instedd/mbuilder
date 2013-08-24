class Identity < ActiveRecord::Base
  attr_accessible :provider, :token

  belongs_to :user
end
