#
# Cookbook Name:: aem
# Recipe:: start
#
# this recipe will insure cq is started
# 

ruby_block 'block_until_cq_operational' do
  block do
    Chef::Log.info 'Waiting until CQ is listening on port '+node['aem']['port']
    until CQHelper.service_listening?(node['aem']['port'])
      sleep 1
      Chef::Log.info('.')
    end

    Chef::Log.info 'Waiting until the CQ default page is responding'
    test_url = URI.parse(node['aem']['url'])
    until CQHelper.endpoint_responding?(test_url)
      sleep 1
      Chef::Log.info('.')
    end
  end
  action :nothing
end

log 'ensure_cq_is_running' do
  notifies :start, 'service[aem]', :immediately
  notifies :create, 'ruby_block[block_until_cq_operational]', :immediately
end