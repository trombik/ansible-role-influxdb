require "spec_helper"
require "serverspec"

package = "influxdb"
service = "influxdb"
config  = "/etc/influxdb/influxdb.conf"
user    = "influxdb"
group   = "influxdb"
ports   = [PORTS]
log_dir = "/var/log/influxdb"
db_dir  = "/var/lib/influxdb"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/influxdb.conf"
  db_dir = "/var/db/influxdb"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("influxdb") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/influxdb") do
    it { should be_file }
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
