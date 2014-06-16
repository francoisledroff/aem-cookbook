case node['platform_family']
when 'rhel' 
  log 'this platform family is supported' do
    level :info
  end
else 
  log 'this platform family is not supported' do
    level :error
  end
end
 
case node['platform']
when 'centos' 
   if node['platform_version'] == '6.4'
     ## empiric yum list httpd gave me this version  
     node.default['apache']['version'] = '2.2.15-29.el6.centos'
   else     
      log 'this platform version was never tested' do
        level :warn
      end
   end   
when 'redhat' 
   if node['platform_version'] == '5.5'
     ## empiric yum list httpd gave me this version   
     node.default['apache']['version'] = '2.2.3-43.el5'     
   elsif node['platform_version'] == '5.10'
     node.default['apache']['version'] = '2.2.3-83.el5_10'
   else
     log 'this platform version was never tested' do
         level :warn
     end     
   end             
else 
  log 'this platform family is not supported' do
    level :error
  end
end
 
if node['apache'].attribute?('version')
  package 'apache2' do
    package_name node['apache']['package']
    version  node['apache']['version'] 
    notifies :restart, 'service[apache2]', :delayed
  end
  package 'mod_ssl' do
    package_name node['mod_ssl']['package']
    version  node['apache']['version']
    notifies :restart, 'service[apache2]', :delayed 
    only_if { node['apache']['ssl'] } 
  end  
else
  package 'apache2' do
    package_name node['apache']['package']
    notifies :restart, 'service[apache2]', :delayed
  end
  package 'mod_ssl' do
    package_name node['mod_ssl']['package']
    notifies :restart, 'service[apache2]', :delayed 
    only_if { node['apache']['ssl'] } 
  end 
end 

if node['apache']['ssl']   
  include_recipe 'aaem::_dispatcher_ssl'
end

# by default apache rpm will be installed in /etc/httpd, we add a link in apps 
link node['apache']['apps_link'] do
  to node['apache']['dir']
  owner node['apache']['user']
  group node['apache']['group']
  mode 0755 
end

directory node['apache']['docroot_dir'] do
  owner node['apache']['user']
  group node['apache']['group']
  mode 0755
  recursive true
  action :create
end


if node['apache']['ssl'] 
  node.default['apache']['port'] = node['apache']['https_port']
  node.default['apache']['url'] = 'https://localhost'  
  node.default['apache']['cq_dispatcher_module_url'] = node['apache']['cq_ssl_dispatcher_module_url']
else
  node.default['apache']['port'] = node['apache']['http_port']
  node.default['apache']['url'] = 'http://localhost' 
  node.default['apache']['cq_dispatcher_module_url'] = node['apache']['cq_non_ssl_dispatcher_module_url']
end

remote_file node['apache']['cq_dispatcher_module_file_path'] do
  source node['apache']['cq_dispatcher_module_url']
  mode 0755
  owner 'root'
  group node['apache']['root_group']
  action :create_if_missing 
  notifies :restart, 'service[apache2]', :delayed 
end


template node['apache']['dir']+'/conf/httpd.conf' do
  source   'httpd.conf.erb'
  owner    'root'
  group    node['apache']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]', :delayed 
end


template node['apache']['cq_dispatcher_module_config_file_path'] do
  source   'cq_dispatcher.any.erb'
  owner    'root'
  group    node['apache']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]', :delayed 
end

template node['apache']['cq_dispatcher_httpd_config_file_path'] do
  source   'cq_dispatcher.httpd.conf.erb'
  owner    'root'
  group    node['apache']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]', :delayed 
end



## inspired from opscode apache2 cookbook
service 'apache2' do
   service_name 'httpd'
   # If restarted/reloaded too quickly httpd has a habit of failing.
   # This may happen with multiple recipes notifying apache to restart - like
   # during the initial bootstrap.
   restart_command '/sbin/service httpd restart && sleep 1'
   reload_command '/sbin/service httpd reload && sleep 1'
   supports [:start, :stop, :restart, :reload, :status]
   action [:enable, :start]
end

log 'ensure_apache_is_started' do
  notifies :create, 'ruby_block[block_until_apache_operational]', :delayed
end


ruby_block 'block_until_apache_operational' do
  block do
    Chef::Log.info 'Waiting until apache is listening on port '+ node['apache']['port']
    until CQHelper.service_listening?(node['apache']['port'])
      sleep 1
      Chef::Log.info('.')
    end

    Chef::Log.info 'Waiting until the apache default page is responding'
    test_url = URI.parse(node['apache']['url'])
    until CQHelper.endpoint_responding?(test_url)
      sleep 1
      Chef::Log.info('.')
    end
  end
  action :nothing
end

# adding the handy apache-logs link
link node['apache']['log_link'] do
  to node['apache']['log_dir']
  owner node['aem']['user']
  group node['aem']['group']
  mode 0755 
end


