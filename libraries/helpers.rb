def splunk_cmd
  "#{splunk_home}/bin/splunk"
end

def splunk_home
  if node['splunk']['type'] == 'server'
    '/opt/splunk'
  elsif node['splunk']['type'] == 'forwarder'
    '/opt/splunkforwarder'
  end
end

def splunk_master
  search(:node, 'role:master').first
end
