require 'chef/knife/rackspace_base'

class Chef
  class Knife
    class RackspaceLoadbalancerList < Knife

      include Knife::RackspaceBase
      
      deps do
        require 'hostess'
        require 'fog'
      end
      
      banner "knife rackspace loadbalancer list (options)"

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

        loadbalancers.list
        
        # server_list = [
        #   ui.color('Instance ID', :bold),
        #   ui.color('Public IP', :bold),
        #   ui.color('Private IP', :bold),
        #   ui.color('Flavor', :bold),
        #   ui.color('Image', :bold),
        #   ui.color('Name', :bold),
        #   ui.color('State', :bold)
        # ]
        # connection.servers.all.each do |server|
        #   server_list << server.id.to_s
        #   server_list << (server.public_ip_address == nil ? "" : server.public_ip_address)
        #   server_list << (server.addresses["private"].first == nil ? "" : server.addresses["private"].first)
        #   server_list << (server.flavor_id == nil ? "" : server.flavor_id.to_s)
        #   server_list << (server.image_id == nil ? "" : server.image_id.to_s)
        #   server_list << server.name
        #   server_list << begin
        #     case server.state.downcase
        #     when 'deleted','suspended'
        #       ui.color(server.state.downcase, :red)
        #     when 'build'
        #       ui.color(server.state.downcase, :yellow)
        #     else
        #       ui.color(server.state.downcase, :green)
        #     end
        #   end
        # end
        # puts ui.list(server_list, :columns_across, 7)

      end
    end
  end
end
