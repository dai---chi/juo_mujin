module ApplicationHelper
  def topic_list
    Topic.all.map(&:title).uniq
  end
end
