module API
  module V1
    module Defaults
      extend ActiveSupport::Concern

      included do
        plugin :json
        plugin :all_verbs
        plugin :hooks
        plugin :sinatra_helpers
        
        def annotations
          ::Stats::AnnotationsService.new(@current_application, @time_range, @params).call
        end
      end
    end
  end
end
