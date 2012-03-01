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


# >> @name = 'akqa-kitchen-prod-lb-80'
# "akqa-kitchen-prod-lb-80"
# >> @protocol = 'HTTP'
# "HTTP"
# >> @port = 80
# 80
#     >> @load_balancers.create_load_balancer(@name, @protocol, @port, [{ :type => 'PUBLIC'}], [{ :address => '10.183.4.20', :port => 80, :condition => 'ENABLED'}])

    # create_load_balancer(name, protocol, port, virtual_ips, nodes)
    desc "create", "Create a new load balancer"
    def create(name, protocol, port, node_search, node_port)
      # name should be client-appname-environment-port ie target-facebooktabs-dev-80
      # lb = @load_balancers.list_load_balancers.body['loadBalancers'].find{|key, val| key['name'] == name}
      pattern = Regexp.new("^(.+-)\d+$")
      lb = @load_balancers.list_load_balancers.body['loadBalancers'].find{|key, val| pattern.match(key['name']) == name}
      
      # [{ :address => '10.0.0.1', :port => 80, :condition => 'ENABLED'}]
      nodes = search_nodes(node_search).map{|n| { :address => n, :port => Integer(node_port), :condition => 'ENABLED'} }
      
      name += "-#{port}"

      # @name = 'akqa-kitchen-prod-lb-80'
      # @protocol = 'HTTP'
      # @port = 80
      
      @name = name
      @protocol = protocol
      @port = port
      # @nodes = [{ :address => '10.183.4.20', :port => 80, :condition => 'Enabled'}] #, {:address=>"10.183.4.25", :port=>80, :condition=>"Enabled"}]
        @nodes = [{ :address => '10.183.4.20', :port => 80, :condition => 'ENABLED'}]

      if lb
        # @load_balancers.create_load_balancer(name, protocol, port, virtual_ips, nodes)
        puts "Existing load balancer with #{name}, #{protocol}, #{port}, #{lb['virtualIps']}, #{nodes}"
        pp @load_balancers.create_load_balancer(name, protocol, port, lb['virtual_ips'], nodes)
      else
        puts "@load_balancers.create_load_balancer(#{@name}, #{@protocol}, #{@port}, #{ [{ :type => 'PUBLIC' }] }, #{nodes})"
        begin
          pp nodes
          @load_balancers.create_load_balancer(@name, @protocol, @port, [{ :type => 'PUBLIC'}], nodes) #[{ :address => '10.183.4.20', :port => 80, :condition => 'ENABLED'}])
          # @load_balancers.create_load_balancer(@name, @protocol, port, [{ :type => 'PUBLIC' }], [{:address=>"10.183.4.20", :port=> 80, :condition=>"Enabled"}])
        rescue
          puts $!.response_data
        end
      end

      
    end

    desc "search-load-balancers", "Search for load balancer"
    def search_load_balancer(name)
      search = Regexp.new(name)
    end

    desc "search-nodes", "Search for nodes"
    def search_nodes(regex)
      # node = Compute[:rackspace].servers.find_all{|s| s.name == 'target-tgtapps-staging-app-01'}.first
      # search = Regexp.new(regex.gsub('*', '.*'))
      search = Regexp.new(regex)
      pp "searching for nodes containing #{search}..."
      result_nodes = @nodes.find_all{|server| search =~ server.name}
      result_nodes.collect{|n| n.addresses['private'].first}
    end
  end
end

