
# typically in your wrapper cookbook, you'll override attributes to point to jdk and aem binaries
#node.default['aem']['jar_url'] = 'aem-binaries-url'
#node.default['java']['jdk_url'] = 'jdk-binaries-url' 
#node.default['java']['jdk_version'] = '1.6.0_45'
# you will also need to stuff your aem license in a data bags (using chef-vault)
  
node.default['aem']['mode'] = 'publish'
node.default['aem']['port'] = '4503'
node.default['aem']['ldap']['enabled'] = false

include_recipe 'aaem::default'
