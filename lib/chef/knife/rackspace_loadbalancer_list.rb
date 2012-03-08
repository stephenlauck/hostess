require 'chef/knife/rackspace_base'
require 'chef/knife/rackspace_loadbalancer_base'

class Chef
  class Knife
    class RackspaceLoadbalancerList < Knife

      include Knife::RackspaceBase
      include RackspaceLoadbalancerBase

      banner "knife rackspace loadbalancer list (options)"
      
      deps do
        require 'hostess'
      end

      def run
        $stdout.sync = true

        loadbalancers.list
        # ["name", "id", "protocol", "port", "algorithm", "status", "created", "virtualIps", "updated"]

        
        loadbalancer_list = [
          ui.color('Instance ID', :bold),
          ui.color('Name', :bold),
          ui.color('Protocol', :bold),
          ui.color('Port', :bold),
          ui.color('Algorithm', :bold),
          ui.color('Virtual IPS', :bold),
          ui.color('Status', :bold)
        ]

        # @lbs.list_load_balancers.body['loadBalancers'].each
       @loadbalancers.list.each do |lb|
          loadbalancer_list << lb['id'].to_s
          loadbalancer_list << (lb['name'] == nil ? "" : lb['name'])
          loadbalancer_list << (lb['protocol'] == nil ? "" : lb['protocol'])
          loadbalancer_list << (lb['port'].to_s == nil ? "" : lb['port'].to_s)
          loadbalancer_list << (lb['algorithm'] == nil ? "" : lb['algorithm'])
          loadbalancer_list << (lb['virtualIps'].first['address'] == nil ? "" : lb['virtualIps'].first['address'])
          loadbalancer_list << begin
        # ACTIVE = 'ACTIVE'
        # ERROR = 'ERROR'
        # PENDING_UPDATE = 'PENDING_UPDATE'
        # PENDING_DELTE = 'PENDING_DELETE'
        # SUSPENDED = 'SUSPENDED'
        # DELETED = 'DELETED'
        # BUILD = 'BUILD'
            case lb['status'].downcase
            when 'deleted','suspended', 'error'
              ui.color(lb['status'].downcase, :red)
            when 'build', 'pending_update', 'pending_delete'
              ui.color(lb['status'].downcase, :yellow)
            else
              ui.color(lb['status'].downcase, :green)
            end
          end
        end
        puts ui.list(loadbalancer_list, :columns_across, 7)

      end
    end
  end
end
