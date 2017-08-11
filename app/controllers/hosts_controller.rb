class HostsController < ApplicationController

  def index
    @hosts = @current_organization.hosts
  end

  def show
    @host = @current_organization.hosts.find(params[:id])
  end
end
