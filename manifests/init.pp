# Class: update
# ===========================
#
# Authors
# -------
#
# Benjamin Merot
#
# Copyright
# ---------
#
# Copyright 2017 Dansk Supermarked Group.
#
class update(
  $bundle_dep         = true,
  $conf_folder        = '/etc',
  $cron_hour          = 6,
  $cron_monthday      = 1,
  $dest_branch        = $::environment,
  $git_account_name   = '',
  $git_email          = '',
  $git_package_ensure = 'present',
  $git_password       = '',
  $git_repo_name      = '',
  $git_user           = '',
  $git_username       = '',
  $hiera_file         = "common_${::osfamily}_${::operatingsystemrelease}.json",
  $hiera_pkg_root_key = 'packages',
  $install_from_cache = false,
  $manage_git_package = true,
  $manage_python_deps = true,
  $merge_resources    = true,
  $pr_description     = 'OS package update',
  $pr_reviewers       = '',
  $pr_title           = "Scheduled OS update for ${::environment}",
  $proxy              = '',
  $repo_filter        = "rhel-${::operatingsystemmajrelease}-server-rpms",
  $repo_in_resource   = false,
  $require_repo       = false,
  $save_hiera         = true,
  $script_path        = '/usr/local/bin',
  $src_branch         = $::environment,
  $working_branch     = '',
  $working_dir        = '/tmp/update_machine',
  $wrap_resources     = true
) {

  $git_api_url = "https://api.bitbucket.org/2.0/repositories/${git_account_name}/${git_repo_name}/pullrequests"
  $git_url     = "https://bitbucket.org/${git_account_name}/${git_repo_name}/"

  cron {'pkg_update_check':
    command  => "${script_path}/update_context.py -c ${conf_folder}/update-with-puppet.conf",
    hour     => $cron_hour,
    minute   => fqdn_rand(60),
    monthday => $cron_monthday,
    require  => File['update_context'],
  }

  file {'send_pull_request':
    mode    => '0700',
    path    => "${script_path}/send_pull_request.py",
    replace => false,
    source  => 'https://raw.githubusercontent.com/DanskSupermarked/update-with-puppet/master/app/send_pull_request.py',
  }

  file {'generate_list':
    mode    => '0700',
    path    => "${script_path}/generate_list.py"
    replace => false,
    source  => 'https://raw.githubusercontent.com/DanskSupermarked/update-with-puppet/master/app/generate_list.py',
  }

  file {'update_context':
    content => file('update/update_context.py'),
    mode    => '0700',
    path    => "${script_path}/update_context.py",
    replace => false,
    require => [File['send_pull_request'], File['generate_list'], File[$working_dir], File['update-with-puppet.conf']],
    source  => 'https://raw.githubusercontent.com/DanskSupermarked/update-with-puppet/master/app/update_context.py',

  }

  file {'update-with-puppet.conf':
    content => template('update/update-with-puppet.conf.erb'),
    path    => "${conf_folder}/update-with-puppet.conf",
  }

  file { $working_dir:
    ensure => 'directory',
  }

  file { "${working_dir}/${git_repo_name}":
    ensure  => 'directory',
    require => File[$working_dir],
  }

  if $manage_git_package {
    package {'git':
      ensure => $git_package_ensure,
    }
  }

  if $manage_python_deps and $::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '6') == 0 {
    package {'python-argparse':
      ensure => 'present',
    }
  }

  if $manage_python_deps and $::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '8') == -1 {
    package {'python-configparser':
      ensure  => 'present',
      require => Yumrepo['epel'],
    }
  }

}
