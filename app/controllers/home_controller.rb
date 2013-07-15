class HomeController < ApplicationController
  def index
    @users = User.all
  end

  #TODO: this is temporary
  def notification

    puts ">>>> Notification:   #{params}"
    respond_to do |format|
      format.all { render json: {success: true}, status: 200 }
    end
  end
end
