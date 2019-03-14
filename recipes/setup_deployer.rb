include_recipe 'chef-vault'

bag = chef_vault_item('splunk', 'dev')
symmKey = bag['pass4SymmKey']
shcluster_label = node['splunk']['shclustering']['cluster_label']

cmd = "echo -e \"\n[shclustering]\npass4SymmKey = #{symmKey}\nshcluster_label"\
      " = #{shcluster_label}\n\" >> #{splunk_home}/etc/system/local/server.conf"

unless ::File.exist?("#{splunk_home}/etc/.deployer_setup")
  execute 'enable_deployer' do
    command cmd
    notifies :restart, 'service[splunk]', :delayed
  end
end

file "#{splunk_home}/etc/.deployer_setup" do
  content 'deployer has been setup\n'
  owner 'root'
  group 'root'
  mode '0600'
end
