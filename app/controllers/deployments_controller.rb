class DeploymentsController < ApplicationController
  def index
    @deployments = @current_application
      .deployments
      .order(:start_time)
      .reverse_order

    respond_to do |format|
      format.html {}
      format.json { render :json => @deployments }
    end
  end

  def new
    @deployment = @current_application.deployments.new
    @deployment.event_time = Time.now.strftime("%Y-%m-%d %I:%M %p")
  end

  def create
    @deployment = @current_application.deployments.new(deployment_params)

    if @deployment.save
      redirect_to dynamic_url(@current_application, :deployments)
    else
      render "new"
    end
  end

  private

  def deployment_params
    params.require(:deployment).permit(
      :title,
      :description,
      :event_time
    )
  end
end
