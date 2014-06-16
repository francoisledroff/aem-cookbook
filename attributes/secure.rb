################################
## secure related attributed
################################ 

default['aem']['cq_admin_default_password'] = 'admin' 
   
# the vault cq_admin accounts item can be created with the following command:
# knife encrypt  create accounts cq_admin '{\'username\' : \'admin\', \'password\' : \'new\'}' -A 'ledroff' --mode client -S 'name:vagrant-esqi'  
# the chef-vault/encrypted data bag type name  
default['aem']['vault_accounts'] = 'accounts'
# the chef-vault/encrypted data bag name 
default['aem']['vault_accounts_cq_admin_item'] = 'cq_admin'     
# the chef-vault/encrypted data bag username property
default['aem']['vault_accounts_username_property'] = 'username'
# the chef-vault/encrypted data bag password property
default['aem']['vault_accounts_password_property'] = 'password'
  
# cf. http://dev.day.com/docs/en/crx/current/how_to/package_manager.html#Uninstalling%20Packages  
default['aem']['package_api_endpoint']            = node['aem']['url']+'/crx/packmgr/service/.json'    
default['aem']['package_api_uninstall_command']   = '?cmd=uninstall'
default['aem']['package_api_delete_command']      = '?cmd=delete'
default['aem']['package_api_nuke_commands']       = [node['aem']['package_api_uninstall_command'], node['aem']['package_api_delete_command']]  
default['aem']['cq_geometrixx_pkg_path']          = '/etc/packages/day/cq550/product/cq-geometrixx-pkg-5.5.4.zip'
default['aem']['cq_geometrixx_outdoors_pkg_path'] = '/etc/packages/day/cq550/product/cq-geometrixx-outdoors-pkg-5.5.8.zip' 
default['aem']['cq_geometrixx_pkgs']              = [node['aem']['cq_geometrixx_pkg_path'], node['aem']['cq_geometrixx_outdoors_pkg_path']]
 

# crxde is disabled by stopping the com.day.crx.crxde-support osgi bundle, 
# as for webdav disabling it is done by stopping org.apache.sling.jcr.webdav and org.apache.sling.jcr.davex
# curl command : http://www.wemblog.com/2011/12/how-to-manage-bundle-using-curl-command.html  
default['aem']['bundle_api_endpoint']  = node['aem']['url']+'/system/console/bundles/' 
default['aem']['disabled_osgi_bundles'] = ['com.day.crx.crxde-support','org.apache.sling.jcr.webdav', 'org.apache.sling.jcr.davex']
    
  