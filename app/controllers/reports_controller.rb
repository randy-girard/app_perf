class ReportsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    data = Application.select("pg_sleep(5)").first

    render :json => data
  end

  def error
    raise 'Hello'
  end

  def stress_test

    render json: {}, status: :ok
  end

  def profile
    @profile, @result = ::AppPerfRpm::Tracer.profile("test") do
      @profile = []
      @result = nil
      render_to_string "profile", :layout => false
    end
  end
end
