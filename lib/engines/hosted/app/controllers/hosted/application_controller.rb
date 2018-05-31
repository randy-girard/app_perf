module Hosted
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception

    def hosted?
      true
    end
  end
end
