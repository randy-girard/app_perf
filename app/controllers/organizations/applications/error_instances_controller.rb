class Organizations::Applications::ErrorInstancesController < ApplicationController
  before_action :set_error_message

  def index
    @error_instances = @error_message.error_data.order("created_at DESC")
  end

  def show
    @error_instance = @error_message.error_data.find(params[:id])
  end

  private

  def set_error_message
    @error_message = @current_application.error_messages.find(params[:error_id])
  end
end
