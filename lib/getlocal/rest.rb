#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'

module Getlocal
  class REST
    def self.pull(project, username, password)  
      # Set up a base for the requests
      http = Net::HTTP.new("https://api.getlocalization.com/#{project-name}/api")
    
      # Get the list of translations
      request = Net::HTTP::Get.new("/list-master/json")
      request.basic_auth(username, password)
      response = http.request(request)
    
      translationList = JSON.parse(response.body)
      
      for name, name in translationList
        #code
      end
      
    
      request = Net::HTTP::Post.new("/users")
      request.set_form_data({"users[login]" => "quentin"})
      response = http.request(request)
      
    end
    
    def self.checkForInfo(project, username, password)
      # Check for username and password
      if !project then
        puts "Please specify a project"
      end
      if !username then
        puts "Please specify a username"
      end
      if !password then
        puts "Please specify a password"
      end
      return project && username && password
    end
    
  end
end