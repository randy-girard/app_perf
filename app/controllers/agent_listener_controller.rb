require 'base64'
require 'json'
require 'zlib'
require 'stringio'

class AgentListenerController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!

  def create
    #AppPerfRpm.without_tracing do
      params.permit!

      request.body.rewind

      case params[:protocol_version].to_s
      when "2"
        AppPerfAgentWorker.perform_later(params, request.body.read)
      when "3"
        OpenTracingWorker.perform_later(params, request.body.read)
      end

      render :text => "", :status => :ok
    #end
  end
end
