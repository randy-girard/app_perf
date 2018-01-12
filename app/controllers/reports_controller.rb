class ReportsController < ApplicationController
  def new
    data = Application.select("pg_sleep(5)").first

    render :json => data
  end

  def error
    raise 'Hello'
  end

  def profile
    @profile, @result = ::AppPerfRpm::Tracer.profile("test") do
      @profile = []
      @result = nil
      render_to_string "profile", :layout => false
    end
  end
end
