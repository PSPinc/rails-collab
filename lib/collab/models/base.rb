# frozen_string_literal: true

module Collab
  module Models
    class Base < ::Collab.config.base_record.constantize
      self.abstract_class = true
      self.table_name_prefix = 'collab_'
    end
  end
end
