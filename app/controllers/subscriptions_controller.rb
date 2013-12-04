class SubscriptionsController < ApplicationController

	def create
	    @subscription = Subscription.new(params[:subscription])
    
    	respond_to do |format|
    	  if @subscription.save
        	format.json { render json: @subscription, status: :created, location: @subscription }
      	  else
    	    format.json { render json: @subscription.errors, status: :unprocessable_entity }
    	   end
		end
    end

end
