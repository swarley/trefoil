require "http/client"

module Trefoil
  # Used for making API requests. Instances are rate limited to one request per second as per the
  # [API documentation](https://github.com/4chan/4chan-API).
  class Client
    # Base url for all API requests.
    BASE_URL = "https://a.4cdn.org/"

    def initialize
      @last_request = Time.now - 1.second
      @mutex = Mutex.new
    end

    # Get the body of a request from a given endpoint. If we're rate limited
    # the request is queued.
    def get(endpoint : String, if_modified_since : Time = Time::UNIX_EPOCH) : String
      @mutex.synchronize do
        sleep retry_after
        request(endpoint, if_modified_since).body
      end
    end

    # Like `get` but if we're rate limited it returns `nil`
    # instead of blocking.
    def get?(endpoint : String, if_modified_since : Time = Time::UNIX_EPOCH) : String | Nil
      return nil if rate_limited?

      @mutex.synchronize do
        request(endpoint, if_modified_since).body
      end
    end

    # Whether or not we are able to make another request
    def rate_limited? : Bool
      Time.now < @last_request + 1.second
    end

    # The time span we have to wait before another request can be made
    def retry_after : Time::Span
      (@last_request + 1.second) - Time.now
    end

    def request(endpoint : String, if_modified_since : Time = Time::UNIX_EPOCH)
      time_format = "%a, %d %b %Y %X GMT"
      time_str = if_modified_since.to_s(time_format)
      resp = HTTP::Client.get(BASE_URL + endpoint.lstrip('/'), headers: HTTP::Headers{"If-Modified-Since" => time_str})
      @last_request = Time.now
      return resp
    end
  end
end
