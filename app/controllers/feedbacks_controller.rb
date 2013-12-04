class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(params[:feedback])

    send_email

	respond_to do |format|
	  if @feedback.save
    	format.json { render json: @feedback, status: :created, location: @feedback }
  	  else
	    format.json { render json: @feedback.errors, status: :unprocessable_entity }
	   end
	end
  end

  def send_email
  	feedback = @feedback
  	CustomerMailer.feedback_mailer(feedback).deliver
  end
end
