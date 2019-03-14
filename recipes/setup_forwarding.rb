include_recipe 'chef-vault'

bag = chef_vault_item('splunk', 'dev')
symmKey = bag['pass4SymmKey']
fwd_settings = node['splunk']['forwarding']
polling_rate = fwd_settings['polling_rate']
indexerWeightByDiskCapacity = fwd_settings['indexerWeightByDiskCapacity']
index_receiving_port = fwd_settings['index_receiving_port']
master_uri = splunk_master['ipaddress']

begin
  resources('service[splunk]')
rescue Chef::Exceptions::ResourceNotFound
  service 'splunk'
end

if node['roles'].include? 'master'
  cmd = "echo -e \"[indexer_discovery]\n"\
        "pass4SymmKey = #{symmKey}\n"\
        "polling_rate = #{polling_rate}\n"\
        "indexerWeightByDiskCapacity = #{indexerWeightByDiskCapacity}\n\""\
        " >> #{splunk_home}/etc/system/local/server.conf"
elsif node['roles'].include? 'indexer'
  cmd = "echo -e \"\n[splunktcp://#{index_receiving_port}]\ndisabled = 0\n\""\
        " >> #{splunk_home}/etc/system/local/inputs.conf"
elsif node['roles'].include? 'forwarder'
  cmd = "echo -e \"[indexer_discovery:master1]\n"\
        "pass4SymmKey = #{symmKey}\n"\
        "master_uri = https://#{master_uri}:8089\n"\
        "\n"\
        "[tcpout:group1]\n"\
        "indexerDiscovery = master1\n"\
        "\n"\
        "[tcpout]\n"\
        "defaultGroup = group1\n\""\
        " >> #{splunk_home}/etc/system/local/outputs.conf"
else
  Chef::Log.error('Node is not part of a valid role for this recipe.')
  return
end

execute 'configure_forwarding' do
  command cmd
  not_if { ::File.exist?("#{splunk_home}/etc/.forwarding_setup") }
  notifies :restart, 'service[splunk]', :delayed
end

file "#{splunk_home}/etc/.forwarding_setup" do
  content 'forwarding has been setup\n'
  owner 'root'
  group 'root'
  mode '0600'
end
