class ReportsController < ApplicationController

  before_filter :authenticate_admin_user!

  def index

  end

  def download_data

    start_date = params[:start_date]
    end_date = params[:end_date]

    @policies = Policy.all(:conditions => {:start_date => start_date..end_date})

    respond_to do |format|
      format.xls
    end
  end

end
