#
# Cookbook Name:: aem
# Recipe:: logrotate
#
#

begin
    include_recipe 'logrotate'
rescue
    Chef::Log.warn('The apache::logrotate recipe requires the logrotate cookbook. Install the cookbook with `knife cookbook site install logrotate`.')
end

logrotate_app 'httpd' do
  cookbook  'logrotate'
  path      node['apache']['log_dir']
  frequency node['aem']['logrotate']['frequency']
  rotate    node['aem']['logrotate']['rotate']
end

#TODO check if we need that, as we may have log rotation for free in aem...
logrotate_app 'aem' do
  cookbook  'logrotate'
  path      node['aem']['log_dir']
  frequency node['aem']['logrotate']['frequency']
  rotate    node['aem']['logrotate']['rotate']
end
