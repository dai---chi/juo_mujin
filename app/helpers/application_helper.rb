module ApplicationHelper
  def topic_list
    # Topic.all.map(&:title)
    arr = []
    for i in Topic.all
      arr << { topic: i,
               posts: i.posts}
    end
    # binding.pry
    arr
  end
end
