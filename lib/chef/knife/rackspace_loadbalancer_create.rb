require 'chef/knife/rackspace_base'

class Chef
  class Knife
    class RackspaceLoadbalancerCreate < Knife

      include Knife::RackspaceBase

      # deps do
      #         require 'fog'
      #         require 'readline'
      #         require 'chef/json_compat'
      #         require 'chef/knife/bootstrap'
      #         Chef::Knife::Bootstrap.load_deps
      #       end

      deps do
        require 'hostess'
      end
      
      banner "knife rackspace loadbalancer create (options)"

      # TODO figure out way to get rackspace data center Endpoint from Chef::Config
      # maybe using code similar to comments below
        
      # option :flavor,
      #   :short => "-f FLAVOR",
      #   :long => "--flavor FLAVOR",
      #   :description => "The flavor of server; default is 2 (512 MB)",
      #   :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f.to_i },
      #   :default => 2

      # option :rackspace_metadata,
      #   :short => "-M JSON",
      #   :long => "--rackspace-metadata JSON",
      #   :description => "JSON string version of metadata hash to be supplied with the server create call",
      #   :proc => Proc.new { |m| Chef::Config[:knife][:rackspace_metadata] = JSON.parse(m) },
      #   :default => ""

      # create(name, protocol, port, node_search, node_port)
      option :name,
        :short => "-N NAME",
        :long => "--name NAME",
        :description => "The loadbalancer name"

      option :protocol,
        :short => "-P PROTOCOL",
        :long => "--protocol PROTOCOL",
        :description => "The loadbalancer protocol"

      option :port,
        :short => "-p PORT",
        :long => "--port PORT",
        :description => "The loadbalancer port"

      option :node_search,
        :short => "-s NODE_SEARCH",
        :long => "--node-search NODE_SEARCH",
        :description => "The regular expression to search for nodes to add to loadbalancer"

      option :node_port,
        :short => "-n NODE_PORT",
        :long => "--node-port NODE_PORT",
        :description => "The port for added nodes"

      def loadbalancers
        @loadbalancers ||= begin
          Hostess::LoadBalancer.new(
            Chef::Config[:knife][:rackspace_username],
            Chef::Config[:knife][:rackspace_api_key]
          )
        end
      end

      def run
        $stdout.sync = true

        loadbalancer = loadbalancers.create(
          config[:name],
          config[:protocol],
          config[:port],
          config[:node_search],
          config[:node_port]
        )

        puts loadbalancer
        # ["name", "id", "protocol", "port", "algorithm", "status", "created", "virtualIps", "updated"]
        puts "\n"
        puts "#{ui.color("Instance ID", :cyan)}: #{loadbalancer['id'].to_s}"
        puts "#{ui.color("Name", :cyan)}: #{loadbalancer['name']}"
        puts "#{ui.color("Protocol", :cyan)}: #{loadbalancer['protocol']}"
        puts "#{ui.color("Port", :cyan)}: #{loadbalancer['port'].to_s}"
        puts "#{ui.color("Algorithm", :cyan)}: #{loadbalancer['algorithm']}"
        puts "#{ui.color("Virtual IP", :cyan)}: #{loadbalancer['virtualIps'].first['address'] == nil ? "" : loadbalancer['virtualIps'].first['address']}"
        puts "#{ui.color("Status", :cyan)}: #{loadbalancer['status']}"
        
      end
    end
  end
end
