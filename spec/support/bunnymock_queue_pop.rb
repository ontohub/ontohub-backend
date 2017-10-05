# frozen_string_literal: true

# See https://github.com/arempe93/bunny-mock/blob/daa3211090eef48327fcd26840f0b09f5ca3b3bf/UPGRADING.md#upgrading-to--140
#
# The implmentation of BunnyMock::Queue#pop has changed to support the same
# return value as Bunny. The old functionality is still enabled by default. To
# use the new functionality that matches Bunny:

BunnyMock.use_bunny_queue_pop_api = true
