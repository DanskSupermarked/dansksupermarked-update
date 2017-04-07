# Update with Puppet

Would like to know which packages should be updated on a node?

Would like that list of packages to be injected in your Puppet code?

## How it Works
The module will help you configure and schedule [update-with-puppet](https://github.com/DanskSupermarked/update-with-puppet).

The job will fetch from the package provider the updates available for the specified package repositories.
A list of [Puppet Package](https://docs.puppet.com/puppet/latest/type.html#package) resource will be generated (For now as Hiera JSON).
This list can be committed to a GIT repository where your Puppet configuration is.
You're then free to have those Package resources updated by Puppet.

## Use Case
A [CRON](https://docs.puppet.com/puppet/latest/type.html#cron) job will collect a list of packages to be updated.
Then create a GIT PR to be reviewed, eventually edited, and finally merged in your Puppet configuration to have the packages updated during the next Puppet run.

## OS Support
- RPM based Linux: RHEL, Centos, Scientific, older Fedora,...
- DNF based Linux: newer Fedora.

## Repository Support
- GIT.
- BitBucket API for pull request creation.


## TODO
- Added class param doc.
- Add Hiera configuration example.

#### Copyright

Copyright 2017 [Dansk Supermarked Group](https://dansksupermarked.com/) and released under the terms of the [GPL version 3 license](https://www.gnu.org/licenses/gpl-3.0-standalone.html).
