# Configuration for the collab gem
Collab.config do |c|
  # The NPM package containing the document schema. This will be require()d from your Rails directory
  # To use a Git repo, see https://docs.npmjs.com/files/package.json#git-urls-as-dependencies
  c.schema_package = "prosemirror-schema-basic"
  # How many old transactions to keep per document
  c.max_transactions = 250

  # ActionCable settings
  # ====================
  # The document channel to use for collaboration
  # If you change this, you must pass {channel: "[ChannelName]"} as subscription params to the Javascript client
  c.channel = "CollabDocumentChannel"

  # ActionJob settings
  # ==================
  # The base job class to use
  c.application_job = "ApplicationJob"
  # The commit job to use
  c.commit_job = "Collab::CommitJob"


  # ActiveRecord settings
  # =====================
  # The class which models in the gem should inherit from
  c.application_record = "ApplicationRecord"
  # If you want to use your own document or commit model, 
  c.document_model = "Collab::Models::Document"
  c.commit_model = "Collab::Models::Commit"
end
