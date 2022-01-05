# Collab

Real-time collaborative document editing for Ruby on Rails using ActionCable & Prosemirror based on operational transforms.

> This gem isn't recommended for production use, as the concurrency method for updating documents will strugle under high load.

Client library: https://github.com/benaubin/prosemirror-collab-plus

## How it works

The collab gem exposes an ActionCable channel (`CollabDocumentChannel`) enabling users to start a real-time editing session.
A client may submit one or many steps in a DocumentTransaction to the server, alongside a reference for processing. The gem
attempts to apply the transaction to the document in a background job (`Collab::DocumentTransactionJob`). The job first checks
that the operation applies to the current version of the document, and if so, uses a NodeJS child process running ProseMirror
and JSDom to apply the transaction. If successful, the document is saved and the transaction is broadcasted to clients.

## Requirements

- ActionCable
- ~~NodeJS in the Rails environment, with a `node` executible on the `$PATH```
- A prose-node TCP service (default port: 8080)

## Getting started

0. Setup the prose-node TCP service

See prose-node repository for details.

1. (node) Expose a [ProseMirror schema] as a NodeJS package (use the package
   registry of choice or a private Git repository) so that it can be accessed
   either client-side or server-side.

```js
module.exports.plainText = new Schema({
  nodes: {
    text: {},
    doc: { content: "text*" },
  },
});
```

2. Inside the Rails app, install the gem ~~and the npm packages necessary for
   applying document transforms server-side~~

```sh
bundle add collab
# yarn add @pmcp/authority prosemirror-model prosemirror-transform [a-schema-package]
```

Add something akin to the following in `Gemfile`:

```ruby
gem 'collab', github: 'PSPinc/rails-collab', branch: :develop
```


3. Generate the initalizer and migration

```sh
rails g collab:install
```

4. Configure the gem in `config/initializers/collab.rb`. Set `schema_package`
   to the name of a schema package.

5. Run `rails db:migrate`

6. Add `HasCollaborativeDocument` to a model

```rb
class BlogPost < ApplicationRecord
  include Collab::HasCollaborativeDocument

  # schema: name of the export from a schema package
  # blank_document: document used for version 0
  has_collaborative_document :body,
                              schema: Collab.config.schema_package,
                              blank_document: {
                                type: 'doc', content => [{ type: 'paragraph', text: "" }]
                              }

end
```

7. Add authorization logic to `app/channels/collab_document_channel.rb`

```ruby
class ConversationChannel < ApplicationCable::Channel
  include Collab::Channel

  # TODO: integrate document authorization logic here
end
```

8. (node) Install the client library

```sh
yarn add prosemirror-collab-plus rails-collab [a-schema-package]
```

9. (node) Add the railsCollab plugin to a ProseMirror view:

```js
import { EditorView } from "prosemirror-view";
import { EditorState } from "prosemirror-state";
import { railsCollab } from "rails-collab";
import { plainText } from "[a-schema-package]";

const cable = ActionCable.createConsumer("ws://cable.example.com");

const originalDocument = blogPost.body; // from ERB, <%= raw json_escape(@blog_post.body.to_json) %>

const target = document.getElementById("editor-view");

const view = new EditorView(target, {
  state: EditorState.create({
    doc: plainText.nodeFromJSON(originalDocument.document),
    plugins: [
      railsCollab({
        cable,
        startingVersion: originalDocument.version,
        params: { document_id: originalDocument.id },
      }),
    ],
  }),
});

// later, to unsubscribe & destroy the editor:
// view.destroy();
```

10. 🎉 You're done! Start collaborating.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow experimentation.

To install this gem locally, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

### Local development / contributor

From within a projects root path, run the following:

```sh
bundle config local.collab ../rails-collab
```

This will update `~/.bundle/config` to point bundler to something maintainable

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/benaubin/collab. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct].

## License

The gem is available as open source under the terms of the [MIT License](LICENSE).

## Code of Conduct

Everyone interacting in the Collab project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct].

[prosemirror schema]: https://prosemirror.net/examples/schema/
[code of conduct]: https://github.com/PSPinc/rails-collab/blob/master/CODE_OF_CONDUCT.md
