module ApplicationHelper
  def topic_list
    # Topic.all.map(&:title)
    arr = []
    for i in Topic.all.order('created_at DESC')
      arr << { topic: i,
               posts: i.posts.order('created_at DESC').limit(5)}
    end
    # binding.pry
    arr
  end
end
