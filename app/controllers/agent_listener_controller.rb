require 'base64'
require 'json'
require 'zlib'
require 'stringio'

class AgentListenerController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!

  def create
    params.permit!

    EventsWorker.perform_later(params)

    render :text => "", :status => :ok
  end

  def invoke_raw_method
    response = NewRelicWorker.new(params).execute

    render :json => response, :status => :ok
  end

  private

  def parse_body(request)
    request.body.rewind
    body = request.body.read
    body = Zlib::Inflate.inflate(body)
    JSON.parse body
  end
end

