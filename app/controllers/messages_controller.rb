class MessagesController < ApplicationController
  include MessagesHelper

  before_action :logged_in_user

  def create
    @receiver = User.find_by(id: params[:user_id])
    @room = exists_chatroom current_user, @receiver
    if @room == nil
      @room = ChatRoom.new(name: "#{current_user.username} and #{@receiver.username}")
      @room.users << @receiver
      @room.users << current_user
      @room.save
    end
    #problem: if we resend the post request, a duplicate message ends up being
    #created. But it is a problem when I keep resending the request to look at debug
    #information. Would this happen in real life if I prohibit the send button from being clicked
    #twice?
    current_user.messages.build(content: params[:message][:content], chat_room_id: @room.id)
    current_user.save
    #it might not be true that a user looks at a chatroom when they send a message
    ChatRoomsUser.where("user_id = ?", current_user.id).find_by(chat_room_id: @room.id)
                 .update_attributes(last_viewed: Time.now)
    render 'chats/index'
  end

  def new
    @message = Message.new
  end

  #TODO: When this loads, current_user's last_viewed should update
  def show
  end

  private
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please Log In"
        redirect_to login_url, notice: "Please Log In"
      end
    end

end
