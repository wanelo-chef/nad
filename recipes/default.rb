#
# Cookbook Name:: nad
# Recipe:: default
#
# Copyright 2012, ModCloth, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'ipaddr_extensions'
include_recipe 'nodejs'

case node['platform']
when "smartos", "solaris2"
  include_recipe "smf"
end

git "/var/tmp/nad" do
  repository "https://github.com/circonus-labs/nad.git"
  reference node['nad']['reference']
end

execute "make and install nad binary" do
  command "cd /var/tmp/nad && make install"
  not_if "ls #{node['nad']['path']}/etc/node-agent.d"
end

execute "install nad man page" do
  command "cp /var/tmp/nad/nad.8 #{node['nad']['man_path']}/man8/"
  not_if "ls -al #{node['nad']['man_path']}/man8/nad.8"
end

case node['platform']
when "smartos", "solaris2"
  execute "compile C-extensions" do
    command "cd #{node['nad']['path']}/etc/node-agent.d/illumos && test -f Makefile && make PREFIX=/opt/circonus"
    not_if "ls #{node['nad']['path']}/etc/node-agent.d/illumos/aggcpu.elf"
  end

  template "/opt/circonus/etc/node-agent.d/illumos/link.sh" do
    source "link.sh.erb"
    mode "0755"
  end

  template "/opt/circonus/etc/node-agent.d/illumos/memory.sh" do
    source "memory.sh.erb"
    mode "0755"
  end

  template "/opt/circonus/etc/node-agent.d/illumos/disk.sh" do
    source "disk.sh.erb"
    mode "0755"
  end

  file "/opt/circonus/etc/node-agent.d/illumos/zone_vfs.sh" do
    mode "0755"
  end

  link "/opt/circonus/etc/node-agent.d/if.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/if.sh"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/aggcpu.elf" do
    to "/opt/circonus/etc/node-agent.d/illumos/aggcpu.elf"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/sdinfo.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/sdinfo.sh"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/zfsinfo.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/zfsinfo.sh"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/vminfo.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/vminfo.sh"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/link.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/link.sh"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/memory.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/memory.sh"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/disk.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/disk.sh"
    notifies :restart, "service[nad]"
  end

  link "/opt/circonus/etc/node-agent.d/zone_vfs.sh" do
    to "/opt/circonus/etc/node-agent.d/illumos/zone_vfs.sh"
    notifies :restart, "service[nad]"
  end

  smf "nad" do
    user "nobody"
    start_command "#{node['nad']['path']}/sbin/nad -c #{node['nad']['path']}/etc/node-agent.d -p #{node['privateaddress']}:#{node['nad']['port']}"
    environment "HOME" => "#{node['nad']['path']}/etc",
                "PATH" => "/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin",
                "NODE_PATH" => "#{node['nad']['path']}/lib/node_modules:#{node['nad']['path']}/etc/node_modules"
    manifest_type "application"
    duration "child"
    notifies :restart, 'service[nad]'
  end

  service 'nad'

when "ubuntu", "debian"
  template "/etc/init.d/nad" do
    source "nad.init.erb"
    mode 0755
    notifies :restart, "service[nad]"
  end
end

service "nad" do
  action :enable
end
