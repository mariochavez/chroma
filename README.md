# Chroma's Ruby client

Chroma is the open-source embedding database. Chroma makes it easy to build LLM apps by making knowledge, facts, and skills pluggable for LLMs.

This Ruby gem is a client to connect to Chroma's database via its API.

Find more information about Chroma on how to install at their website. [https://www.trychroma.com/](https://www.trychroma.com/)

## Description
Chroma-rb is a Ruby client for Chroma Database. It works with version 0.3.22 or better **(Please see requirements below)**.

A small example usage

```ruby
require "logger"

# Requiere Chroma Ruby client.
require "chroma-db"

# Configure Chroma's host. Here you can specify your own host.
Chroma.connect_host = "http://localhost:8000"
Chroma.logger = Logger.new($stdout)
Chroma.log_level = Chroma::LEVEL_ERROR

# Check current Chrome server version
version = Chroma::Resources::Database.version
puts version

# Create a new collection
collection = Chroma::Resources::Collection.create(collection_name, {lang: "ruby", gem: "chroma-db"})

# Add embeddings
embeddings = [
  Chroma::Resources::Embedding.new(id: "1", embedding: [1.3, 2.6, 3.1], metadata: {client: "chroma-rb"}, document: "ruby"),
  Chroma::Resources::Embedding.new(id: "2", embedding: [3.7, 2.8, 0.9], metadata: {client: "chroma-rb"}, document: "rails")
]
collection.add(embeddings)
```

For a complete example, please refer to the Jupyter Noterbook [Chroma gem](https://github.com/mariochavez/chroma/blob/main/notebook/Chroma%20Gem.ipynb)

## Requirements
- Ruby 2.7.8 or newer
- Chroma Database 0.4.24 or later running as a client/server model.

For Chroma database 0.3.22 or older, please use version 0.3.0 of this gem.

## Installation
To install the gem and add to the application's Gemfile, execute:

    $ bundle add chroma-db

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install chroma-db

## Use the Jupyter notebook
To use the Jupyter Noterbook [Chroma gem](https://github.com/mariochavez/chroma/blob/main/notebook/Chroma%20Gem.ipynb) in this repository, please install python 3.9 or better, iruby and Jupyter notebook dependencies:

    $ pip install jupyterlab notebook ipywidgets
    $ gem install iruby
    $ iruby register --force

**NOTE: ** Notebook has an example on how to create embeddings using [Ollama](https://ollama.com) and [Nomic embed text](https://ollama.com/library/nomic-embed-text) with a simple Ruby HTTP client.
## Development 
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`.

To generate Rdoc documentation for the gem, run `bundle exec rake rdoc`.

## Rails integration
If you are looking for a solution to embed your ActiveRecord models into ChromaDB, look at [Cromable gem](https://github.com/AliOsm/chromable)
## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/mariochavez/chroma. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/mariochavez/chroma/blob/main/CODE_OF_CONDUCT.md). 

## License
The gem is available as open source under the terms of the [MIT License](https://github.com/mariochavez/chroma/blob/main/LICENSE.txt).

## Code of Conduct
Everyone interacting in the Chroma project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mariochavez/chroma/blob/main/CODE_OF_CONDUCT.md).
