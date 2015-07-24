#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "dovecot"

user "vmail" do
  comment "Virtual mail user"
  uid 5000
  shell "/bin/false"
  home "/var/vmail"
  system true
  notifies :create, "group[vmail]", :immediately
  subscribes :create, "user[dovecot]", :immediately
end

group "vmail" do
  gid 5000
  members ["vmail"]
  system true
  append true
  action :nothing
end

virtual_users = ""
ruby_block "dovecot-virtual-users" do
  block do
    node["dovecot"]["virtual_users"].each do |user|
      name = user["name"]
      domain = user["domain"]
      password = user["password"] || "test"
      uid = user["uid"] || 5000
      gid = user["gid"] || 5000
      home = "/var/vmail/#{domain}/#{name}"
      doveadm = Mixlib::ShellOut.new("doveadm pw -s CRYPT -p #{password}")
      doveadm.run_command
      virtual_users << "#{name}@#{domain}:#{doveadm.stdout.chomp}:#{uid}:#{gid}::#{home}\n"
      Chef::Log.info("dovecot[virtual_users] #{name}@#{domain}")
      File.write("/etc/dovecot/users", virtual_users)
    end
  end
  action :nothing
end

file "/etc/dovecot/users" do
  owner "dovecot"
  group "dovecot"
  mode "0644"
  content virtual_users
  action :create
  notifies :run, "ruby_block[dovecot-virtual-users]", :immediately
end

directory node["postfix"]["main"]["virtual_mailbox_base"] do
  owner "vmail"
  group "vmail"
  mode "0755"
  action :create
end
