# Dispatcher uses OpenSSL to implement secure communication over HTTP. 
# Dispatcher supports OpenSSL 0.9.8 and OpenSSL 1.0.0. Dispatcher uses version 0.9.8 by default. 
# To work around this, the recipe will create the needed symbolic links for you.
if  File.exists?('/usr/lib64/libssl.so')
  node.default['apache']['cq_dispatcher_linked_libssl']='/usr/lib64/libssl.so'
  # on centos  
elsif  File.exists?('/lib64/libssl.so.6')
  node.default['apache']['cq_dispatcher_linked_libssl']='/lib64/libssl.so.6'
  # on rhel  
else
  log 'Cant locate openssl libssl.so on this node' do
     level :error
  end        
end
link '/usr/lib64/libssl.so.0.9.8' do
  to node['apache']['cq_dispatcher_linked_libssl']
  owner 'root'
  group node['apache']['root_group']
  not_if do
      File.exists?('/usr/lib64/libssl.so.0.9.8')
  end
  notifies :restart, 'service[apache2]', :delayed
end

if  File.exists?('/usr/lib64/libcrypto.so')
  node.default['apache']['cq_dispatcher_linked_libcrypto']='/usr/lib64/libcrypto.so'
  # on centos  
elsif  File.exists?('/lib64/libcrypto.so.6')
  node.default['apache']['cq_dispatcher_linked_libcrypto']='/lib64/libcrypto.so.6'
  # on rhel  
else
  log "Can't locate openssl libcrypto.so on this node" do
       level :error
  end        
end
link '/usr/lib64/libcrypto.so.0.9.8' do
  to node['apache']['cq_dispatcher_linked_libcrypto']
  owner 'root'
  group node['apache']['root_group']
  not_if do
    File.exists?('/usr/lib64/libcrypto.so.0.9.8')
  end
  notifies :restart, 'service[apache2]', :delayed
end

## will now fetch the ssl cert and key in the appropiate directory
directory node['apache']['ssl_cert_dir'] do
  owner 'root'
  group node['apache']['root_group']
  mode 0755
  recursive true
  action :create
  notifies :restart, 'service[apache2]', :delayed
end

include_recipe 'chef-vault-util::default'

vault_crt = chef_vault_item(node['apache']['vault_ssl'], node['apache']['vault_ssl_cert'])
file node['apache']['ssl_cert_file_path'] do
  content vault_crt[node['apache']['vault_ssl_cert_id']]
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :restart, 'service[apache2]', :delayed
end

vault_crt = chef_vault_item(node['apache']['vault_ssl'], node['apache']['vault_ssl_key'])
file node['apache']['ssl_key_file_path'] do
  content vault_crt[node['apache']['vault_ssl_key_id']]
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  notifies :restart, 'service[apache2]', :delayed
end

template "#{node['apache']['dir']}/conf.d/ssl.conf" do
  source   'httpd.ssl.conf.erb'
  owner    'root'
  group    node['apache']['root_group']
  mode     '0644'
  notifies :restart, 'service[apache2]', :delayed
end
