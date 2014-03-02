class Post < ActiveRecord::Base
  belongs_to :topic, touch: true
  validates :content, presence: true, length: { maximum: 10000 }
end
