# frozen_string_literal: true

require 'api_client/base'

module ApiClient
  # ruby-client of server-authority for client-library: prosemirror-collab-plus
  class Collab < Base
    config.base_path = '/'

    def initializer(**kwargs)
      @service_uri = kwargs[:service_uri] || 'http://localhost:8282'
    end
  end
end
