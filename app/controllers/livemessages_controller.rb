 class LivemessagesController < ApplicationController


  def create
    @event = Event.find(params[:event_id])
    @livemessage = Livemessage.new(params_livemessage)
    @livemessage.user = current_user
    @livemessage.event = @event
    if @livemessage.save!
      flash[:notice] = "Message sent"

      json = {
        message: @livemessage.description,
        user: @livemessage.user.full_name,
        id: @livemessage.id
      }
      LivemessageJob.perform_later(@event.token, json)
      render json: json
    else
      flash[:notice] = "Some error occured. Message sent failure "
    end
  end

  private


   def params_livemessage
     params.require(:livemessage).permit(:description)
   end
 end
