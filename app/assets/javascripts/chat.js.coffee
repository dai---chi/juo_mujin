jQuery ->
  window.chatController = new Chat.Controller($('#posts').data('uri'), true);
  window.topicController = new Topic.Controller($('#topic').data('uri'), true);

window.Chat = {}
window.Topic = {}


class Chat.User
  constructor: (@user_name) ->
  serialize: => { user_name: @user_name }
class Topic.User
  constructor: (@user_name) ->
  serialize: => { user_name: @user_name }

class Chat.Controller
  template: (message) ->
    console.log('aaa')
    console.log(message)
    html = '<div class="message new_message">'
    for i in message.msg_body
      html += '<span style="font-size:'
      html += i.vol
      html += 'px;line-height:'
      html += i.vol - 15 # 要調整
      html += 'px;">'
      html += String.fromCharCode(i.keyCode)
      html += '</span>'
      # """<span>#{String.fromCharCode(message.msg_body[i].keyCode)}</span>"""
      # """
      # <div class="message new_message" >
      #   <label class="label label-info">
      #     [#{message.received}] #{message.user_name}
      #   </label>&nbsp;
      #   #{message.msg_body}
      # </div>
      # """
    html += '</div>'
    $(html)

  userListTemplate: (userList) ->
    userHtml = ""
    for user in userList
      userHtml = userHtml + "<li>#{user.user_name}</li>"
    $(userHtml)

  constructor: (url,useWebSockets) ->
    @messageQueue = []
    console.log("url: #{url}"
    "useWebSockets: #{useWebSockets}")
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @dispatcher.on_open = @createGuestUser
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'user_list', @updateUserList
    $('input#user_name').on 'keyup', @updateUserInfo
    $('#send_post').on 'click', @sendMessage
    $('#message_post').keypress (e) -> $('#send_post').click() if e.keyCode == 13

  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    @appendMessage message

  sendMessage: (event) =>
    # event.preventDefault()
    # message = $('#message_post').val()
    message = messageArr
    return if !message
    # topic_id = parseInt($('#topic_id').val())
    topic_id = $('#topic_selection option:selected').val()
    console.log("messageArr: #{messageArr}")
    console.log(messageArr)
    @dispatcher.trigger 'new_message', {user_name: @user.user_name, msg_body: messageArr, topic_id: topic_id}
    $('#message_post').val('')

  updateUserList: (userList) =>
    $('#user-list').html @userListTemplate(userList)

  updateUserInfo: (event) =>
    @user.user_name = $('input#user_name').val()
    $('#username').html @user.user_name
    @dispatcher.trigger 'change_username', @user.serialize()

  appendMessage: (message) ->
    messageTemplate = @template(message)
    # $('#topics').append messageTemplate
    # console.log("message.topic_id: "+message.topic_id)
    console.log("message: #{message}")
    console.log("messageTemplate: #{messageTemplate}")
    # $('#'+message.topic_id).children('.messages').prepend(messageTemplate).fadeOut(100).fadeIn(200)
    # $(messageTemplate).prependTo($('#'+message.topic_id).children('.messages')).hide().fadeIn(600)
    $(messageTemplate).prependTo($('#posts')).hide().fadeIn(600)
    # $('#'+message.topic_id).children('.messages').prepend.
    # messageTemplate.slideDown 140

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#posts div.messages:first').slideDown 100, ->
      $(this).remove()

  createGuestUser: =>
    rand_num = Math.floor(Math.random()*1000)
    @user = new Chat.User("Guest_" + rand_num)
    $('#username').html @user.user_name
    $('input#user_name').val @user.user_name
    @dispatcher.trigger 'new_user', @user.serialize()

class Topic.Controller
  template: (message) ->
    html =
      """
      <div id="#{message.topic_id}" class="topic_column">
          <h3>#{message.topic_id}</h3>
          <div class="messages">
          </div>
        </div>
      """
    $(html)

  userListTemplate: (userList) ->
    userHtml = ""
    for user in userList
      userHtml = userHtml + "<li>#{user.user_name}</li>"
    $(userHtml)

  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @dispatcher.on_open = @createGuestUser
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'new_topic', @newMessage
    @dispatcher.bind 'user_list', @updateUserList
    $('input#user_name').on 'keyup', @updateUserInfo
    $('#send_topic').on 'click', @sendMessage
    $('#message_topic').keypress (e) -> $('#send_topic').click() if e.keyCode == 13

  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    @appendMessage message

  sendMessage: (event) =>
    event.preventDefault()
    message = $('#message_topic').val()
    return if !message
    @dispatcher.trigger 'new_topic', {user_name: @user.user_name, msg_body: message}
    $('#message_topic').val('')

  updateUserList: (userList) =>
    $('#user-list').html @userListTemplate(userList)

  updateUserInfo: (event) =>
    @user.user_name = $('input#user_name').val()
    $('#username').html @user.user_name
    @dispatcher.trigger 'change_username', @user.serialize()

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#topics').prepend messageTemplate
    $('#topic_selection').prepend """<option value="#{message.topic_id}">#{message.topic_id}</option>"""
    $('#topic_selection').val("#{message.topic_id}")
    $('#message_post').focus()
    messageTemplate.slideDown 140

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#topic div.messages:first').slideDown 100, ->
      $(this).remove()

  createGuestUser: =>
    rand_num = Math.floor(Math.random()*1000)
    @user = new Topic.User("Guest_" + rand_num)
    $('#username').html @user.user_name
    $('input#user_name').val @user.user_name
    @dispatcher.trigger 'new_user', @user.serialize()