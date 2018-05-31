class ApplicationsController < ApplicationController
  before_action :set_application, only: [:edit, :update, :destroy]

  # GET /applications
  # GET /applications.json
  def index
    @applications = @application_scope
  end

  # GET /applications/new
  def new
    @application = @application_scope.new
    @root_uri = URI.parse(root_url)
  end

  def create
    @application = @application_scope.new(application_params)

    respond_to do |format|
      if @application.save
        format.html { redirect_to dynamic_url(@application, action: :edit), notice: 'Application was successfully created.' }
        format.json { render :show, status: :ok, location: @application }
      else
        format.html { render :new }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /applications/1/edit
  def edit
  end

  # PATCH/PUT /applications/1
  # PATCH/PUT /applications/1.json
  def update
    respond_to do |format|
      if @application.update(application_params)
        format.html { redirect_to dynamic_url(@application, action: :edit), notice: 'Application was successfully updated.' }
        format.json { render :show, status: :ok, location: @application }
      else
        format.html { render :edit }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applications/1
  # DELETE /applications/1.json
  def destroy
    @application.destroy
    respond_to do |format|
      format.html { redirect_to dynamic_url(:applications), notice: 'Application was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = @application_scope.find(params[:id])
      @current_application = @application
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def application_params
      params.require(:application).permit(:name)
    end
end
