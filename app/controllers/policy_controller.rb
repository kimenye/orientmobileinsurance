class PolicyController < ApplicationController

  def show_details
    @policy = Policy.find_all_by_policy_number(params[:policy_no])

    respond_to do |format|
      format.html { render action: "policy_details" }
    end
  end

  def policy_details

  end

end