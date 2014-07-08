#!/usr/bin/env ruby

require 'thread'
require 'thor'
require 'getlocal'

Thread.abort_on_exception = true

module Getlocal
  class CLI < Thor
    class_option :verbose, :type => :boolean, :aliases => "-v"

    method_option :user, :required => true, :aliases => "-u"
    method_option :password, :required => true, :aliases => "-p"
    desc "fetch [PROJECT]", "Used to fetch the latest localisations"
    def fetch(project)
      username = options[:user]
      password = options[:password]
      
      if !options[:verbose] then
        Thread.new do
          #set up spinner
          glyphs = ['|', '/', '-', "\\"]
          while true
            glyphs.each do |g|
              print "\r#{g}"
              sleep 0.15
            end
          end
        end
      end
      
      auth = {:username => username, :password => password}
      
    end
    
    method_option :user, :required => true, :aliases => "-u"
    method_option :password, :required => true, :aliases => "-p"
    desc "update [PROJECT]", "Used to send the latest localisations to get localization"
    def update(project)
      username = options[:user]
      password = options[:password]
      
      if !options[:verbose] then
        Thread.new do
          #set up spinner
          glyphs = ['|', '/', '-', "\\"]
          while true
            glyphs.each do |g|
              print "\r#{g}"
              sleep 0.15
            end
          end
        end
      end
      
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
          responceCodes << response.code
        else
          #Upload new master
          response = HTTMultiParty.post("https://api.getlocalization.com/#{project}/api/create-master/ios/en/", :basic_auth => auth, :query => body)
          responceCodes << response.code
        end
        
      end
      
        if responceCodes.include?(400)
          puts "The request was malformed please try again"
        elsif responceCodes.include?(404)
          puts "The username or password are invailed"
        end
      
    
    end
  end
end