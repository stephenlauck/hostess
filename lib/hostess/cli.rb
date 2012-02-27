#!/usr/bin/env ruby

# assumes rackspace credentials for CRUD load balancers

# hostess --new 'name of load balancer' --port 80 --node-search '^node-regex' --node-port 80
# hostess --list 
# hostest --show 'name of load balancer'
# hostess --delete 'name of load balancer'
# hostess --add-node 'name of load balancer' --node-ip '10.x.x.x' --node-port 80
# hostess --delete-node 'name of load balancer' --node-ip '10.x.x.x'
# hostess --sync-nodes 'name of load balancer' --node-search '^node-regex' --node-port 80

# Hostess::CLI.run(ARGV)


require 'thor'
require 'fog'
require 'pp'

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
      puts "id \t name"
      puts "-------------------------------"
      @load_balancers.list_load_balancers.body['loadBalancers'].each do |lb|
        puts "#{lb['id']}\t #{lb['name']}"
      end
    end

    desc "show", "Show a load balancer by ID"
    def show(load_balancer_id)
      pp @load_balancers.get_load_balancer(load_balancer_id)
    end


  end
end

