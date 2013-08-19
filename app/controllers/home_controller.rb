class HomeController < ApplicationController
  def index
    @users = User.all
    @claims = Claim.all
  end
end
