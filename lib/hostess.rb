require "hostess/version"
require "fog"

module Hostess
  autoload :CLI, "hostess/cli"
  autoload :LoadBalancer, "hostess/load_balancer"
end
