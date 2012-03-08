module RackspaceLoadbalancerBase 
  def loadbalancers
    @loadbalancers ||= begin
      Hostess::LoadBalancer.new(
        Chef::Config[:knife][:rackspace_username],
        Chef::Config[:knife][:rackspace_api_key],
        Chef::Config[:knife][:rackspace_datacenter]
      )
    end
  end
end
