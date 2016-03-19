# coding: utf-8
require 'sinatra/base'

module Simptus
  class WebApp < Sinatra::Base

    get '/' do
      erb :index
    end

  end
end
