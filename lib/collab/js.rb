# frozen_string_literal: true

require 'json'
require 'api_client/collab'

module Collab
  # wrapper around applyCommit, docToHtml, htmlToDoc, and mapThroughSteps
  module JS
    include ActiveSupport::Configurable
    config_accessor :resolve_modes

    config.resolve_modes = {
      http: %i[apply_commit doc_to_html map_through html_to_doc]
    }

    @queue = Queue.new
    @queue_initialized = false
    @queue_initialization_mutex = Mutex.new

    class << self
      def queue
        initialize_queue unless @queue_initialized
        @queue
      end

      # Calls the block given with a JS process acquired from the queue
      # Will block until a JS process is available
      def with_js
        js = queue.pop
        yield js
      ensure
        queue << js
      end

      def call(name, data = nil, schema_name = nil)
        req = { name: name, data: data, schemaPackage: ::Collab.config.schema_package }
        req[:schemaName] = schema_name if schema_name
        with_js { |js| js.call(JSON.generate(req)) }
      end

      def apply_commit(document, commit, map_steps_through:, schema_name:, pos: nil)
        if config.resolve_modes.fetch(:http, []).include?(:apply_commit)
          return apply_commit_http(
            schema_name: schema_name,
            content: document,
            commit: commit,
            map_steps_through: map_steps_through, pos: pos
          )
        end

        call(
          'applyCommit',
          { doc: document, commit: commit, mapStepsThrough: map_steps_through, pos: pos },
          schema_name
        )
      end

      def apply_commit_http(**kwargs)
        api_client.expect_json_response

        body_data = kwargs.fetch(:content).merge(
          commit: kwargs.fetch(:commit),
          mapStepsThrough: kwargs.fetch(:map_steps_through),
          pos: kwargs.fetch(:pos)
        ).stringify_keys

        faraday_response = api_client.post(
          '/api/v1/prose/apply-commit',
          body_data.to_json,
          api_client.http_headers
        )
        resp = api_client.handle_response(response: faraday_response)
        return JSON.parse(resp) if api_client.success_response?(response: faraday_response)

        raise Faraday::ServerError, resp
      end

      def api_client
        @api_client ||= ApiClient::Collab.new
      end

      def html_to_document(html, schema_name:)
        if config.resolve_modes.fetch(:http, []).include?(:html_to_doc)
          return html_to_document_http(html: html)
        end

        call('htmlToDoc', html, schema_name)
      end

      def html_to_document_http(**kwargs)
        api_client.expect_html_response

        faraday_response = api_client.post(
          '/api/v1/prose/html-to-doc',
          { html: kwargs.fetch(:html) }.to_json,
          api_client.http_headers
        )
        resp = api_client.handle_response(response: faraday_response)
        return JSON.parse(resp) if api_client.success_response?(response: faraday_response)

        raise Faraday::ServerError, resp
      end

      def document_to_html(document, schema_name:)
        if config.resolve_modes.fetch(:http, []).include?(:doc_to_html)
          return document_to_html_http(
            document: document
          )
        end

        call('docToHtml', document, schema_name)
      end

      def document_to_html_http(**kwargs)
        api_client.expect_html_response

        faraday_response = api_client.post(
          '/api/v1/prose/doc-to-html',
          {
            doc: {
              type: 'doc',
              content: kwargs.fetch(:document).dig('doc', 'content')
            }
          }.to_json,
          api_client.http_headers
        )
        api_client.handle_response(response: faraday_response)
      end

      def map_through(steps:, pos:)
        if config.resolve_modes.fetch(:http, []).include?(:map_through)
          return map_through_http(steps: steps, pos: pos)
        end

        call('mapThru', { steps: steps, pos: pos })
      end

      def map_through_http(**kwargs)
        api_client.expect_json_response

        faraday_response = api_client.post(
          '/api/v1/prose/map-thru',
          kwargs.slice(:steps, :pos).to_json,
          api_client.http_headers
        )
        resp = api_client.handle_response(response: faraday_response)
        return JSON.parse(resp) if api_client.success_response?(response: faraday_response)

        raise Faraday::ServerError, resp
      end

      private

      # Thread-safe initialization of the NodeJS process queue
      def initialize_queue
        @queue_initialization_mutex.synchronize do
          unless @queue_initialized
            ::Collab.config.num_js_processes.times { @queue << ::Collab::JS::JSProcess.new }
            @queue_initialized = true
          end
        end
      end
    end

    # wrapper for calls to forked node
    class JSProcess
      def initialize
        @node = if defined?(Rails)
                  Dir.chdir(Rails.root) { open_node }
                else
                  open_node
                end
      end

      def call(req)
        @node.puts(req)
        res = JSON.parse(@node.gets)
        raise ::Collab::JS::JSRuntimeError, res['error'] if res['error']

        res['result']
      end

      private

      def open_node
        IO.popen(['node', '-e', "require('@pmcp/authority/dist/rpc')"], 'r+')
      end
    end

    # errors from node
    class JSRuntimeError < StandardError
      def initialize(data)
        if data['stack']
          @js_backtrace = data['stack'].split("\n").map do |fn|
            "JavaScript #{fn.strip}"
          end
        end

        super("#{data['name']}: #{data['message']}")
      end

      def backtrace
        return unless (val = super)

        if @js_backtrace
          @js_backtrace + val
        else
          val
        end
      end
    end
  end
end
