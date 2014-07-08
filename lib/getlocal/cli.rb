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
        
        Getlocal::REST.pull(project, username, password)
      else
        puts Getlocal::REST.pull(project, username, password)
      end
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
        
        Getlocal::REST.push(project, username, password)
      else
        puts Getlocal::REST.push(project, username, password)
      end
    end

  end
end