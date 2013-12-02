class FeedbacksController < ApplicationController
  def create
    @feedback = Feedback.new(params[:feedback])

	respond_to do |format|
	  if @feedback.save
    	format.json { render json: @feedback, status: :created, location: @feedback }
  	  else
	    format.json { render json: @feedback.errors, status: :unprocessable_entity }
	   end
	end
  end
end
