class Topic < ActiveRecord::Base
  has_many :posts
  validates :title, presence: true, length: { maximum: 80 }
  validates_uniqueness_of :title
end
