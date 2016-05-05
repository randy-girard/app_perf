module SystemMetrics
  module Instrument
    class ActionMailer < SystemMetrics::Instrument::Base

      def initialize
        super /\.action_mailer$/
      end

      def prepare(event)
        event.payload.except!(:mail)
      end

    end
  end
end
