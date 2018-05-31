module API
  module V1
    class Stats < Roda
      include API::V1::Defaults
      include API::V1::Authentication

      route do |r|
        @params = r.params.symbolize_keys

        require_login!(r)

        @time_range, @period = Reporter.time_range(@params)
        @current_application = Application.find(@params[:application_id])

        r.on 'stats' do
          r.get 'average_duration' do
            data = DurationReporter.new(@current_application, @params).report_data

            {
              :data => data,
              :annotations => annotations
            }
          end

          r.get 'latency' do
            data = PercentileReporter.new(@current_application, @params).report_data

            {
              :data => data,
              :annotations => annotations
            }
          end

          r.get 'latency_distribution' do
            data = ::Stats::LatencyDistributionService.new(@current_application, @time_range, @params).call

            {
              :data => data
            }
          end

          r.get 'hosts' do
            data = ::Stats::HostsService.new(@current_application, @time_range, @params).call

            {
              :data => data
            }
          end

          r.get 'controllers' do
            data = ::Stats::ControllersService.new(@current_application, @time_range, @params).call

            {
              :data => data
            }
          end

          r.get 'urls' do
            data = ::Stats::UrlsService.new(@current_application, @time_range, @params).call

            {
              :data => data
            }
          end

          r.get 'layers' do
            data = ::Stats::LayersService.new(@current_application, @time_range, @params).call

            {
              :data => data
            }
          end

          r.get 'traces' do
            data = ::Stats::TracesService.new(@current_application, @time_range, @params).call

            {
              :data => data
            }
          end

          r.get 'database' do
            data = DatabaseReporter.new(@current_application, @params).report_data

            {
              :data => data,
              :annotations => annotations
            }
          end

          r.get 'database_calls' do
            data = ::Stats::DatabaseCallsService.new(@current_application, @time_range, @params).call

            {
              :data => data
            }
          end
        end
      end
    end
  end
end
