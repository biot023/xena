require "eventmachine"
require "evma_httpserver"

module Xena
  
  class Server < EM::Connection
    
    include EM::HttpServer
    
    def post_init
      super
      no_environment_strings
    end
    
    def process_http_request
      # puts "*** -- " + {
      #   :http_protocol       => @http_protocol,
      #   :http_request_method => @http_request_method,
      #   :http_cookie         => @http_cookie,
      #   :http_if_none_match  => @http_if_none_match,
      #   :http_content_type   => @http_content_type,
      #   :http_path_info      => @http_path_info,
      #   :http_request_uri    => @http_request_uri,
      #   :http_query_string   => @http_query_string,
      #   :http_post_content   => @http_post_content,
      #   :http_headers        => @http_headers
      # }.inspect
      
      response = EM::DelegatedHttpResponse.new( self )
      
      if @http_request_uri == "/__command"
        process_command
        response.status = 200
        return response.send_response
      end
      
      self.class.add_request(
        { :protocol       => @http_protocol,
          :request_method => @http_request_method,
          :cookie         => @http_cookie,
          :if_none_match  => @http_if_none_match,
          :content_type   => @http_content_type,
          :path_info      => @http_path_info,
          :request_uri    => @http_request_uri,
          :query_string   => @http_query_string,
          :post_content   => @http_post_content,
          :headers        => @http_headers
        }
      )
      
      response.status = 200
      response.send_response
    end
    
    #
    # Launch an instance of the server in a thread, and return the thread.
    #
    def self.launch_thread( port )
      @thread = Thread.new do
        EM.run do
          @@signature = EM.start_server( "0.0.0.0", port, self )
        end
      end
      @thread
    end
    
    #
    # Pop all requests that have been made from the stack.
    #
    def self.pop_all_requests
      @@requests ||= []
      return_requests = []
      return_requests, @@requests = @@requests, return_requests
      return_requests
    end
    
    #
    # Add a request to the stack.
    #
    def self.add_request( request_hash )
      @@requests ||= []
      @@requests << request_hash
    end
    
    private
    
    def process_command
      match = @http_query_string.match( /^([^\&\;]+)(.*)?$/ )
      command = match[1]
      if match[2] && match[2] != ""
        options = match[2].split( /\&|\;|\=/ )
          .reject( &:empty? )
          .each_slice( 2 )
          .each_with_object( {} ) { |(k, v), acc| acc[k] = v }
        send( command.to_sym, options: options )
      else
        case command
        when "is_running"
          is_running
        when "stop"
          stop
        else
          raise( "Unhandled command #{ command.inspect }" )
        end
      end
    end
    
    # THE COMMAND METHODS
    #
    
    def stop
      EM::stop_server( @@signature )
    end
    
    def is_running
      true
    end
    
    #
    # description
    #
    def self.__launch
      EM.run do
        EM.start_server( "0.0.0.0", 3000, self )
      end
    end
    
  end
  
end

#
# GET http://localhost:3000/__is_running?monkey=dogbreath
#
# {
#   :http_protocol=>"HTTP/1.1",
#   :http_request_method=>"GET",
#   :http_cookie=>nil,
#   :http_if_none_match=>nil,
#   :http_content_type=>nil,
#   :http_path_info=>"/__is_running",
#   :http_request_uri=>"/__is_running",
#   :http_query_string=>"monkey=dogbreath",
#   :http_post_content=>nil,
#   :http_headers=>"Host:localhost:3000\x00User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_3; en-us) AppleWebKit/533.16 (KHTML, like Gecko) Version/5.0 Safari/533.16\x00Accept: application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5\x00Accept-Language: en-us\x00Accept-Encoding: gzip, deflate\x00Connection: keep-alive\x00\x00"
# }
