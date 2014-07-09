#!/usr/bin/env ruby

require 'zip'
require 'thread'

require 'thor'
require 'httmultiparty'
require 'highline'

require 'getlocal'

Thread.abort_on_exception = true

module Getlocal
  class CLI < Thor
    class_option :verbose, :type => :boolean, :aliases => "-v"

    method_option :user, :required => true, :aliases => "-u"
    method_option :password, :aliases => "-p"
    desc "fetch [PROJECT]", "Used to fetch the latest localisations"
    def fetch(project)
      
      puts "Wrong directory please select the directory that contains the .lproj folders" if Dir.glob('*.lproj').empty?
      
      username = options[:user]
      
      if options[:password]
        password = options[:password]
      else
        password = ask("Password: ") { |q| q.echo = "*" }
      end
      
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
      
      puts "Fetching the zip"
      
      zipfile = Tempfile.new("file")
        
      begin
        response = HTTParty.get("https://api.getlocalization.com/#{project}/api/translations/zip/", :basic_auth => auth, :timeout => 600)
      rescue
        puts "Oh no, somthing fucked up."
      else 
        puts "Creating the zip"
        zipfile.binmode # This might not be necessary depending on the zip file
        zipfile.write(response.body)
      ensure
        zipfile.close
      end
      
      puts "Extracting the zip"
      Zip::File.open(zipfile.path) do |zip_file|
        # Handle entries one by one
        zip_file.each do |entry|
          # Extract to correct location
          puts "Extracting #{entry.name}"
          
          #entry.extract(dest_file)
        end
      end
      
    end
    
    method_option :user, :required => true, :aliases => "-u"
    method_option :password, :aliases => "-p"
    desc "update [PROJECT]", "Used to send the latest localisations to get localization"
    def update(project)
      username = options[:user]
      
      if options[:password]
        password = options[:password]
      else
        password = ask("Password: ") { |q| q.echo = "*" }
      end
      
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
      
      responceCodes = []
        
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
        else
          puts ""
        end
        
    end
  end
end