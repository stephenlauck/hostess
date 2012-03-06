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
      @lb = Hostess::LoadBalancer.new()
    end

    desc "list", "List all load balancers"
    def list
      @lb.list
    end

    desc "show ID", "Show a load balancer by ID"
    def show(load_balancer_id)
      @lb.show(load_balancer_id)
    end

    desc "create NAME PROTOCOL PORT NODE_REGEX NODE_PORT", "Create a new load balancer"
    def create(name, protocol, port, node_search, node_port)
      @lb.create(name, protocol, port, node_search, node_port)
    end

    desc "delete ID", "Delete a load balancer by ID"
    def delete(load_balancer_id)
      @lb.delete(load_balancer_id)
    end

    desc "list_nodes ID", "List nodes of load balancer by ID"
    def list_nodes(load_balancer_id)
      @lb.list_nodes(load_balancer_id)
    end 

    # desc "sync_nodes ID NODE_REGEX NODE_PORT", "Sync nodes to load balancer using given regex"
    # def sync_nodes(load_balancer_id, node_search, node_port)
    #   @lb.sync_nodes(load_balancer_id, node_search, node_port)
    # end 

    # desc "delete_node ID NODE_ID", "Delete node from load balancer by ID and NODE_ID"
    # def delete_node(load_balancer_id, node_id)
    #   pp @load_balancers.delete_node(load_balancer_id, node_id)
    # end 

    desc "nodes", "Show all available server nodes"
    def nodes
      @lb.nodes
    end
  end
end

