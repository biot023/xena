Feature: Running the xena server
  In order to setup, run, and manipulate the server
  As a feature implementor
  I want to be able to set it going, stop it, set data on it, and get data from it

  
  Scenario: Starting and stopping the server
    When I launch the server in a thread on port "9001" into a variable "the_server"
		Then there should be a thread under the variable "the_server"
		And the thread should be alive
		When I ask the server if it is running
		Then I should get a successful response
		When I tell the server to finish
		Then I should get a successful response
		And trying to poll the server further should raise an error
	
	
	Scenario: Recording a few requests
	  Given the server is running on port "9001"
		When I pop all requests
		Then I should receive an empty array
		When I send the following calls:
			| Request Method	| Request URI								| Query String                        |
			| GET     				| /donkey/wonder.json       |                                     |
			| GET     				| /mouse/1/trap.23          | ?dogbreath                          |
			| DELETE  				| /god/forsaken/hell/hole   | ?dogbreath&vomiting=true            |
			| GET	    				| /rampaging/git/horse.html | ?whywhywhy;delilah=hussy&pork=chop	|
		And I pop all requests
		Then I should receive hashes containing the following values in an array:
			| request_method	| request_uri								| query_string											|
			| GET     				| /donkey/wonder.json       |                                   |
			| GET     				| /mouse/1/trap.23          | dogbreath                        	|
			| DELETE  				| /god/forsaken/hell/hole   | dogbreath&vomiting=true          	|
			| GET	    				| /rampaging/git/horse.html | whywhywhy;delilah=hussy&pork=chop	|
		When I pop all requests again
		Then I should receive an empty array