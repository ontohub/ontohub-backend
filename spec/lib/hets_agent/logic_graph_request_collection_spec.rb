# frozen_string_literal: true

RSpec.describe HetsAgent::AnalysisRequestCollection do
  subject do
    HetsAgent::LogicGraphRequestCollection.new
  end

  context 'requests' do
    it 'are correct' do
      expect(subject.requests).to match_array([{action: 'migrate logic-graph'}])
    end
  end

  context 'each' do
    it 'is delegated to requests' do
      direct = []
      indirect = []
      subject.each { |request| direct << request }
      subject.requests.each { |request| indirect << request }
      expect(direct).to eq(indirect)
    end
  end
end
