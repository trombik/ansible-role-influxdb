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
admin_user = "admin"
admin_password = "PassWord"
log_dir = "/var/log/influxdb"

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
db_users = [
  { name: "foo", read: :success, write: :success, password: "PassWord" },
  { name: "write_only", read: :fail, write: :success, password: "write_only" },
  { name: "read_only", read: :success, write: :fail, password: "read_only" },
  { name: "none", read: :fail, write: :fail, password: "none" }
]
test_database = "mydatabase"
influx_command = "influx -ssl -unsafeSsl"
tls_key = "#{config_dir}/tls/influxdb.key"
tls_pub = "#{config_dir}/tls/influxdb.pem"

case os[:family]
when "ubuntu"
  describe package "python-pip" do
    if os[:release].to_f < 18.04
      it { should be_installed }
    else
      it { should_not be_installed }
    end
  end
end

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

describe file tls_pub do
  it { should exist }
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into group }
  its(:content) { should match(/^-----BEGIN CERTIFICATE-----$/) }
end

describe file tls_key do
  it { should exist }
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into group }
  its(:content) { should match(/^-----BEGIN PRIVATE KEY-----$/) }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 750 }
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

describe command "#{influx_command} -username #{admin_user} -password #{admin_password} -execute 'show databases'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^#{test_database}$/) }
end

describe command "#{influx_command} -username #{admin_user} -password #{admin_password} -execute 'show users'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  db_users.map { |u| u[:name] }.each do |name|
    its(:stdout) { should match(/^#{name}\s+false$/) }
  end
  its(:stdout) { should_not match(/^bar\s+/) }
  its(:stdout) { should match(/^admin\s+true$/) }
end

db_users.each do |u|
  describe command "#{influx_command} -username #{u[:name]} -password #{u[:password]} -database #{test_database} -execute 'INSERT cpu,host=serverA,region=us_west value=0.64'" do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should eq "" }
    case u[:write]
    when :success
      its(:stdout) { should eq "" }
    when :fail
      its(:stdout) { should match(/user is not authorized to write to database/) }
    else
      raise "unknown assert keyword `#{u[:write]}`"
    end
  end
end

db_users.each do |u|
  describe command "#{influx_command} -username #{u[:name]} -password #{u[:password]} -database #{test_database} -execute 'SELECT host, region, value FROM cpu'" do
    case u[:read]
    when :success
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq "" }
      its(:stdout) { should match(/^\d+\s+serverA\s+us_west\s+0\.64$/) }
    when :fail
      its(:exit_status) { should eq 1 }
      its(:stderr) { should match(/not authorized to execute statement/) }
      its(:stdout) { should match(/not authorized to execute statement/) }
    else
      raise "unknown assert keyword `#{u[:read]}`"
    end
  end
end

describe file("#{log_dir}/access.log") do
  it { should exist }
  it { should be_file }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/^127\.0\.0\.1 - write_only/) }
end
