Chef::Log.info('setting proxy!')

proxy = "Acquire::http::Proxy \"http://mainproxy.nottingham.ac.uk:8080\";\n"

file "/etc/apt/apt.conf.d/01proxy" do
  mode 00644
  content proxy 
  action :create
end

Chef::Log.info("proxy has been set!")

execute "update" do
  command "apt-get update"
  action :run
end

