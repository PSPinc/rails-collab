module Collab
  class Range
    attr_reader :anchor, :head
    def initialize(anchor, head)
      @anchor = anchor
      @head = head
    end

    def self.resolve(document, anchor_pos, head_pos, version:)
      anchor_assoc = anchor_pos > head_pos ? -1 : 1

      ::Collab.config.tracked_position_model.constantize.resolve(
        document,
        {"pos" => anchor_pos, "assoc" => anchor_assoc},
        {"pos" => head_pos, "assoc" => anchor_assoc * -1},
        version: version
      ) do |anchor, head|
        yield new anchor, head
      end
    end
  end
end