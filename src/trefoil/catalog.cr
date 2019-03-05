require "json"

require "./client"
require "./post"
require "./thread"

module Trefoil
  alias Catalog = Array(Thread)
  alias CatalogResponse = Array(NamedTuple(page: Int32, threads: Array(PostInfo)))
end
