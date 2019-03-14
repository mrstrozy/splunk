#
# Cookbook:: splunk-cookbook
# Recipe:: install_splunk_server.rb
#
# Copyright:: 2019, The Authors, All Rights Reserved.
#
#
install_splunk "#{node['splunk']['download_url']}"
