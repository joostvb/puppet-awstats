# == Class: awstats::params
#
# This class should be considered private
#
class awstats::params {
  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '6', '7': {
          $package_name                 = 'awstats'
          $config_dir_path              = '/etc/awstats'
          $default_template             = "${module_name}/awstats.conf.erb"
          $crontab_path                 = undef
          $awstats_update_command       = undef
          $awstats_buildstatic_command  = undef
        }
        default: {
          fail("Module ${module_name} is not supported on operatingsystemmajrelease ${::operatingsystemmajrelease}") # lint:ignore:80chars
        }
      }
    }
    'Debian': {
      case $::operatingsystemmajrelease {
        '8': {
          $package_name                 = 'awstats'
          $config_dir_path              = '/etc/awstats'
          $default_template             = "${module_name}/awstats.conf.erb"
          $crontab_path                 = '/etc/cron.d/awstats'
          $awstats_update_command       = '[ -x /usr/share/awstats/tools/update.sh ] && /usr/share/awstats/tools/update.sh'
          $awstats_buildstatic_command  = '[ -x /usr/share/awstats/tools/buildstatic.sh ] && /usr/share/awstats/tools/buildstatic.sh'
        }
        default: {
          fail("Module ${module_name} is not supported on operatingsystemmajrelease ${::operatingsystemmajrelease}") # lint:ignore:80chars
        }
      }
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
