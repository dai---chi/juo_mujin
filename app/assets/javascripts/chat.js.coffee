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
        </label>&nbsp; <br>
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
    console.log("message.topic_id: "+message.topic_id)
    column = $('#'+message.topic_id)
    if $('#topics').children()[0].id == column.attr('id')
      column.children('.messages').children('.message').removeClass('new_message')
      column.children('.messages').prepend(messageTemplate)
    else # cf. http://jsfiddle.net/ebiewener/Y5Mdt/1/
      h = column.outerWidth()
      pos = column.position()
      column.css({
        position:'absolute',
        left: pos.left,
        top: pos.top })
      column.animate({left:0}, 800, 'easeInOutExpo')
      column.next().animate({marginLeft: -1 }, 800, 'easeInOutExpo');
      column.parent().animate({
        paddingLeft: h - 1
      }, 800, 'easeInOutExpo', =>
        column.parent().css('padding-left', '')
        column.parent().children(':first').before(column);
        column.css('position', 'relative');
        column.siblings().css({paddingLeft: ''});
        column.children('.messages').prepend(messageTemplate)
      )

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
      <div id="#{message.topic_id}" class='topic_column new_topic'>
          <h3 class='topic_title'>#{message.topic_id}</h3>
          <div class='messages'>
          </div>
        </div>
      """
    $(html)

  userListTemplate: (userList) ->
    userHtml = ''
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