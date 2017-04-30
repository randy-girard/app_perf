require 'base64'
require 'json'
require 'zlib'
require 'stringio'

class AgentListenerController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!

  def create
    params.permit!

    request.body.rewind
    AppPerfAgentWorker.perform_later(params, request.body.read)

    render :text => "", :status => :ok
  end

  private

  def parse_body(request)
    request.body.rewind
    body = request.body.read
    body = Zlib::Inflate.inflate(body)
    JSON.parse body
  end
end
