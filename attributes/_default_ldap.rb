################################
## default ldap related attributed
################################ 
  
# ldap attribute if node['aem']['ldap']['enabled'] is set to true, ldap authentication will be set
# this recipe will hook the cq server with an AD conf sample (templates/ldap_AD.conf.erb)
# where the credentials are protected with chef-vault
#default['aem']['ldap']['enabled']=true
  
default['aem']['ldap']['template']   = 'ldap.conf.erb' 

default['aem']['ldap']['tokenExpiration']  = '3600000' 
# CQ cred cache in sec (12 hours)  
default['aem']['ldap']['cache.expiration'] = '43200' 
# CQ cred cache size in entries
default['aem']['ldap']['cache.maxsize']    = '1500';  
  
default['aem']['ldap']['host']            = 'your-ad-server-fqdn'
default['aem']['ldap']['secure']          = 'false'
default['aem']['ldap']['port']            = '389'  

# we will encrypt using chef-vault the remaining secret ldap conf, for that issue the following command:
# here are the expected databags, type, name, and properties:
# the chef-vault/encrypted data bag type name  
default['aem']['ldap']['vault_conf_type'] = 'ldap_conf'
# the chef-vault/encrypted data bag name 
default['aem']['ldap']['vault_conf'] = 'ldap_test_conf'     
# the chef-vault/encrypted data bag properties
default['aem']['ldap']['vault_authDn']    = 'authDn'
default['aem']['ldap']['vault_authPw']    = 'authPw'
default['aem']['ldap']['vault_userRoot']  = 'userRoot'
default['aem']['ldap']['vault_groupRoot'] = 'groupRoot'
default['aem']['ldap']['vault_userFilter']= 'userFilter'

 