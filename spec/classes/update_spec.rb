require 'spec_helper'

describe 'update' do

  context 'without Python lib deps for RedHat 6' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystemmajrelease => '6'} }
    let(:params) { { 'manage_python_deps' => false } }
    it { should contain_file('/usr/local/bin/send_pull_request.py') }
    it { should contain_file('/usr/local/bin/generate_list.py') }
    it { should contain_file('/usr/local/bin/update_context.py') }
    it { should contain_file('/etc/update-with-puppet.conf') }
    it { should contain_package('git') }
  end

  context 'without Python lib deps for RedHat 7' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystemmajrelease => '7'} }
    let(:params) { { 'manage_python_deps' => false } }
    it { should contain_file('/usr/local/bin/send_pull_request.py') }
    it { should contain_file('/usr/local/bin/generate_list.py') }
    it { should contain_file('/usr/local/bin/update_context.py') }
    it { should contain_file('/etc/update-with-puppet.conf') }
    it { should contain_package('git') }
  end

end
