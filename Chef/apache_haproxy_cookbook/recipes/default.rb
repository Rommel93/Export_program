#
# Cookbook:: apache_haproxy_cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'java-1.6.0-openjdk'

package 'httpd'


service 'httpd' do
  supports status: true
  action [:enable, :start]
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
end
