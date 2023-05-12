# frozen_string_literal: true

module Chroma
  module Resources
    # A Embedding class represents an embedding by its Id, metadata, and document.
    # This class is used by Collection class.
    class Embedding
      attr_reader :id
      attr_reader :embedding
      attr_reader :metadata
      attr_reader :document
      attr_reader :distance

      def initialize(id:, embedding: nil, metadata: nil, document: nil, distance: nil)
        @id = id
        @embedding = embedding
        @metadata = metadata
        @document = document
        @distance = distance
      end
    end
  end
end
