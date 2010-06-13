require File.join( File.dirname( __FILE__ ), "..", "..", "spec_helper" )

describe Xena::Server do
  
  describe 'class structure' do
    subject { Xena::Server }
    it { should inherit_from( EM::Connection ) }
    it { should include_module( EM::HttpServer ) }
  end
  
  describe '.launch_thread( port )' do
    
    before( :each ) do
      @port = 4321
      @thread = mock( :thread )
      EM.stub!( :start_server )
      EM.stub!( :run ).and_yield
      Thread.stub!( :new ).and_yield
    end
    
    def do_call
      Xena::Server.launch_thread( @port )
    end
    
    it "should initialise the server" do
      EM.should_receive( :start_server ).with( "0.0.0.0", @port, Xena::Server )
      do_call
    end
    
    it "should run the initialised server" do
      EM.should_receive( :run ).and_yield
      do_call
    end
    
    it "should run the server in a thread" do
      Thread.should_receive( :new ).and_yield
      do_call
    end
    
    it "should return the thread that the server was run into" do
      Thread.stub!( :new ).and_return( @thread )
      do_call.should == @thread
    end
    
  end
  
  it "should be able to store and pop requests at the class level" do
    Xena::Server.pop_all_requests.should == []
    Xena::Server.add_request( { a: "request" } )
    Xena::Server.add_request( { another: "request" } )
    Xena::Server.pop_all_requests.should == [ { a: "request" }, { another: "request" } ]
    Xena::Server.pop_all_requests.should == []
  end
  
  describe 'receiving a command request' do
    
    before( :each ) do
      @xena_server = Xena::Server.new( nil )
      @xena_server.instance_variable_set( :@http_request_uri, "/__command" )
      @response_object = mock( :response_object, send_response: "Munchausen!" )
      @response_object.stub!( :status= )
      EM::DelegatedHttpResponse.stub!( :new ).and_return( @response_object )
      @xena_server.stub!( :is_running )
    end
    
    def do_call( query_string="is_running" )
      @xena_server.instance_variable_set( :@http_query_string, query_string )
      @xena_server.process_http_request
    end
    
    it "should generate a response object" do
      EM::DelegatedHttpResponse.should_receive( :new ).with( @xena_server ).and_return( @response_object )
      do_call
    end
    
    it "should call the command method with response object and without params if there is only the command in the query string" do
      %w( stop is_running ).each do |command|
        @xena_server.should_receive( command.to_sym )
        do_call( command )
      end
    end
    
    it "should call the command method with response object and params if there are params in the query string" do
      [
        [ "set_response", { "request_uri" => "/products", "file" => "path/to/file.txt" }, "set_response&request_uri=/products&file=path/to/file.txt" ],
        [ "set_responses", { "request_uri" => "/gits.json", "directory" => "path/to/dir" }, "set_responses&request_uri=/gits.json&directory=path/to/dir" ]
      ].each do |(command, options, query_string)|
        @xena_server.should_receive( command.to_sym ).with( options: options )
        do_call( query_string )
      end
    end
    
    it "should set the response object's status to 200" do
      @response_object.should_receive( :status= ).with( 200 )
      do_call
    end
    
    it "should call send_response on the response_object and return it" do
      do_call.should == @response_object.send_response
    end
    
  end
  
  describe 'receiving miscellaneous requests' do
    
    before( :each ) do
      @xena_server = Xena::Server.new( nil )
      @ivar_hashes = {
        :protocol       => "@http_protocol",
        :request_method => "@http_request_method",
        :cookie         => "@http_cookie",
        :if_none_match  => "@http_if_none_match",
        :content_type   => "@http_content_type",
        :path_info      => "@http_path_info",
        :request_uri    => "@http_request_uri",
        :query_string   => "@http_query_string",
        :post_content   => "@http_post_content",
        :headers        => "@http_headers"
      }
      @ivar_hashes.values.flatten.each do |ivar|
        @xena_server.instance_variable_set( ivar, ivar )
      end
      @response = mock( :response, send_response: "Okey-dokey" )
      EM::DelegatedHttpResponse.stub!( :new ).and_return( @response )
      @response.stub!( :status= )
    end
    
    def do_call
      @xena_server.process_http_request
    end
    
    it "should create a response object" do
      EM::DelegatedHttpResponse.should_receive( :new ).and_return( @response )
      do_call
    end
    
    context "without pre-recorded responses" do
      
      it "should add all of the request details to the requests stack" do
        Xena::Server.should_receive( :add_request ).with( @ivar_hashes )
        do_call
      end
      
      it "should set the response object to status 200" do
        @response.should_receive( :status= ).with( 200 )
        do_call
      end
      
      it "should call send_response on the response object and return it" do
        do_call.should == @response.send_response
      end
      
    end
    
    context "with pre-recorded responses" do
      it "should be specced"
    end
    
  end
  
  describe 'the command methods' do
    
    before( :each ) do
      @xena_server = Xena::Server.new( nil )
    end
    
    describe '#stop' do
      
      it "should call EM.stop_server" do
        EM.should_receive( :stop_server )
        @xena_server.send( :stop )
      end
      
    end
    
    describe '#is_running' do
      
      it "should just return true" do
        @xena_server.send( :is_running ).should be_true
      end
      
    end
    
  end
  
end
