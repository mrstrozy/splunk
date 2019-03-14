resource_name :install_splunk
property :splunk_url, String, name_property: true

action :install do
  remote_file '/tmp/crap.rpm' do
    source new_resource.splunk_url
    action :create_if_missing
  end

  rpm_package '/tmp/crap.rpm' do
    action :install
  end

  template '/etc/init.d/splunk' do
    source 'init.d/splunk.erb'
    mode '0755'
    owner 'root'
    group 'root'
    variables(
      splunk_home: splunk_home
    )
  end

  service 'splunk' do
    supports status: true, restart: true
    action :enable
  end

  if node['splunk']['start_on_install']
    execute "#{splunk_cmd} start --no-prompt --answer-yes" do
    end
  end
end
