#!/usr/bin/env ruby

require 'zip'
require 'thread'
require 'io/console'

require 'thor'
require 'httmultiparty'
require 'powerbar'

require 'getlocal'

Thread.abort_on_exception = true

module Getlocal
  class CLI < Thor
    class_option :verbose, :type => :boolean, :aliases => "-v"

    method_option :user, :required => true, :aliases => "-u"
    method_option :password, :aliases => "-p"
    method_option :timeout, :type => :numeric, :default => 600, :aliases => "-t"
    method_option :sleep, :type => :numeric, :default => 0, :aliases => "-s"
    desc "fetch [PROJECT]", "Used to fetch the latest localisations"
    def fetch(project)

      # Check if we are in the right place
      if Dir.glob('*.lproj').empty?
        puts "Wrong directory please select the directory that contains the .lproj folders"
        return
      end

      username = options[:user]

      # Check if we need to ask for a password
      if options[:password]
        password = options[:password]
      else
        print "Password:"
        password = STDIN.noecho(&:gets).chomp
        puts ""
      end

      p = PowerBar.new

      auth = {:username => username, :password => password}
      
      sleepTime = options[:sleep]

      # Find all the languages we support
      supportedLanguages = []
      Dir.glob("*.lproj") do |filePath|
        f = File.basename(filePath, ".*")
        supportedLanguages << f unless f == "Base"
      end

      puts "Fetching localisations for" if options[:verbose]
      puts "" if options[:verbose]

      total = Dir.glob("Base.lproj/*.strings").count * supportedLanguages.count
      current = 0

      # Loop through the string files we have localy
      Dir.glob("Base.lproj/*.strings") do |stringFilePath|

        fileName = File.basename(stringFilePath)
        puts "-- #{fileName} --" if options[:verbose]
        puts "" if options[:verbose]

        # Request the translations for each supported language
        supportedLanguages.each do |lang|

          current = current.next
          p.show(:msg => 'Fetching Translation', :done => current, :total => total) unless options[:verbose]

          tempfile = Tempfile.new("file")

          puts "Fetching #{lang} for #{fileName}." if options[:verbose]
          begin
            response = HTTParty.get("https://api.getlocalization.com/#{project}/api/translations/file/#{fileName}/#{lang}/", :basic_auth => auth, :timeout => options[:timeout])
          rescue
            puts "Oh no, somthing fucked up."
            return
          else
            if response.code == 200
              puts "File downloaded" if options[:verbose]
              tempfile.binmode # This might not be necessary depending on the zip file
              tempfile.write(response.body)


              destFolder = lang + ".lproj"
              destFile = fileName

              destPath = destFolder + '/' + destFile

              puts "moveing translations to #{destPath}" if options[:verbose]

              if Dir.exists?(destFolder)
                File.delete(destPath) if File.exist?(destPath)
                FileUtils.mv(tempfile.path, destPath)
              else
                puts destFolder + " folder not found. Couldn't import " + destFile if options[:verbose]
              end
            elsif response.code == 401
              puts "The username or password are invailed"
              return
            else
              puts "Bad response. Close but no cigar. Response Code = #{response.code}"
              puts "Sorry couldn't get #{lang} translations this time."
            end
          ensure
            tempfile.close
          #Sleep so we don't hit the rate limiting on GetLocalization's API
          sleep(sleepTime)
          end
          puts "" if options[:verbose]
        end
        puts "" if options[:verbose]
        puts "" if options[:verbose]
      end
    end

    method_option :user, :required => true, :aliases => "-u"
    method_option :password, :aliases => "-p"
    desc "update [PROJECT]", "Used to send the latest localisations to get localization"
    def update(project)
      username = options[:user]

      # Check if we need to ask for a password
      if options[:password]
        password = options[:password]
      else
        print "Password:"
        password = STDIN.noecho(&:gets).chomp
        puts ""
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

      puts "Requesting the list of master files" if options[:verbose]
      response = HTTParty.get("https://api.getlocalization.com/#{project}/api/list-master/json/", :basic_auth => auth)

      if response.code == 200 then
        parsedResponse = JSON.parse(response.body)
        if parsedResponse['success'] == "1"
          puts "Recived list" if options[:verbose]
          currentMasterFiles = parsedResponse['master_files']
        else
          puts "couldn't fetch list of master files"
          return
        end
      else
        puts "couldn't fetch list of master files"
        return
      end

      Dir.glob("Base.lproj/*.strings") do |stringFilePath|

        alreadyExists = currentMasterFiles.include?(stringFilePath.gsub("Base.lproj/", ""))

        body = {"file" => File.new(stringFilePath)}

        if alreadyExists
          # Update master
          puts "Updateing " + stringFilePath if options[:verbose]
          response = HTTMultiParty.post("https://api.getlocalization.com/#{project}/api/update-master/", :basic_auth => auth, :query => body)
        else
          #Upload new master
          puts "Creating " + stringFilePath if options[:verbose]
          response = HTTMultiParty.post("https://api.getlocalization.com/#{project}/api/create-master/ios/en/", :basic_auth => auth, :query => body)
        end

        puts "Upload complete with responce code #{response.code}" if options[:verbose]
        puts "" if options[:verbose]
      end

    end
  end
end
