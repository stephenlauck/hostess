require 'chef/knife/rackspace_base'

class Chef
  class Knife
    class RackspaceLoadbalancerDelete < Knife

      include Knife::RackspaceBase

      banner "knife rackspace loadbalancer delete LOADBALANCER_ID [LOADBALANCER_ID] (options)"

      deps do
        require 'hostess'
      end

      def loadbalancers
        @loadbalancers ||= begin
          Hostess::LoadBalancer.new(
            Chef::Config[:knife][:rackspace_username],
            Chef::Config[:knife][:rackspace_api_key]
          )
        end
      end

      def run
        @name_args.each do |instance_id|
          
          # server = connection.servers.get(instance_id)

          loadbalancer = loadbalancers.show(instance_id)

          # ["name", "id", "protocol", "port", "algorithm", "status", "created", "virtualIps", "updated"]
          msg("Instance ID", loadbalancer['id'].to_s)
          msg("Name", loadbalancer['name'])
          msg("Protocol", loadbalancer['protocol'])
          msg("Port", loadbalancer['port'].to_s)
          msg("Algorithm", loadbalancer['algorithm'])
          msg("Virtual IP", loadbalancer['virtualIps'].first['address'] == nil ? "" : loadbalancer['virtualIps'].first['address'])
          msg("Status", loadbalancer['status'])

          puts "\n"
          confirm("Do you really want to delete this loadbalancer")

          @loadbalancers.delete(loadbalancer['id'])

          ui.warn("Deleted loadbalancer #{loadbalancer['id']} named #{loadbalancer['name']}")
        end
      end

      def msg(label, value)
        if value && !value.empty?
          puts "#{ui.color(label, :cyan)}: #{value}"
        end
      end
    end
  end
end
