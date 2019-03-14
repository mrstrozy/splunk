include_recipe 'chef-vault'

bag = chef_vault_item('splunk', 'dev')

user = bag['user']
pw = bag['password']
symmKey = bag['pass4SymmKey']
shcluster_settings = node['splunk']['shclustering']

master_node = search(:node, 'role:master').first
search_nodes = search(:node, 'role:search')

search_nodes.each do |s|
  Chef::Log.error("Node: #{s['name']}")
end

return

shcluster_nodes = []
search_nodes.each do |sh|
    Chef::Log.error("sh hostname #{sh['ec2']['public_hostname']}")
    Chef::Log.error("node hostname #{node['ec2']['public_hostname']}")
#  if sh['hostname'] != node['hostname']
  if sh['ec2']['public_hostname']  != node['ec2']['public_hostname']
#    shcluster_nodes.push("https://#{sh['hostname']}:8089")
    shcluster_nodes.push("https://#{sh['ec2']['public_hostname']}:8089")
  end
end

cmd = "#{splunk_cmd} init shcluster-config "\
      "-auth #{user}:#{pw} "\
#      "-mgmt_uri https://#{node['hostname']}:8089 "\
      "-mgmt_uri https://#{node['ec2']['public_ipv4']}:8089 "\
      "-replication_port #{shcluster_settings['replication_port']} "\
      "-replication_factor #{shcluster_settings['replication_factor']} "\
      "-conf_deploy_fetch_url https://#{master_node['ipaddress']}:8089 "\
      "-shcluster_label #{shcluster_settings['cluster_label']} "\
      "-secret #{symmKey}"

bootstrap_cmd = "#{splunk_cmd} bootstrap shcluster-captain "\
                "-servers_list #{shcluster_nodes.join(',')} "\
                "-auth #{user}:#{pw}"

unless ::File.exist?("#{splunk_home}/etc/.shclustering_setup")
  execute 'configure_shcluster' do
    command cmd
    notifies :restart, 'service[splunk]'
  end

  if shcluster_settings['is_captain']
    execute 'boostrap captain' do
      command bootstrap_cmd
    end
  end
end

file "#{splunk_home}/etc/.shclustering_setup" do
  content 'clustering has been setup\n'
  owner 'root'
  group 'root'
  mode '0600'
end
