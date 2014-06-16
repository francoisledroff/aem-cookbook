#
# Cookbook Name:: aem
# Attributes:: node
#
#

################################
## default related attributed
################################ 

#configure install directory paths where aem is installed and node['apache']['docroot_dir'] will be
default['apps_dir']   = '/apps'
# tell the recipe where to find jdk and aem binaries
default['artifact_repo_url']  = 'your nexus/artifactory/binaries repo url'  
default['aem']['jar_url'] = node['artifact_repo_url']+'com/day/cq/cq5/5.5.0.20120220/cq5-5.5.0.20120220.jar'
## java attributes  
default['java']['jdk_url'] =  node['artifact_repo_url']+'com/oracle/jdk/6u45-linux-x64/jdk-6u45-linux-x64.bin'  
default['java']['jdk_version'] = '1.6.0_45'
#default['java']['jdk_url'] = 'http://download.oracle.com/otn-pub/java/jdk/6u45-b06/jdk-6u45-linux-x64.bin'
#default['java']['jdkchecksum'] = '6b493aeab16c940cae9e3d07ad2a5c5684fb49cf06c5d44c400c7993db0d12e8'  
default['java']['oracle']['accept_oracle_download_terms'] = true
default['java']['home'] = File.join(node['apps_dir'], '/java')
  
  
#linux user and group used to unpack cq and run it as a service and run httpd (if the dispatcher recipe is applied)
default['aem']['user'] = 'aem-node'
default['aem']['group'] = 'aem-node'
  
default['aem']['shell'] = '/bin/sh'
default['aem']['home'] = '/home/aem'
  
default['aem']['mode'] = 'publish'
default['aem']['port'] = '4503'

default['aem']['url'] = 'http://localhost:'+ node['aem']['port']

default['aem']['max_files'] = '8192'
default['aem']['heap_min'] = '2048'
default['aem']['heap_max']= '2048'
default['aem']['permgen'] = '512'  
  
# default cq server name   
default['aem']['name'] = node['fqdn']
default['aem']['appname'] = node['hostname']  


# ldap attribute if node['aem']['debug'] is set to true, debug will be set on node['aem']['debug_port']
default['aem']['debug']=true
default['aem']['debug_port']='5005'
    

## cq jar file source and destination
default['aem']['install_dir'] = File.join(node['apps_dir'], '/'+node['aem']['mode'])
default['aem']['jar'] = 'aem-'+ node['aem']['mode'] + '-' + node['aem']['port'] + '.jar'
default['aem']['quickstart_jar']  = File.join(node['aem']['install_dir'], '/'+node['aem']['jar'])
 
## logs :  
default['aem']['log_dir'] = File.join(node['aem']['install_dir'], '/crx-quickstart/logs')
# the recipe add a link from apps to cq log using the file path below
default['aem']['log_link'] =  File.join(node['apps_dir'], '/cq-logs') 
#we will test this existence of this file to see if we already ran the unpack command
default['aem']['stdout_log'] = File.join(node['aem']['log_dir'], '/stdout.log')
#cq startuplog use in the service  
default['aem']['startup_log'] = File.join(node['aem']['log_dir'], '/startup.log')
default['aem']['service_log'] = File.join(node['aem']['log_dir'], '/service.log') 
default['aem']['service_error_log'] = File.join(node['aem']['log_dir'], '/service.error.log')  

default['aem']['conf_dir']        = File.join(node['aem']['install_dir'], '/crx-quickstart/conf')
  
  
#where to place the license.properties file
default['aem']['license']   = File.join(node['aem']['install_dir'], '/license.properties')
  
#where to place the serverctl file
default['aem']['serverctl']   = File.join(node['aem']['install_dir'], '/serverctl')

#command to unpack CQ jar file
default['aem']['unpack']    = 'java -jar '+ node['aem']['jar'] +' -unpack'

################################
## ldap related attributes
################################     
default['aem']['ldap_conf']  = File.join(node['aem']['conf_dir'], '/ldap.conf')
default['aem']['repository_dir']  = File.join(node['aem']['install_dir'], '/crx-quickstart/repository')
default['aem']['repository.xml']  = File.join(node['aem']['repository_dir'], '/repository.xml')
  
include_attribute 'aaem::_default_ldap'  
 
  
################################
## dispatcher related attributed
################################    
# try out 'yum list httpd' to find out if the version is available
default['apache']['package'] = 'httpd'
default['mod_ssl']['package'] = 'mod_ssl'
#default['apache']['version'] = '2.2.15-29.el6.centos' now set in the dispatcher recipe based on the linux platform
default['apache']['cq_dispatcher_version'] = '2.2-4.1.5'
# watch out the dispatcher version must match the apache version too must match 
# cf. https://www.adobeaemcloud.com/content/companies/public/adobe/dispatcher/dispatcher.html

default['apache']['dir']                = '/etc/httpd'
default['apache']['conf_dir']           = File.join(node['apache']['dir'], '/conf.d')
default['apache']['apps_link']          = File.join(node['apps_dir'], '/apache')
default['apache']['log_dir']            = File.join(node['apache']['dir'], 'logs')  
default['apache']['log_link']           = File.join(node['apps_dir'], '/apache-logs')
      
default['apache']['ssl']  = true
default['apache']['http_port'] = '80'
default['apache']['https_port'] = '443'
default['apache']['servername'] = 'yourservername.yourdomain'
#default['apache']['servername'] =  node['fqdn'] 
 
default['apache']['ssl_cert_dir']       = File.join(node['apps_dir'], '/ssl')
default['apache']['ssl_cert_file_path'] = File.join(node['apache']['ssl_cert_dir'], node['apache']['servername']+'.crt')
default['apache']['ssl_key_file_path']  = File.join(node['apache']['ssl_cert_dir'], node['apache']['servername']+'.key')

# the dispatcher recipe expects ssl related encrypted data bags (managed in the recipe with chef-vault)
# the chef-vault/encrypted ssl data bag type name  
default['apache']['vault_ssl'] = 'certs'
# the chef-vault/encrypted ssl cert data bag name 
default['apache']['vault_ssl_cert'] = 'server_crt'     
# the chef-vault/encrypted data bag ssl cert field
default['apache']['vault_ssl_cert_id'] = 'server.crt'
# the chef-vault/encrypted ssl key data bag name 
default['apache']['vault_ssl_key'] = 'server_key'     
# the chef-vault/encrypted data bag ssl key field
default['apache']['vault_ssl_key_id'] = 'server.key' 
   
default['apache']['ssl_rewrite']               = true  
default['apache']['ssl_rewrite_log_file_path'] = File.join(node['apache']['log_dir'], 'rewrite-ssl.log')  

   
default['apache']['user']        = node['aem']['user']
default['apache']['group']       = node['aem']['group']
default['apache']['contact']     = node['aem']['contact']
default['apache']['root_group']  = 'root'
default['apache']['docroot_dir'] = File.join(node['apps_dir'], '/apache_cq_docroot')  
  
default['apache']['cq_non_ssl_dispatcher_module_url']  = node['artifact_repo_url']+'/com/day/cq/dispatcher-apache/'+node['apache']['cq_dispatcher_version']+'/dispatcher-apache-'+node['apache']['cq_dispatcher_version']+'.so'
default['apache']['cq_ssl_dispatcher_module_url']      = node['artifact_repo_url']+'/com/day/cq/dispatcher-ssl-apache/'+node['apache']['cq_dispatcher_version']+'/dispatcher-ssl-apache-'+node['apache']['cq_dispatcher_version']+'.so'
default['apache']['cq_dispatcher_module_file_relpath'] = 'modules/mod_cq_dispatcher-'+ node['apache']['cq_dispatcher_version'] +'.so'
default['apache']['cq_dispatcher_module_file_path']    = File.join(node['apache']['dir'], node['apache']['cq_dispatcher_module_file_relpath'])
 
# change the templates according to your needs (we provide the generic publish template) 
# to override this template in your recipe use this trick : https://gist.github.com/fujin/1713157 
default['apache']['cq_dispatcher_httpd_config_file_path']  = File.join(node['apache']['conf_dir'], '/cq_dispatcher.httpd.conf')
default['apache']['cq_dispatcher_module_config_file_path'] = File.join(node['apache']['conf_dir'], '/cq_dispatcher.any')


# cq dispatcher specific attributes  
default['apache']['cq_dispatcher_log_file_path'] = File.join(node['apache']['log_dir'], '/dispatcher_log')
# DispatcherLogLevel level:
# 0 - Errors
# 1 - Warnings
# 2 - Infos
# 3 - Debug  
default['apache']['cq_dispatcher_log_level'] = 3  

  # DispatcherNoServerHeader  Defines the Server Header to be used:
# undefined or 0 - the HTTP server header contains the AEM version.
# 1 - the Apache server header is used.
default['apache']['cq_dispatcher_no_server_header'] = 0 
# DispatcherDeclineRoot Defines whether to decline requests to the root '/':
# 0 - accept requests to /
# 1 - requests to / are not handled by the dispatcher; use mod_alias for the correct mapping. 
default['apache']['cq_dispatcher_decline_root'] = 0   
# DispatcherUseProcessedURL Defines whether to use pre-processed URLs for all further processing by Dispatcher:
# 0 - use the original URL passed to the web server.
# 1 - the dispatcher uses the URL already processed by the handlers that precede the dispatcher (i.e. mod_rewrite) instead of the original URL passed to the web server.
default['apache']['cq_dispatcher_use_processed_url'] = 0  
# DispatcherPassError
# Defines how to support error codes for ErrorDocument handling:
# 0 - the dispatcher spools all error responses to the client.
# 1 - the dispatcher does not spool an error response to the client (where the status code is greater or equal than 400), but passes the status code to Apache, which e.g. allows an ErrorDocument directive to process such a status code.
default['apache']['cq_dispatcher_pass_error'] = 0 



