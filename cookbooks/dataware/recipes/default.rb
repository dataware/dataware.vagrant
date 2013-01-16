bash "install_dataware" do
  code <<-EOH
    cd /vagrant
    sudo dpkg -i python-dataware-resource.deb
  EOH
end
