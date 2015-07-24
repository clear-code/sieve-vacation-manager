#
# Cookbook Name:: mariadb
# Recipe:: default
#
# Copyright (C) 2015 Kenji Okimoto
#
# All rights reserved - Do Not Redistribute
#

[
  "centos-release-SCL",
  "mariadb55",
  "mysql-devel",
  "mysql-libs",
  "gcc",
  "git",
  "rpm-build",
].each do |name|
  package name
end

service "mariadb55-mysqld" do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

bash "mysql_secure_installation" do
  user "root"
  base_dir = "/opt/rh/mariadb55/root/"
  bin_dir = File.join(base_dir, "/usr/bin")
  mysqladmin = File.join(bin_dir, "mysqladmin")
  mysql = File.join(bin_dir, "mysql")
  code <<-CODE
    #{mysqladmin} -u root password "root"
    #{mysql} -v -u root -proot -e "DELETE FROM mysql.user WHERE User='';"
    #{mysql} -v -u root -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    #{mysql} -v -u root -proot -e "DROP DATABASE IF EXISTS test;"
    #{mysql} -v -u root -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    #{mysql} -v -u root -proot -e "FLUSH PRIVILEGES;"
  CODE
end
