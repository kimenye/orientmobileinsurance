class ClaimsController < ApplicationController
  #include Wicked::Wizard

  # GET /claims
  # GET /claims.json
  def index
    @claims = Claim.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @claims }
    end
  end

  def search
    @claim = Claim.find_by_claim_no(params[:claim_no])
    respond_to do |format|
      format.html { render action: "edit" }
    end
  end

  # GET /claims/1
  # GET /claims/1.json
  def show
    @claim = Claim.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @claim }
    end
  end

  # GET /claims/new
  # GET /claims/new.json
  def new
    @claim = Claim.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @claim }
    end
  end

  # GET /claims/1/edit
  def edit
    if  user_signed_in? || customer_can_see_claim?(params[:id])
      @claim = Claim.find_by_id(params[:id])
    else
      redirect_to customer_path
    end
  end

  # POST /claims
  # POST /claims.json
  def create
    @claim = Claim.new(params[:claim])

    respond_to do |format|
      if @claim.save
        format.html { redirect_to @claim, notice: 'Claim was successfully created.' }
        format.json { render json: @claim, status: :created, location: @claim }
      else
        format.html { render action: "new" }
        format.json { render json: @claim.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /claims/1
  # PUT /claims/1.json
  def update
    @claim = Claim.find(params[:id])

    respond_to do |format|
      if @claim.update_attributes(params[:claim])
        @claim.step += 1
        if @claim.step < 5
          format.html { render action: "edit", notice: 'Claim was successfully updated.' }
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @claim.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /claims/1
  # DELETE /claims/1.json
  def destroy
    @claim = Claim.find(params[:id])
    @claim.destroy

    respond_to do |format|
      format.html { redirect_to claims_url }
      format.json { head :no_content }
    end
  end
end
