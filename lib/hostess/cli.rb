#!/usr/bin/env ruby

require 'thor'
require 'fog'

module Hostess
  class CLI < Thor

    def initialize(*)
      super

      @connection = Fog::Rackspace

      @load_balancers = Fog::Rackspace::LoadBalancers.new(
        :rackspace_auth_url    => 'auth.api.rackspacecloud.com',
        :rackspace_lb_endpoint => Fog::Rackspace::LoadBalancers::ORD_ENDPOINT
      )
    end

    desc "list", "List all load balancers"
    def list
      @load_balancers.list_load_balancers.body['loadBalancers'].each do |lb|
        puts "#{lb['name']}"
      end
    end

  end

end

