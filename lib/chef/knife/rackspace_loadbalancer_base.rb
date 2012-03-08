module RackspaceLoadbalancerBase 
  def loadbalancers
    @loadbalancers ||= begin
      Hostess::LoadBalancer.new(
        Chef::Config[:knife][:rackspace_username],
        Chef::Config[:knife][:rackspace_api_key]
      )
    end
  end
end
