#
# Cookbook Name:: shinken
# Recipe:: base
#
# Copyright 2013, Arthur Gautier
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#


## Base recipe
# This recipe as a dependency of every shinken elements

### Run_state 
# The run state is used to store content during the run and to generate content
# at the end.
node.run_state["shinken"] = {}

if node['platform_family'] == "debian"
  ### Packaging
  #### Shinken's repository
  # Shinken resides in its own directory
  apt_repository "shinken-dev" do
    uri "http://shinken.apt.znx.fr/"
    distribution "sid"
    components ["main"]
    key "http://shinken.apt.znx.fr/packages@zenexity.com.gpg.key"
    action :add
  end
end

#### Package install
# We'll install core package which contains common files and common
# configuration
package node["shinken"]["core_package"]

template "shinken/default/debian" do
  path   "/etc/default/shinken"
  source "default/shinken.erb"
  mode   "00644"
end

### Cleanup
# Remove unused files
['brokerd-windows.ini',
 'pollerd-windows.ini',
 'reactionnerd-windows.ini',
 'receiverd-windows.ini',
 'schedulerd-windows.ini',
 'commands.cfg',
 'contactgroups.cfg',
 'discovery.cfg',
 'discovery_rules.cfg',
 'discovery_runs.cfg',
 'escalations.cfg',
 'servicegroups.cfg',
 'templates.cfg',
 'timeperiods.cfg',
 'shinken-specific-high-availability.cfg',
 'shinken-specific-load-balanced-only.cfg'].each do |f|
  file ::File.join('/etc/shinken', f) do
    action :delete
  end
end

directory "/etc/shinken/packs"

directory "/etc/shinken/objects" do
  action :delete
  recursive true
end

cookbook_file "/etc/shinken/resource.cfg" do
  mode "00644"
end

if node[:platform] == "centos"

  cookbook_file "/etc/init.d/shinken" do
    mode "0755"
  end

  package "python-ldap"

end
