# coding: utf-8
require 'sinatra/base'

module Simptus
  class WebApp < Sinatra::Base

    get '/' do
      erb :index
    end

    def self.new(*)
      auth = File.open("#{ENV['HOME']}/.simptus/simptus_auth", 'r').readline
      auth = auth.split(':')
      user = auth[0]
      pass = auth[1].chomp
      app = Rack::Auth::Digest::MD5.new(super) do |username|
        { user => pass }[username]
      end
      app.realm = 'test digest'
      app.opaque = 'secretkey'
      app
    end

  end
end
