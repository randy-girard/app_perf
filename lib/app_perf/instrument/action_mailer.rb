module AppPerf
  module Instrument
    class ActionMailer < AppPerf::Instrument::Base

      def initialize
        super /\.action_mailer$/
      end

      def prepare(event)
        event.payload.except!(:mail)
      end

    end
  end
end
