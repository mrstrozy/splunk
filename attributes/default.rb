# Splunk install link config
default['splunk']['download_base'] = 'http://download.splunk.com/products'
default['splunk']['version'] = '7.1.1'
default['splunk']['type'] = 'server'
default['splunk']['platform'] = 'linux'
default['splunk']['start_on_install'] = false

# For testing purposes
default['chef-vault']['databag_fallback'] = true

# Splunk Clustering
default['splunk']['clustering'] = {
  'cluster_label' => 'ops_fun',
  'mode' => 'master',
  'replication_port' => '9887',
  # Must have 3 or more indexers/search heads
  'replication_factor' => 3,
  'search_factor' => 2
}
  
# Splunk Search Head Clustering
default['splunk']['shclustering'] = {
  'cluster_label' => 'shops_fun',
  'replication_port' => '9900',
  'replication_factor' => 3,
  'is_captain' => false
}

# Splunk Forwarding
default['splunk']['forwarding'] = {
  'polling_rate' => 40000,
  'indexerWeightByDiskCapacity' => false,
  'index_receiving_port' => 9997
}

case node['platform_family']
when 'rhel', 'amazon'
  if node['kernel']['machine'] == 'x86_64'
    filename = if node['splunk']['type'] == 'server'
                 'splunk-7.1.1-8f0ead9ec3db-linux-2.6-x86_64.rpm'
               elsif node['splunk']['type'] == 'forwarder'
                 'splunkforwarder-7.1.1-8f0ead9ec3db-linux-2.6-x86_64.rpm'
               else
                 Chef::Application.fatal!('Legal types are: server, forwarder')
               end
  else
    Chef::Application.fatal!('Only x86_64 machines are supported')
  end

  type = node['splunk']['type'] == 'server' ? 'splunk' : 'universalforwarder'
  default['splunk']['download_url'] = "#{node['splunk']['download_base']}/"\
                                      "#{type}/releases/"\
                                      "#{node['splunk']['version']}/"\
                                      "#{node['splunk']['platform']}/"\
                                      "#{filename}"
else
  Chef::Application.fatal!('Only RHEL machines are supported')
end
