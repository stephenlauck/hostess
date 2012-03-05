#!/usr/bin/env ruby

# assumes rackspace credentials for CRUD load balancers

# hostess --new 'name of load balancer' --port 80 --node-search '^node-regex' --node-port 80
# hostess --list 
# hostest --show 'name of load balancer'
# hostess --delete 'name of load balancer'
# hostess --add-node 'name of load balancer' --node-ip '10.x.x.x' --node-port 80
# hostess --delete-node 'name of load balancer' --node-ip '10.x.x.x'
# hostess --sync-nodes 'name of load balancer' --node-search '^node-regex' --node-port 80

# functions to implement http://rubydoc.info/gems/fog/1.1.2/Fog/Rackspace/LoadBalancers/Real

require 'thor'
require 'fog'
require 'pp'

module Hostess
  class CLI < Thor

    def initialize(*args)
      super

      @load_balancers = Fog::Rackspace::LoadBalancers.new(
        :rackspace_auth_url    => 'auth.api.rackspacecloud.com',
        :rackspace_lb_endpoint => Fog::Rackspace::LoadBalancers::ORD_ENDPOINT
      )

      @nodes = Fog::Compute[:rackspace].servers
    end

    desc "list", "List all load balancers"
    def list
      puts "id \t name"
      puts "-------------------------------"
      @load_balancers.list_load_balancers.body['loadBalancers'].each do |lb|
        puts "#{lb['id']}\t #{lb['name']}"
      end
    end

    desc "show ID", "Show a load balancer by ID"
    def show(load_balancer_id)
      pp @load_balancers.get_load_balancer(load_balancer_id).body['loadBalancer']
    end

    desc "create NAME PROTOCOL PORT NODE_REGEX NODE_PORT", "Create a new load balancer"
    def create(name, protocol, port, node_search, node_port)

      pattern = Regexp.new('^(.+)-\d+$')
      load_balancer = @load_balancers.list_load_balancers.body['loadBalancers'].find_all{|key, val| pattern.match(key['name'])[1] == name}.first

      nodes = search_nodes(node_search).map{|n| { :address => n, :port => Integer(node_port), :condition => 'ENABLED'} }

      # name should be client-appname-environment-port ie target-facebooktabs-dev-80      
      name += "-#{port}"


      if load_balancer
        vip = [ 'id'=> load_balancer['virtualIps'].find { |v| v["ipVersion"] == "IPV4" }["id"] ]
        pp "Sharing VIP with existing load balancer with #{name}, #{protocol}, #{port}, #{vip}, #{nodes}"
      else
        vip = [{ :type => 'PUBLIC'}]
        pp "Creating #{@name}, #{@protocol}, #{@port}, #{ [{ :type => 'PUBLIC' }] }, #{nodes})"
      end

        pp @load_balancers.create_load_balancer(name, protocol, port, vip, nodes)

    end

    desc "delete ID", "Delete a load balancer by ID"
    def delete(load_balancer_id)
      @load_balancers.delete_load_balancer(load_balancer_id)
    end

    desc "list_nodes ID", "List nodes of load balancer by ID"
    def list_nodes(load_balancer_id)
      pp @load_balancers.list_nodes(load_balancer_id)
    end 

    desc "sync_nodes ID NODE_REGEX NODE_PORT", "Sync nodes to load balancer using given regex"
    def sync_nodes(load_balancer_id, node_search, node_port)

      nodes = search_nodes(node_search).map{|n| { :address => n, :port => Integer(node_port), :condition => 'ENABLED'} }

      pp @load_balancers.update_load_balancer(load_balancer_id, { :nodes => nodes })
    end 

    desc "delete_node ID NODE_ID", "Delete node from load balancer by ID and NODE_ID"
    def delete_node(load_balancer_id, node_id)
      pp @load_balancers.delete_node(load_balancer_id, node_id)
    end 

    desc "search-nodes NODE_REGEX", "Search for nodes"
    def search_nodes(regex)
      search = Regexp.new(regex)
      pp "searching for nodes containing #{search}..."
      result_nodes = @nodes.find_all{|server| search =~ server.name}
      result_nodes.collect{|n| n.addresses['private'].first}
    end

    desc "nodes", "Show all available server nodes"
    def nodes
      @nodes.table
    end
  end
end

