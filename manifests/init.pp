# Class: update
# ===========================
#
# The module will help you configure and schedule update-with-puppet.
#
# Parameters:
#
# [*bundle_dep*]
#   If packages meant to be updated at once (such as -lib) should be
#   bundled into Exec resources to succesfully update groups.
#   These Exec resources will be created under a hiera key 'execs'.
#
# [*conf_folder*]
#   Where the INI configuration file managed by this module will be placed.
#
# [*cron_hour*]
#   The hour at which the CRON job will be scheduled.
#
# [*cron_monthday*]
#   The day of the month (1-31) at which the CRON job will be scheduled.
#
# [*dest_branch*]
#   The branch into which the PR should set to merge.
#   By default set to the $::environment Fact value (as expected by r10k).
#
# [*file_src_base_uri*]
#   The location of the Python files of update-with-puppet.
#   The default https:// location requires at Puppet 4.4.
#
# [*file_replace*]
#   If the Python files on a node should be replaced by a newer file from the source.
#
# [*generate_pr*]
#   If a pull request should be generated in case one with the same 'pr_title'
#   doesn't already exists in the GIT repository.
#
# [*git_account_name*]
#   The name of the GIT account/tenant.
#
# [*git_email*]
#   The email address of the GIT user.
#
# [*git_package_ensure*]
#   The 'ensure' value of the package resource for 'git'.
#   Used in combination with 'manage_git_package'.
#
# [*git_password*]
#   The password of the GIT account.
#
# [*git_repo_name*]
#   The name of the GIT repository where the resources should be committed to.
#
# [*git_user*]
#   The GIT user.
#
# [*git_username*]
#   The username of the GIT account. Will be shown in GIT commit history.
#
# [*hiera_file*]
#   The name of the Hiera file where the Package resources will be listed.
#
# [*hiera_folder*]
#   The folder in the GIT repository where the Hiera files should be created.
#
# [*hiera_pkg_root_key*]
#   The Hiera key under which the Package resources will be written.
#   Should be used in Puppet to lookup and create resources.
#
# [*install_from_cache*]
#   Pass to the Package provider the option to force package install from
#   already downloaded packages in cache.
#
# [*manage_git_package*]
#   Choose if the 'git' package should be installed.
#   If set to false, ensure a git client is available in your $PATH.
#
# [*manage_python_deps*]
#   Install the two Python libraries needed. One is not provided by a main OS repository.
#   The EPEL repository will be needed, or set to false install them with pip.
#
# [*merge_resources*]
#   Merge existing Package resources in the same Hiera file with new updates found.
#
# [*proxy*]
#   Specify some HTTP proxy if needed to reach the GIT repository.
#
# [*pr_title*]
#   The title of the pull request. If using environment per branch structure,
#   use a specific value in the title to have one PR per environment lke the default does.
#
# [*repo_filter*]
#   A comma separated list of Yum repository to search for available updates.
#   Default: the main RHEL repository for $::operatingsystemmajrelease.
#
# [*repo_in_resource*]
#   If the repository providing a package should be the only enabled repository
#   passed as an option to the Package provider.
#
# [*require_repo*]
#   Add to the Package resource a require => Yumrepo[] for the providing repository.
#
# [*save_hiera*]
#   If the list of available packages for updates should be
#   written to a Hiera file.
#
# [*script_path*]
#   The path where the Python files will be placed.
#
# [*src_branch*]
#   The GIT source branch to be used by the newly created branch.
#
# [*working_branch*]
#   The GIT branch to which new resources will be committed to and used for the PR.
#
# [*working_dir*]
#   The local folder where the GIT src branch will be pulled and new content
#   placed before being committed.
#
# [*wrap_resources*]
#   Place Package resources under a common Hiera key to use for lookup.
#   Used in combination with 'hiera_pkg_root_key'.
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
  $file_src_base_uri  = 'https://raw.githubusercontent.com/DanskSupermarked/update-with-puppet/master/app',
  $file_replace       = false,
  $generate_pr        = false,
  $git_account_name   = '',
  $git_email          = '',
  $git_package_ensure = 'present',
  $git_password       = '',
  $git_repo_name      = '',
  $git_user           = '',
  $git_username       = '',
  $hiera_file         = "common_${::osfamily}_${::operatingsystemrelease}.json",
  $hiera_folder       = 'hiera',
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
  $working_dir        = '/tmp/update',
  $wrap_resources     = true
) {

  $git_api_url = "https://api.bitbucket.org/2.0/repositories/${git_account_name}/${git_repo_name}/pullrequests"
  $git_url     = "https://bitbucket.org/${git_account_name}/${git_repo_name}/"

  cron {'pkg_update_check':
    command  => "${script_path}/update_context.py -c ${conf_folder}/update-with-puppet.conf",
    hour     => $cron_hour,
    minute   => fqdn_rand(60),
    monthday => $cron_monthday,
    require  => File['update_context.py'],
  }

  file {'send_pull_request.py':
    mode    => '0700',
    path    => "${script_path}/send_pull_request.py",
    replace => $file_replace,
    source  => "${file_src_base_uri}/send_pull_request.py",
  }

  file {'generate_list.py':
    mode    => '0700',
    path    => "${script_path}/generate_list.py",
    replace => $file_replace,
    source  => "${file_src_base_uri}/generate_list.py",
  }

  file {'update_context.py':
    mode    => '0700',
    path    => "${script_path}/update_context.py",
    replace => $file_replace,
    require => [File['send_pull_request.py'], File['generate_list.py'], File[$working_dir], File['update-with-puppet.conf']],
    source  => "${file_src_base_uri}/update_context.py",
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
