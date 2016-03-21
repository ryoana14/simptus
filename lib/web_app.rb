# coding: utf-8
require 'sinatra/base'
require 'simptus'

module Simptus
  class WebApp < Sinatra::Base

    configure do
      DB.prepare
    end

    get '/' do
      resources = Resource.order('id desc').take(30).reverse
      servers_list = Execute::Common.read_server_list
      servers = []
      servers_list.each_key do |k|
        servers << k
      end
      cpu_hash = {}
      mem_cap = {}
      time = []
      servers.each do |s|
        total = s + '_total'
        idle  = s + '_idle'
        mem   = s + '_mem'
        cpu_hash[s] =[]
        mem_cap[s] =[]

        resources.each do |r|
          cpu_hash[s] << [r[total], r[idle]]
          mem_cap[s] << r[mem]
          time << r[:time]
        end
      end

      cpu_usage = {}
      cpu_hash.each_key do |k|
        usage = []
        cpu_hash[k].each_cons(2) do |before, after|
          total = after[0] - before[0]
          idle = after[1] - before[1]
          usage << 100 - idle.to_f / total.to_f * 100
        end
        cpu_usage[k] = usage
      end

      @chart_cpu = Chart.create("cpu", cpu_usage, time, 100)
      @chart_mem = Chart.create("mem", mem_cap, time, 10240)
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
