# frozen_string_literal: true

require 'api_client/base'

module ApiClient
  # ruby-client of server-authority for client-library: prosemirror-collab-plus
  class Collab < Base
    config.base_path = '/'
  end
end
