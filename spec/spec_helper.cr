require "spec"
require "../src/trefoil"
require "webmock"

macro load_json(fname)
  File.read(__DIR__ + "/data/" + {{fname}})
end
