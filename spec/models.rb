class User < ActiveRecord::Base
  has_many :pets
end

class Pet < ActiveRecord::Base
  belongs_to :user
end