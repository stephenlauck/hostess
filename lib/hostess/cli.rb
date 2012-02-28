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

    def initialize(*args)
      super

      @nodes = Fog::Compute[:rackspace].servers

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
      pp @load_balancers.get_load_balancer(load_balancer_id).body['loadBalancer']
    end

    # create_load_balancer(name, protocol, port, virtual_ips, nodes)
    desc "create", "Create a new load balancer"
    def create(name, protocol, port, node_search)
      lb = @load_balancers.list_load_balancers.body['loadBalancers'].find{|key, val| key['name'] == name}
      if lb
        puts "Existing load balancer with #{name}, #{protocol}, #{port}, #{node_search} has vip of #{lb['virtualIps']}"
      else
        puts "Creating load balancer with #{name}, #{protocol}, #{port}, #{node_search}"
      end

      
    end


    desc "search-nodes", "Search for nodes"
    def search_nodes(regex)
      # node = Compute[:rackspace].servers.find_all{|s| s.name == 'target-tgtapps-staging-app-01'}.first
      pp @nodes.find_all{|server| server =~ regex}
    end
  end
end

