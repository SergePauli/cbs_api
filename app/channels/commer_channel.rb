class CommerChannel < ApplicationCable::Channel
  # Called when the consumer has successfully
  # become a subscriber to this channel.
  def subscribed
    stream_from "commer_#{params[:user_id]}"
  end

  def receive(data)
    puts data
  end
end
