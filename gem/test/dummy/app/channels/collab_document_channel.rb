class CollabDocumentChannel < ApplicationCable::Channel
  include Collab::Channel

  private

  # Find the document to subscribe to based on the params passed to the channel
  # Authorization may also be performed here (raise an error to prevent subscription)
  def find_document
    Collab::Models::Document.find(params[:document_id])
  end

  # Called a commit is first received for processing
  # Throw an error to prevent the commit from being processed
  # You should consider adding some type of rate-limiting here
  def authorize_commit!(data)
    # no-op
  end
end
