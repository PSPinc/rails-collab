# frozen_string_literal: true

class CollabDocumentChannel < ApplicationCable::Channel
  include Collab::Channel

  def commit(data)
    raise 'authorization not implemented' if false # replace with your own authorization logic

    super # make sure to call super in order to process the commit
  end

  private

  # Find the document to subscribe to based on the params passed to the channel
  # Authorization may also be performed here (raise an error to prevent subscription)
  def find_document
    Collab::Models::Document.find(params[:document_id]).tap do |_document|
      # TODO: Replace with your own authorization logic
      reject_unauthorized_connection
    end
  end

  # Uncomment this line to receive the user's selection
  # You must allow enable syncSelection on the client
  #
  # def _select(selection)
  #   ...
  # end
end
