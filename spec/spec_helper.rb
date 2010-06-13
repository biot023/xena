require File.join( File.dirname( __FILE__ ), "..", "lib", "xena", "server" )

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[ "#{File.dirname(__FILE__)}/support/**/*.rb" ].each { |f| require f }

Rspec.configure do |config|
  
  config.mock_with :rspec
  
  config.include GeneralHelpers
  
end
