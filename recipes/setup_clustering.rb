include_recipe 'chef-vault'

bag = chef_vault_item('splunk', 'dev')

user = bag['user']
pw = bag['password']
symmKey = bag['pass4SymmKey']
cluster_settings = node['splunk']['clustering']

case cluster_settings['mode']
when 'master'
  cluster_params = '-mode master '\
                   "-replication_factor #{cluster_settings['replication_factor']} "\
                   "-search_factor #{cluster_settings['search_factor']} "\
                   "-cluster_label #{cluster_settings['cluster_label']} "
when 'slave', 'searchhead'
  Chef::Log.error("This is a log entry yay")
  master_node = search(:node, 'role:master').first
  Chef::Log.error("Results from query: #{master_node}")
  Chef::Log.error("Master node name: #{master_node['ipaddress']}")
  cluster_params = "-mode #{cluster_settings['mode']} "\
                   "-master_uri https://#{master_node['ipaddress']}:8089 "\
                   "-replication_port #{cluster_settings['replication_port']} "
end

cluster_params << "-secret #{symmKey} -auth '#{user}:#{pw}'"

execute 'configure_indexer_cluster' do
  command "#{splunk_cmd} edit cluster-config #{cluster_params}"
  not_if { ::File.exist?("#{splunk_home}/etc/.clustering_setup") }
  notifies :restart, 'service[splunk]', :delayed
end

file "#{splunk_home}/etc/.clustering_setup" do
  content 'clustering has been setup\n'
  owner 'root'
  group 'root'
  mode '0600'
end
