#
# Cookbook Name:: aem
# Recipe:: default
#
#

case node['platform_family']
when 'rhel' 
  log 'this platform family is supported' do
    level :info
  end
else 
  log 'this platform family is not supported' do
    level :warn
  end
end

## create user and group
group node['aem']['group'] do
  notifies :restart, 'service[aem]', :delayed
end

user node['aem']['user'] do
  comment 'aem node user'
  gid node['aem']['group']
  home node['aem']['home']
  shell node['aem']['shell']
  notifies :restart, 'service[aem]', :delayed
end

## ulimit are set in serverclt but failed there (permission denied...) 
#  hence we set it through chef recipe first
include_recipe 'ulimit'
user_ulimit node['aem']['user'] do
   filehandle_limit node['aem']['max_files']
   notifies :restart, 'service[aem]', :delayed
end


# the java default install open jdk6 by default
# include_recipe 'java::default'
# but here we want to install jdk6 from Oracle
java_ark 'jdk' do
    url node['java']['jdk_url']
    #checksum node['java']['jdkchecksum']
    app_home node['java']['home']
    bin_cmds ['java', 'javac']
    action :install
    notifies :restart, 'service[aem]', :delayed
end

directory node['aem']['install_dir'] do
  owner node['aem']['user']
  group node['aem']['group']
  mode 0755
  recursive true
  action :create
  notifies :restart, 'service[aem]', :delayed
end

remote_file node['aem']['quickstart_jar'] do
  source node['aem']['jar_url']
  mode 0755
  owner node['aem']['user']
  group node['aem']['group']
  action :create_if_missing  
  notifies :restart, 'service[aem]', :delayed
end


include_recipe 'chef-vault-util::default'

license_properties = chef_vault_item('license', 'aem_license')
file node['aem']['license'] do
  content license_properties['license.properties']
  mode 0755
  owner node['aem']['user']
  group node['aem']['group']
  notifies :restart, 'service[aem]', :delayed
end

#copy over the serverctl file fetch from aem.4 
cookbook_file node['aem']['serverctl'] do
  source 'serverctl'
  mode 0755
  owner node['aem']['user']
  group node['aem']['group']
  notifies :restart, 'service[aem]', :delayed
end


# Note that configure aem serverctl needs CQ_JVM_OPTS environment variable
# this file template is one way to set it for our service
template 'etc/default/aem' do
    source 'etc_default_aem.erb'
    owner 'root'
    group 'root'
    mode 0755
    notifies :restart, 'service[aem]', :delayed
end
# this file template is the service cq script leveraging serverctl
template 'etc/init.d/aem' do
    source 'etc_init.d_aem.erb'
    owner 'root'
    group 'root'
    mode 0755
    notifies :restart, 'service[aem]', :delayed
end


#unpack aem quickstart jar
execute 'java' do
  command node['aem']['unpack']
  cwd node['aem']['install_dir']
  action :run
  user node['aem']['user']
  group node['aem']['group']
  not_if do
	File.exists?(node['aem']['stdout_log'])
  end
  notifies :restart, 'service[aem]', :delayed
end

## configure ldap authentication
if node['aem']['ldap']['enabled']
  include_recipe 'aaem::_default_ldap'
  #copy over the repository.xml template where ldap is enabled if node['aem']['ldap']['enabled'] 
  #out of the above if closure, to make the recipe idempotent (when node attribute is changed)
  template node['aem']['repository.xml'] do
     source 'repository.xml.erb'
     mode 0755
     owner node['aem']['user']
     group node['aem']['group']
     notifies :restart, 'service[aem]', :delayed
  end
end

# Set the aem service to run at startup
execute 'aem_autostart' do
    command 'chkconfig --add aem'
end

# adding the handy cq-logs link
link node['aem']['log_link'] do
  to node['aem']['log_dir']
  owner node['aem']['user']
  group node['aem']['group']
  mode 0755 
end

service 'aem' do
  action [:enable]
  supports [:status, :start, :stop, :restart]
end
