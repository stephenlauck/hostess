require 'chef/knife/rackspace_base'
require 'chef/knife/rackspace_loadblancer_base'

class Chef
  class Knife
    class RackspaceLoadbalancerShow < Knife

      include Knife::RackspaceBase
      include RackspaceLoadbalancerBase

      deps do
        require 'hostess'
      end

      banner "knife rackspace loadbalancer show LOADBALANCER_ID [LOADBALANCER_ID] (options)"

      def run
        @name_args.each do |instance_id|
          loadbalancer = loadbalancers.show(instance_id)


          # ["name", "id", "protocol", "port", "algorithm", "status", "created", "virtualIps", "updated"]
          puts "\n"
          puts "#{ui.color("Instance ID", :cyan)}: #{loadbalancer['id'].to_s}"
          puts "#{ui.color("Name", :cyan)}: #{loadbalancer['name']}"
          puts "#{ui.color("Protocol", :cyan)}: #{loadbalancer['protocol']}"
          puts "#{ui.color("Port", :cyan)}: #{loadbalancer['port'].to_s}"
          puts "#{ui.color("Algorithm", :cyan)}: #{loadbalancer['algorithm']}"
          puts "#{ui.color("Virtual IP", :cyan)}: #{loadbalancer['virtualIps'].first['address'] == nil ? "" : loadbalancer['virtualIps'].first['address']}"
          puts "#{ui.color("Status", :cyan)}: #{loadbalancer['status']}"
          puts "#{ui.color("Nodes", :cyan)}: "
          # ["address", "id", "port", "status", "condition"]
          

          node_addresses = loadbalancer['nodes'].map { |node| node['address'] }
          node_servers = connection.servers.select { |s| (s.addresses['private'] & node_addresses).size > 0 }

          puts node_servers.table
        end
      end
    end
  end
end
