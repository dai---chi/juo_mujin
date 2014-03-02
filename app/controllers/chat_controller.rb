class ChatController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def initialize_session
    puts "Session Initialized\n"
  end

  def system_msg(ev, msg)
    broadcast_message ev, {
      user_name: 'system',
      received: Time.now.to_s(:short),
      msg_body: msg
    }
  end

  def user_msg(ev, msg, info)
    broadcast_message ev, {
      user_name:  connection_store[:user][:user_name],
      received:   Time.now.to_s(:short),
      msg_body:   ERB::Util.html_escape(msg),
      topic_id:   info[:topic_id]
    }
    p "ev: #{ev}"
    p "msg: #{msg}"
  end

  def client_connected
    system_msg :new_message, "client #{client_id} connected"
  end

  def new_message
    # binding.pry
    user_msg :new_message, message[:msg_body].dup, {topic_id: message[:topic_id]}
    Topic.find_by({title: message[:topic_id]}).posts.create({
      content: message[:msg_body]
    }) # prototype
  end
  def new_topic
    user_msg :new_topic, message[:msg_body].dup, {}
    Topic.create({
      title: message[:msg_body]
    })
  end

  def new_user
    connection_store[:user] = { user_name: sanitize(message[:user_name]) }
    broadcast_user_list
  end

  def change_username
    connection_store[:user][:user_name] = sanitize(message[:user_name])
    broadcast_user_list
  end

  def delete_user
    connection_store[:user] = nil
    system_msg "client #{client_id} disconnected"
    broadcast_user_list
  end

  def broadcast_user_list
    users = connection_store.collect_all(:user)
    broadcast_message :user_list, users
  end

end
