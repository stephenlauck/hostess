

require "hostess/version"

module Hostess
  autoload :CLI, "hostess/cli"

  def initialize
    @connection = Fog::Rackspace

    @load_balancers = Fog::Rackspace::LoadBalancers.new(
      :rackspace_auth_url    => 'auth.api.rackspacecloud.com',
      :rackspace_lb_endpoint => Fog::Rackspace::LoadBalancers::ORD_ENDPOINT
    )
  end

end
