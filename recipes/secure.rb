#
# Cookbook Name:: aem
# Recipe:: secure
#
# Desciption: this recipe will apply some of cq security check list
# cf. http://dev.day.com/docs/en/cq/current/deploying/security_checklist.html 
# 

include_recipe 'chef-vault-util::default'

item = chef_vault_item(node['aem']['vault_accounts'], node['aem']['vault_accounts_cq_admin_item'])
cq_admin_username = item[node['aem']['vault_accounts_username_property']]
cq_admin_password = item[node['aem']['vault_accounts_password_property']]   
log 'the secret accounts credential was fetched from a chef-vault enabled encrypted data_bag for username '+ cq_admin_username do
  level :info
end


ruby_block 'check_and_change_cq_admin_password' do
    block do
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
      Chef::Log.info 'removing geometrix pacakges'
      shell_command = 'curl -u '+ cq_admin_username + ':'+node['aem']['cq_admin_default_password']+' -F rep:password='+ cq_admin_password +' --write-out %{http_code} --connect-timeout 100 --show-error --output /dev/null '+ node['aem']['url'] +'/home/users/a/admin.rw.html'
      command_shell_out = shell_out(shell_command)
      Chef::Log.info 'command triggered : '+ shell_command
      Chef::Log.info 'command output :    '+ command_shell_out.stdout
      
      shell_command = 'curl -u '+ cq_admin_username +':'+ cq_admin_password + ' --write-out %{http_code} --connect-timeout 100  --show-error --output /dev/null '+node['aem']['url']+'/system/console/bundles'
      command_shell_out = shell_out(shell_command)
      # don't log the below unless you have an issue, there is a secret here
      # Chef::Log.info 'command triggered : #{shell_command}'
      Chef::Log.info 'command output :    '+ command_shell_out.stdout
      
      #TODO add some test 
    end
    action :create
end

  
ruby_block 'nuke: uninstall and delete all geometrix pacakges' do
    block do
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
      Chef::Log.info 'removing geometrix pacakges'
      for pkg in node['aem']['cq_geometrixx_pkgs'] 
         for command in node['aem']['package_api_nuke_commands'] 
            shell_command = 'curl -u '+ cq_admin_username +':'+ cq_admin_password+ ' --write-out %{http_code} --connect-timeout 500 --show-error -X POST '+node['aem']['package_api_endpoint']+pkg+command
            command_shell_out = shell_out(shell_command)
            Chef::Log.info 'command triggered : '+ shell_command
            Chef::Log.info 'command output :    '+ command_shell_out.stdout
         end  
      end
      #TODO check somehow that the packages  nuked   
    end
    action :create
end

ruby_block 'disabling a few osgi bundles ' do
    block do
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
      Chef::Log.info 'disabling crxde and webdav'
      for bundle_symbolic_name in node['aem']['disabled_osgi_bundles'] 
         shell_command = 'curl -u '+ cq_admin_username +':'+ cq_admin_password+ ' --write-out %{http_code} --connect-timeout 500 --show-error -F action=stop '+node['aem']['bundle_api_endpoint']+bundle_symbolic_name
         command_shell_out = shell_out(shell_command)
         Chef::Log.info 'command triggered : '+shell_command
         Chef::Log.info 'command output :    '+command_shell_out.stdout
       end 
      #TODO check somehow that the bundles are stopped
    end
    action :create
end