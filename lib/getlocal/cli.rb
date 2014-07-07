#!/usr/bin/env ruby
require 'thor'
require 'Getlocal'

module Getlocal
  class CLI < Thor

    option :user, :required => true, :aliases => "-u"
    option :password, :aliases => "-p"
  
    def fetch(project)
      username = options[:user]
      password = options[:password]

      puts GetLocal::REST.pull(project, username, password) if GetLocal::REST.checkForInfo(project, username, password)
    end

  end
end