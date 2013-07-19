default['nad']['port'] = "2609"
default['nad']['autofs']['shares'] = ["/net/filer/export/share0", "/net/filer/export/share1"]
default['nad']['path'] = "/opt/circonus"

case node['platform']
when "ubuntu", "debian"
  default['nad']['man_path'] = "/usr/share/man"
when "smartos", "solaris2"
  default['nad']['man_path'] = "/opt/local/man"
when "smartos"
  default['nad']['env_path'] = "/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin"
end
