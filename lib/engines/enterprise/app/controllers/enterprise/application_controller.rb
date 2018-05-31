module Enterprise
  class ApplicationController < ::ApplicationController
    protect_from_forgery with: :exception

    def enterprise?
      true
    end
  end
end
