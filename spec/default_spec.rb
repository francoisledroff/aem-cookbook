require 'spec_helper'
require 'chef-vault'

describe 'aem::default' do
  
  let(:aem_user)  { 'aem_user' }
  let(:aem_group) { 'aem_group' }
  
  let(:chef_run) do 
    ChefSpec::Runner.new do |node|
      # we don't want to test the ldap sub recipe here
      node.set['aem']['ldap']['enabled'] = false
      node.set['aem']['service']['email_notification'] = true
      node.set['aem']['user'] = aem_user
      node.set['aem']['group'] = aem_group
    end.converge(described_recipe)
  end
  
  # we need to mock the chef-vault item: by stubbing the load function
  # inspired from https://github.com/sethvargo/chefspec/issues/249  
  before do
    ChefVault::Item.stub(:load).with('license', 'aem_license').and_return({
      'license.properties' => 'fake_license',
      'bla' => 'bla'
    })
  end
    
  it 'smoke_test' do
    expect(chef_run).to install_package('mailx')
    expect(chef_run).to create_group(aem_group)
    expect(chef_run).to create_user(aem_user)
    expect(chef_run).to enable_service('aem')
  end
    
end