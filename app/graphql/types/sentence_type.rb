# frozen_string_literal: true

Types::SentenceType = GraphQL::InterfaceType.define do
  name 'Sentence'
  description 'A logical sentence'

  Types::SentenceMethods.get(self)
end
