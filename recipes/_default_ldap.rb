#
# Cookbook Name:: aem
# Recipe:: aem: _default_ldap
#
# 

include_recipe 'chef-vault-util::default'

item = chef_vault_item(node['aem']['ldap']['vault_conf_type'], node['aem']['ldap']['vault_conf'])
   
#by default: we use an AD ldap conf sample template
template node['aem']['ldap_conf'] do
  source node['aem']['ldap']['template']
  owner node['aem']['user']
  group node['aem']['group']
  mode 0755
  variables({
      :authDn => item[node['aem']['ldap']['vault_authDn']],
      :authPw => item[node['aem']['ldap']['vault_authPw']],
      :userRoot => item[node['aem']['ldap']['vault_userRoot']],
      :groupRoot => item[node['aem']['ldap']['vault_groupRoot']],
      :userFilter  => item[node['aem']['ldap']['vault_userFilter']]      
    })
  notifies :restart, 'service[aem]', :delayed
end
  
directory node['aem']['repository_dir'] do
  owner node['aem']['user']
  group node['aem']['group']
  mode 0755
  recursive true
  action :create
  notifies :restart, 'service[aem]', :delayed
end