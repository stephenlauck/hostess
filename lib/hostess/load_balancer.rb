require 'fog'

module Hostess
  class LoadBalancer

    def initialize(rackspace_username, rackspace_api_key, rackspace_datacenter)
      @load_balancers = Fog::Rackspace::LoadBalancers.new(
        :rackspace_username    => rackspace_username,
        :rackspace_api_key     => rackspace_api_key,
        :rackspace_auth_url    => 'auth.api.rackspacecloud.com',
        :rackspace_lb_endpoint => loadbalancer_endpoint(rackspace_datacenter)
      )

      @nodes = Fog::Compute.new(
        :provider => 'Rackspace',
        :rackspace_username    => rackspace_username,
        :rackspace_api_key     => rackspace_api_key,
        :rackspace_auth_url    => 'auth.api.rackspacecloud.com'
      ).servers
    end

    def loadbalancer_endpoint(datacenter)
      Fog::Rackspace::LoadBalancers.const_get("#{datacenter.upcase}_ENDPOINT")
    end

    def list
      @load_balancers.list_load_balancers.body['loadBalancers']
    end

    def show(load_balancer_id)
      @load_balancers.get_load_balancer(load_balancer_id).body['loadBalancer']
    end

    def create(name, protocol, port, node_search, node_port)
      pattern = Regexp.new('^(.+)-\d+$')

      load_balancer = @load_balancers.list_load_balancers.body['loadBalancers'].find_all do |load_balancer|
        load_balancer['name'] =~ pattern && $1 == name
      end.first

      result_nodes = search_nodes(node_search)
      nodes = result_nodes.map{|n| { :address => n, :port => Integer(node_port), :condition => 'ENABLED'} } unless result_nodes.nil?

      # name should be client-appname-environment-port ie target-facebooktabs-dev-80      
      name += "-#{port}"

      if load_balancer
        vip = [ 'id'=> load_balancer['virtualIps'].find { |v| v["ipVersion"] == "IPV4" }["id"] ]
        pp "Sharing VIP with existing load balancer #{name}"
      else
        vip = [{ :type => 'PUBLIC'}]
        pp "Creating #{@name}, #{@protocol}, #{@port}"
      end

      @load_balancers.create_load_balancer(name, protocol, port, vip, nodes)
    end

    def search_nodes(regex)
      search = Regexp.new(regex)
      pp "searching for nodes containing #{search}..."      
      result_nodes = @nodes.find_all{|server| search =~ server.name}
      result_nodes.collect{|n| n.addresses['private'].first}
    end

    def delete(load_balancer_id)
      @load_balancers.delete_load_balancer(load_balancer_id)
    end

    def list_nodes(load_balancer_id)
      pp @load_balancers.list_nodes(load_balancer_id)
    end 

    def list_nodes(load_balancer_id)
      @load_balancers.list_nodes(load_balancer_id).body['nodes'].each do |node|
        puts node
      end
    end 

    def nodes
      @nodes.table
    end

    # def update(load_balancer_id, node_search, node_port)
    #    nodes = search_nodes(node_search).map{|n| { :address => n, :port => Integer(node_port), :condition => 'ENABLED'} }
    #    pp nodes
    #   pp @load_balancers.update_load_balancer(load_balancer_id, { :nodes => nodes })
    # end 

  end
end
