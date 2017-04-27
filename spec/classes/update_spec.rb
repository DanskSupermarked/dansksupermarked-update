require 'spec_helper'

describe 'update' do

  context 'without Python lib deps for RedHat 6' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystemmajrelease => '6', :operatingsystemrelease => '6.9'} }
    let(:params) { { 'git_repo_name' => 'my_git_repo', 'manage_python_deps' => false } }
    it { should contain_cron('pkg_update_check').with_command('/usr/local/bin/update_context.py -c /etc/update-with-puppet/update-with-puppet.conf') }
    it { should contain_file('send_pull_request.py').with_path('/usr/local/bin/send_pull_request.py') }
    it { should contain_file('generate_list.py').with_path('/usr/local/bin/generate_list.py') }
    it { should contain_file('update_context.py').with_path('/usr/local/bin/update_context.py') }
    it { should contain_file('package_bundle.json').with_path('/etc/update-with-puppet/package_bundle.json') }
    it { should contain_file('update-with-puppet.conf').with_path('/etc/update-with-puppet/update-with-puppet.conf') }
    it { should contain_file('/tmp/update').with_path('/tmp/update') }
    it { should contain_file('/tmp/update/my_git_repo').with_path('/tmp/update/my_git_repo') }
    it { should contain_package('git') }
  end

  context 'without Python lib deps for RedHat 7' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystemmajrelease => '7', :operatingsystemrelease => '7.3'} }
    let(:params) { { 'git_repo_name' => 'my_git_repo', 'manage_python_deps' => false } }
    it { should contain_cron('pkg_update_check').with_command('/usr/local/bin/update_context.py -c /etc/update-with-puppet/update-with-puppet.conf') }
    it { should contain_file('send_pull_request.py').with_path('/usr/local/bin/send_pull_request.py') }
    it { should contain_file('generate_list.py').with_path('/usr/local/bin/generate_list.py') }
    it { should contain_file('update_context.py').with_path('/usr/local/bin/update_context.py') }
    it { should contain_file('package_bundle.json').with_path('/etc/update-with-puppet/package_bundle.json') }
    it { should contain_file('update-with-puppet.conf').with_path('/etc/update-with-puppet/update-with-puppet.conf') }
    it { should contain_file('/tmp/update').with_path('/tmp/update') }
    it { should contain_file('/tmp/update/my_git_repo').with_path('/tmp/update/my_git_repo') }
    it { should contain_package('git') }
  end

  context 'without managing dependencies for RedHat 6' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystemmajrelease => '6', :operatingsystemrelease => '6.9'} }
    let(:params) { { 'manage_git_package' => false, 'manage_python_deps' => false } }
    it { should_not contain_package('git') }
    it { should_not contain_package('python-argparse') }
    it { should_not contain_package('python-configparser') }
  end

  context 'without managing dependencies for RedHat 7' do
    let(:facts) { {:osfamily => 'RedHat', :operatingsystemmajrelease => '7', :operatingsystemrelease => '7.3'} }
    let(:params) { { 'manage_git_package' => false, 'manage_python_deps' => false } }
    it { should_not contain_package('git') }
    it { should_not contain_package('python-argparse') }
    it { should_not contain_package('python-configparser') }
  end

end
