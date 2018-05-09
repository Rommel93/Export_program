#
# Cookbook:: tomcat_cookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package 'java-1.7.0-openjdk-devel' do
	not_if 'java -version |grep 1.7'
end

group 'tomcat' do
	not_if 'grep tomcat /etc/passwd', :group => 'tomcat'
end

user 'tomcat' do
	group 'tomcat'
	system true
	shell '/bin/bash'
	not_if 'grep tomcat /etc/passwd', :user => 'tomcat'
end

remote_file '/tmp/apache-tomcat-8.0.51.tar.gz' do
	source 'http://apache.mirrors.hoobly.com/tomcat/tomcat-8/v8.0.51/bin/apache-tomcat-8.0.51.tar.gz'
	owner 'tomcat'
	group 'tomcat'
	mode '0755'
	not_if { ::File.exist?('/tmp/apache-tomcat-8.0.51.tar.gz') }
end

remote_file '/tmp/sample.war' do
	source 'https://github.com/johnfitzpatrick/certification-workshops/blob/master/Tomcat/sample.war'
	owner 'tomcat'
	group 'tomcat'
	mode '0755'
	not_if { ::File.exist?('/tmp/sample.war') }
end


directory '/opt/tomcat' do
	owner 'tomcat'
	group 'tomcat'
	mode '0755'
	action :create
	not_if 'ls -ld /opt/tomcat/'
end

execute 'tar xvf /tmp/apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1' do
	not_if { ::File.exist?('/opt/tomcat/conf') }
end

directory '/opt/tomcat/conf' do
	owner 'tomcat'
	group 'tomcat'
	mode '0777'
	not_if 'stat -c %a /opt/tomcat/conf |grep 777'
end

execute 'chgrp -R tomcat /opt/tomcat/conf'do
	only_if 'stat -c %G /opt/tomcat/conf/ | grep -v tomcat'
end

execute 'chmod g+r /opt/tomcat/conf/*'do
		only_if 'stat -c %A /opt/tomcat/conf/* | grep "rw-r'
end

execute 'chown -R tomcat:tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/'do
	only_if 'stat -c %G /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/ |grep -v tomcat'
end

template '/etc/systemd/system/tomcat.service' do
	source 'tomcat.service.erb'
	notifies :run, 'execute[daemon-reload]', :immediately
end

execute 'daemon-reload' do
	command 'systemctl daemon-reload'
	action :nothing
	notifies :enable,'service[tomcat]', :immediately
	notifies :start, 'service[tomcat]', :immediately
end

service 'tomcat' do
	supports status: true
#  action [:enable, :start]
	end
