# frozen_string_literal: true

module BunnyMock
  class Exchange
    # Monkeypatch, XRecentHistory be found by the ex declare "x-recent-history"
    def self.declare(channel, name = '', **opts)
      # get requested type
      type = opts.fetch :type, :direct
      # get needed class type
      klazz = BunnyMock::Exchanges.const_get(type.to_s.split('-').
        map(&:capitalize).join)
      # create exchange of desired type
      klazz.new channel, name, type, opts
    end
  end

  module Exchanges
    class XRecentHistory < BunnyMock::Exchanges::Fanout
    end
  end
end
