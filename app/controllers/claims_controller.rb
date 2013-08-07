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
      if dealer_is_logged_in?
        format.html { render action: "dealer_edit" }
      elsif claims_is_logged_in?
        format.html { render action: "claims_edit" }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def dealer_edit

  end

  def dealer_show

  end

  # GET /claims/1
  # GET /claims/1.json
  def show
    @claim = Claim.find(params[:id])

    service = ClaimService.new
    brands = service.find_brands_in_town(@claim.nearest_town)
    @nearest_dealers = brands.brands

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @claim }
    end
  end

  # GET /claims/new
  # GET /claims/new.json
  def new
    @claim = Claim.new

    policy = Policy.find_by_id(params[:policy_id])
    if !policy.nil?
      @claim.policy_id = policy.id
      @claim.policy = policy
    end

    @towns = Agent.select("distinct town").collect { |t| t.town.strip if !t.town.nil? }
    @towns = @towns.reject { |t| t.nil? }

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
    service = ClaimService.new
    @claim = Claim.new(params[:claim])
    @claim.claim_no = service.create_claim_no

    respond_to do |format|
      if @claim.save
        format.html { redirect_to edit_claim_path(@claim) }
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
        if @claim.step == 1
          CustomerMailer.claim_registration(@claim).deliver
          format.html { redirect_to @claim, notice: 'Claim was successfully updated.' }
          service = ClaimService.new
          service.notify_customer @claim
        elsif @claim.step == 2
          format.html { render action: "dealer_show", notice: 'Claim was forwarded to KOIL team.' }
        elsif @claim.step == 3
          service = ClaimService.new
          if params[:commit] == "Approve"
            @claim.authorized = true
          else
            @claim.authorized = false
          end  
          @claim.save!
          service.resolve_claim @claim
          format.html { render action: "claims_show", notice: 'Claim has been finalized' }
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
