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
    html =
      """
      <div class="message new_message" >
        <label class="label label-info">
          [#{message.received}] #{message.user_name}
        </label>&nbsp;
        #{message.msg_body}
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
    event.preventDefault()
    message = $('#message_post').val()
    return if !message
    # topic_id = parseInt($('#topic_id').val())
    topic_id = $('#topic_selection option:selected').val()
    @dispatcher.trigger 'new_message', {user_name: @user.user_name, msg_body: message, topic_id: topic_id}
    $('#message_post').val('')

  updateUserList: (userList) =>
    $('#user-list').html @userListTemplate(userList)

  updateUserInfo: (event) =>
    @user.user_name = $('input#user_name').val()
    $('#username').html @user.user_name
    @dispatcher.trigger 'change_username', @user.serialize()

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#posts').append messageTemplate
    console.log("message.topic_id: "+message.topic_id)
    # $('#'+message.topic_id).children('.messages').prepend(messageTemplate).fadeOut(100).fadeIn(200)
    $(messageTemplate).prependTo($('#'+message.topic_id).children('.messages')).fadeOut(100).fadeIn(200)
    # $('#'+message.topic_id).children('.messages').prepend.
    messageTemplate.slideDown 140

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
      <div class="message new_message" >
        <label class="label label-info">
          [#{message.received}] #{message.user_name}
        </label>&nbsp Topic;
        #{message.msg_body}
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
    $('#topic').append messageTemplate
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