class ApplicationsController < ApplicationController
  skip_before_action :set_current_application
  before_action :set_application, only: [:edit, :update, :destroy]

  # GET /applications
  # GET /applications.json
  def index
    @applications = current_user.applications
  end

  # GET /applications/new
  def new
    @application = current_user.applications.new
    @root_uri = URI.parse(root_url)
  end

  def create
    @application = current_user.applications.new(application_params)

    respond_to do |format|
      if @application.save
        format.html { redirect_to @application, notice: 'Application was successfully created.' }
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
        format.html { redirect_to applications_path, notice: 'Application was successfully updated.' }
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
      format.html { redirect_to applications_url, notice: 'Application was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = current_user.applications.find(params[:id])
      @current_application = @application
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def application_params
      params.require(:application).permit(:name, :data_retention_hours)
    end
end
