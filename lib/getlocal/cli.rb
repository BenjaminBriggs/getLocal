#!/usr/bin/env ruby
require 'thor'
require 'getlocal'

module Getlocal
  class CLI < Thor

    option :user, :required => true, :aliases => "-u"
    option :password, :aliases => "-p"
    
    desc "fetch <Project>", "Used to fetch the latest localisations"
    def fetch(project)
      username = options[:user]
      password = options[:password]

      puts Getlocal::REST.pull(project, username, password)
    end

  end
end