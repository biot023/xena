After do
  @thread.kill if @thread && @thread.alive?
end

def send
  uri = URI.parse( "http://localhost:#{ @port }" )
  Net::HTTP.start( uri.host, uri.port ) do |http|
    yield( http )
  end
end

When /^I launch the server in a thread on port "([^"]*)" into a variable "([^"]*)"$/ do |port, varname|
  Thread.abort_on_exception = true
  @port = port.to_i
  instance_eval( "@#{ varname } = Xena::Server.launch_thread( #{ port } )" )
  @thread = instance_eval( "@#{ varname }")
  # sleep( 1 )
end

Then /^there should be a thread under the variable "([^"]*)"$/ do |varname|
  @thread.should be_kind_of( Thread )
end

Then /^the thread should be alive$/ do
  @thread.should be_alive
end

When /^I ask the server if it is running( again)?$/ do |_|
  @response = send { |http| http.get( "/__command?is_running" ) }
end

Then /^I should get a successful response$/ do
  @response.should be_kind_of( Net::HTTPOK )
end

Then /^I should get an error response$/ do
  @response.should be_kind_of( Net::HTTPInternalServerError )
end

When /^I tell the server to finish( again)?$/ do |_|
  @response = send { |http| http.get( "/__command?stop" ) }
end

Then /^trying to poll the server further should raise an error$/ do
  lambda { send { |http| http.get( "/__command?stop" ) } }
    .should raise_error
end

Given /^the server is running on port "([^"]*)"$/ do |port|
  @port = port.to_i
  @thread = Xena::Server.launch_thread( @port )
end

When /^I pop all requests(?: again)?$/ do
  @requests = Xena::Server.pop_all_requests
end

Then /^I should receive an empty array$/ do
  @requests.should == []
end

When /^I send the following calls:$/ do |table|
  table.rows.each do |(method, request_uri, query_string)|
    _method = method.downcase.to_sym
    uri = "#{ request_uri }#{ query_string }"
    send { |http| http.method( _method ).call( uri ) }
  end
end

Then /^I should receive hashes containing the following values in an array:$/ do |table|
  [ @requests, table.rows ].transpose.each do |(request, (request_method, request_uri, query_string))|
    _query_string = query_string == "" ? nil : query_string
    request[:request_method].should == request_method
    request[:request_uri].should    == request_uri
    request[:query_string].should   == _query_string
  end
end
