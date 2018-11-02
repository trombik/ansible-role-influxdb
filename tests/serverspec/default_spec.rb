require "spec_helper"
require "serverspec"

package = "influxdb"
service = "influxdb"
config_dir = "/etc/influxdb"
config_name = "influxdb.conf"
user    = "influxdb"
group   = "influxdb"
ports   = [8088, 8086]
db_dir  = "/var/lib/influxdb"
default_user = "root"
default_group = "root"

case os[:family]
when "freebsd"
  service = "influxd"
  user = "influxd"
  group = "influxd"
  config_dir = "/usr/local/etc"
  config_name = "influxd.conf"
  db_dir = "/var/db/influxdb"
  default_group = "wheel"
when "openbsd"
  user = "_influx"
  group = "_influx"
  db_dir = "/var/influxdb"
end
config = "#{config_dir}/#{config_name}"

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should exist }
  it { should be_file }
  it { should be_mode os[:family] == "openbsd" ? 640 : 644 }
  it { should be_owned_by os[:family] == "openbsd" ? user : default_user }
  it { should be_grouped_into os[:family] == "openbsd" ? group : default_group }
  its(:content) { should match(/^# Managed by ansible$/) }
  its(:content) { should match(/^reporting-disabled = true$/) }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

%w[data meta wal].each do |d|
  describe file "#{db_dir}/#{d}" do
    it { should exist }
    it { should be_directory }
    it { should be_mode d == "wal" ? 700 : 755 }
    it { should be_owned_by user }
    it { should be_grouped_into group }
  end
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/#{service}") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^# Managed by ansible$/) }
    its(:content) { should match(/^influxd_conf="#{config}"$/) }
    its(:content) { should match(/^influxd_user="#{user}"$/) }
    its(:content) { should match(/^influxd_group="#{group}"$/) }
    its(:content) { should match(/^influxd_flags=""$/) }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command "influx -execute 'show databases'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^name: databases\nname\n\----\n_internal$/) }
end
