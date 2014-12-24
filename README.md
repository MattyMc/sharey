# Sharey

A little passion project. Please go away :)


## Setup steps 

###Get ngrok up and running for port fowarding:

1. Navigate to the 'ngrok' directory
2. ```$ ./ngrok -subdomain=sharey 3000```

###This application uses Figaro for privacy

- Private information shoule be stored in config/application.yml

###To launch a local server

- Use ```$ thin start --ssl``` although I find the deafult rails server works fine.
- Note: config.force_ssl = true in production.rb and development.rb

###Notes on sessions and user persistance

- A sessions['current\_user\_id'] attribute is used to keep track of users sessions. 

	- A few helper methods in the ApplicationController use this to fetch/verify users.
	- This attribute should be destroyed upon leaving the page. It should not persist very long. 
- A cookies[:sharey\_session\_cookie] is used to authorize sharing of items in a more long term way

	- This should get recreated/stored upon each user login
	- This should *not* get destroyed when a user logs out, as we don't want to force users to login on each new share

###Deploying

- I've used a shortcut of adding secrets.yml to git, pushing to Heroku, then removing secrets.yml from version control. 
- Other wise, deply as normal to Heroku

