include_recipe 'chef-vault'

bag = chef_vault_item('splunk', 'dev')

user = bag['user']
pw = bag['password']

template "#{splunk_home}/etc/system/local/user-seed.conf" do
  source 'user-seed.conf.erb'
  mode 0600
  owner 'root'
  group 'root'
  variables(
    admin_username: user,
    admin_password: pw
  )
  sensitive true
end

execute "#{splunk_cmd} enable boot-start --accept-license --answer-yes" do
  not_if { File.exist? "#{splunk_home}/etc/passwd" }
end

service 'splunk' do
  action :restart
end
