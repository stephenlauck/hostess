module Hostess
  class LoadBalancer
 
    require 'fog'

    def initialize(*args)
      super

      @load_balancers = Fog::Rackspace::LoadBalancers.new(
        :rackspace_auth_url    => 'auth.api.rackspacecloud.com',
        :rackspace_lb_endpoint => Fog::Rackspace::LoadBalancers::ORD_ENDPOINT
      )

      @nodes = Fog::Compute[:rackspace].servers
    end

    def list
      puts "id \t name\n-------------------------------"
      @load_balancers.list_load_balancers.body['loadBalancers'].each do |lb|
        puts "#{lb['id']}\t #{lb['name']}"
      end
    end

    def show(load_balancer_id)
      pp @load_balancers.get_load_balancer(load_balancer_id).body['loadBalancer']
    end

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

    def search_nodes(regex)
      search = Regexp.new(regex)
      pp "searching for nodes containing #{search}..."
      result_nodes = @nodes.find_all{|server| search =~ server.name}
      result_nodes.collect{|n| n.addresses['private'].first}
    end

    def delete(load_balancer_id)
      pp @load_balancers.delete_load_balancer(load_balancer_id)
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
