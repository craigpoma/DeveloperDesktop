#!/bin/bash 
cd /tmp 
logger DeveloperDesktop Start PrepNode 
export PATH=/opt/chef-workstation/embedded/bin:$PATH
/opt/chef-workstation/embedded/bin/gem install --no-user-install kitchen-inspec
/opt/chef-workstation/embedded/bin/gem install --no-user-install aws-sdk
/opt/chef-workstation/embedded/bin/gem install --no-user-install train-aws
/opt/chef-workstation/embedded/bin/gem install --no-user-install aws-sdk-cloudtrail
/opt/chef-workstation/embedded/bin/gem cleanup train-aws
/opt/chef-workstation/embedded/bin/gem cleanup aws-sdk-organizations
/opt/chef-workstation/embedded/bin/gem cleanup aws-sdk-autoscaling
/opt/chef-workstation/embedded/bin/gem install --no-user-install kitchen-cloudformation
rm -f /opt/chef-workstation/embedded/lib/ruby/gems/2.6.0/gems/kitchen-cloudformation-1.5.0/kitchen-cloudformation.gemspec 
mv /tmp/kitchen-cloudformation.gemspec.1 /opt/chef-workstation/embedded/lib/ruby/gems/2.6.0/gems/kitchen-cloudformation-1.5.0/kitchen-cloudformation.gemspec 
rm -f /opt/chef-workstation/embedded/lib/ruby/gems/2.6.0/specifications/kitchen-cloudformation-1.5.0.gemspec
mv /tmp/kitchen-cloudformation.gemspec.2 /opt/chef-workstation/embedded/lib/ruby/gems/2.6.0/specifications/kitchen-cloudformation-1.5.0.gemspec
/opt/chef-workstation/embedded/bin/gem build /opt/chef-workstation/embedded/lib/ruby/gems/2.6.0/gems/kitchen-cloudformation-1.5.0/kitchen-cloudformation.gemspec
/opt/chef-workstation/embedded/bin/gem build /opt/chef-workstation/embedded/lib/ruby/gems/2.6.0/specifications/kitchen-cloudformation-1.5.0.gemspec
export CHEF_LICENSE="accept"
cd /tmp
chef generate cookbook cloudformation_sample
rm -f /tmp/cloudformation_sample/kitchen.yml
cp /tmp/kitchen-cloudformation-sample.yml /tmp/cloudformation_sample/kitchen.yml
cd /tmp/cloudformation_sample
kitchen list

