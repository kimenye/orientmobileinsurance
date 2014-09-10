# Copyright (c) 2008-2014 by Afilias Technologies Limited (dotMobi). All rights reserved.
# Author: dotMobi

require File.join(File.dirname(__FILE__), 'client')

# Copyright:: 
# * Copyright (c) 2008-2014 by Afilias Technologies Limited (dotMobi). All rights reserved.
# Author::
# * dotMobi
#
# Welcome to DeviceAtlas Cloud Client API!
# 
# DeviceAtlas Cloud is a web service that can return device information such as 
# screen width, screen height, is mobile, vendor, model etc. To see a full list
# of properties, please visit
# https://deviceatlas.com/resources/available-properties .
# 
# This Client API provides an easy way to query DeviceAtlas Cloud. It provides 
# the ability to cache returned data locally to greatly improve performance and 
# has automatic failover should one of the global DeviceAtlas Cloud endpoints 
# become unavailable. As of version 1.2, the Client API is able to leverage data 
# collected by the DeviceAtlas Client Side Component. This data is sent to 
# DeviceAtlas Cloud to augment the data found from the normal HTTP headers and 
# also allows the detection of the various iPhone and iPad models. 
# 
# The API is very easy to use:
#
# (1) Install the Ruby Client API gem:
#
#		gem install deviceatlas_cloud_ruby-X.X.gem
#
# Add the installed "deviceatlas_cloud_client" gem to the Gemfile of your 
# Rails project if needed.
#
# (2) Include the Client API gem and the controller helper at your Rails 
# controller:
#
#		# Client API gem
#		require 'deviceatlas_cloud_ruby'
#
#		class ExampleController < ActionController::Base
#
#			# Controller helper
#			include DeviceAtlasCloudClient::ControllerHelper
#
#			def index
#
#				# Code with the following steps
#
#			end
#		end
#
# (3) Get the client instance (singleton) and set your licence key:
#
#		client = get_deviceatlas_cloud_client_instance
#		client.settings.licence_key = 'YOUR_LICENCE_KEY'
#
# (4) Get device data (properties)
#
#		# Use browser user-agent
#		device_data = client.get_device_data
#		
#		# Use built-in test user-agent
#		device_data = client.get_device_data true
#
# (5) Use device data (properties):
#
# See the list of property names that can be available as hash-keys inside
# device_data[:properties] here: 
# https://deviceatlas.com/resources/available-properties
# The availability of a property depends on the device and your licence,
# before accessing a property always use has_key() to see if it exists.
#
# The included "example_app" uses the Client API to query DeviceAtlas Cloud and 
# displays a webpage with all the returned properties. 
#
# The Client API uses the device User-Agent to determine what device it is. If 
# you are testing using a desktop web browser it is recommended to use a 
# user-agent switcher plugin to modify the browser's user-agent.
#
# Alternatively, simply passing "true" to get_device_data() will make the Client
# API use a built in test User-Agent.
#
# To get the best results include the DeviceAtlas Client Side Component into 
# your page, that is all you need to do (more details in README file).
#
# The returned data will be as:
#		device_data[DeviceAtlasCloudClient::KEY_PROPERTIES] # Hash of device properties
#		device_data[DeviceAtlasCloudClient::KEY_ERROR] # Errors happened while fetching data
#		device_data[DeviceAtlasCloudClient::KEY_USERAGENT] # User-Agent to query data
#		device_data[DeviceAtlasCloudClient::KEY_SOURCE] # It shows where the data came from and is one of:
#		# DeviceAtlasCloudClient::SOURCE_CACHE
#		# DeviceAtlasCloudClient::SOURCE_CLOUD
#		# DeviceAtlasCloudClient::SOURCE_NONE
#
# Notes
# 
# 1. When in test mode and using cookie cache, changing the user-agent will not 
# update the cookie cache and you have to manually remove the cookie.
# Because in real life the the cookie is on the system it represents.
# 
# 2. It is recommended to always use file cache.
# Using cookie cache will cache device info on the user's browser.
# You can have both caches on, then if device data is found in the cookie
# it will be used otherwise if data is cached in the files the file cache will 
# be used.
module DeviceAtlasCloudClient

	API_VERSION = Client::API_VERSION
	KEY_USERAGENT = Client::KEY_USERAGENT
	KEY_SOURCE = Client::KEY_SOURCE
	KEY_ERROR = Client::KEY_ERROR
	KEY_PROPERTIES = Client::KEY_PROPERTIES

	##
	# Return a DeviceAtlas client instance based on the singleton pattern.
	# 
	# The client contains all public methods:
	#  
	# get_device_data
	# Get the user device data.
	#  
	# get_servers_latencies
	# Check cloud servers and return a list sorted by latency.
	#  
	# get_cloud_url
	# Get the primary server url.
	#  
	# servers
	# Get the current ranked server list.
	# 
	# +headers+:: Hash of headers from the request.
  # +cookies+:: Hash of cookies from the request.
  # 
	# +return+:: Client object.
	#
	def self.get_instance(headers = nil, cookies = nil)

		# If the singleton instance does not exist, then it is created
		if @client.nil?
			@client = Client.new(headers, cookies)
			
		# If it already exists, just update the request details
		else
			@client.headers = headers
      @client.cookies = cookies

		end

		@client
	end

end

##
# Controller helper to use the API from Ruby on Rails.
# Once it is included in the Rails controller, it transparently stores request 
# headers and create the DeviceAtlas cloud client instance.
#
module DeviceAtlasCloudClient::ControllerHelper

	##
	# Method to get a Client object from a Rails controller.
	#
	# +return+:: Client object.
	#
	def get_deviceatlas_cloud_client_instance
		DeviceAtlasCloudClient::get_instance request.env, request.cookies
	end

end
