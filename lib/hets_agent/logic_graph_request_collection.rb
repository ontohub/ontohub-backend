# frozen_string_literal: true

module HetsAgent
  # Builds a request to export the Logic Graph
  class LogicGraphRequestCollection
    include Enumerable

    delegate :each, to: :requests

    def requests
      [{action: 'migrate logic-graph'}]
    end
  end
end
