#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'
require 'httmultiparty'

module Getlocal
  class REST
    def self.pull(project, username, password)
      

      
    end
    
    def self.push(project, username, password)  
             
      auth = {:username => username, :password => password}
      
      response = HTTParty.get("https://api.getlocalization.com/#{project}/api/list-master/json/", :basic_auth => auth)
      if response.code == 200 then
        parsedResponse = JSON.parse(response.body)
        if parsedResponse['success'] == "1"
          currentMasterFiles = parsedResponse['master_files']
        end
      end
      
      Dir.glob("Base.lproj/*.strings") do |stringFilePath|
        
        alreadyExists = currentMasterFiles.include?(stringFilePath.gsub("Base.lproj/", ""))
          
        body = {"file" => File.new(stringFilePath)}
        
        if alreadyExists
          # Update master
          response = HTTMultiParty.post("https://api.getlocalization.com/#{project}/api/update-master/", :basic_auth => auth, :query => body)
        else
          #Upload new master
          response = HTTMultiParty.post("https://api.getlocalization.com/#{project}/api/create-master/ios/en/", :basic_auth => auth, :query => body)
        end
        
      end
      
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