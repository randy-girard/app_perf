class SpansController < ApplicationController
  def show
    @span = Span
      .joins(:application)
      .where(:applications => { :organization_id => @current_organization })
      .find(params[:id])

    render :layout => false
  end
end
