# == Class: awstats
#
class awstats(
  $config_dir_purge = false,
  $enable_plugins   = [],
  $crontab_manage   = false,
  $crontab_minute   = '*/10',
  $crontab_hour     = absent,
  $crontab_month    = absent,
  $crontab_monthday = absent,
  $crontab_weekday  = absent,
  $crontab_buildstatic = false,
  $crontab_buildstatic_minute = '10',
  $crontab_buildstatic_hour = '03',
  $crontab_buildstatic_month = absent,
  $crontab_buildstatic_monthday = absent,
  $crontab_buildstatic_weekday = absent,
) inherits ::awstats::params {
  validate_bool($config_dir_purge)
  validate_bool($crontab_manage)
  validate_bool($crontab_buildstatic)
  validate_array($enable_plugins)

  package{ $::awstats::params::package_name: } ->
  file { $::awstats::params::config_dir_path:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => $config_dir_purge,
  }

  if size($enable_plugins) > 0 {
    $load = prefix(downcase($enable_plugins), '::awstats::plugin::')
    include $load

    anchor { 'awstats::begin': } ->
      Class[$load] ->
        anchor { 'awstats::end': }
  }

  if $::awstats::params::crontab_path {
    file { $::awstats::params::crontab_path:
      ensure =>  'file',
      owner  =>  'root',
      group  =>  'root',
      mode   =>  '0755',
      purge  =>  $crontab_manage,
    }
    if $crontab_manage {
      cron { 'awstats':
        ensure   =>  present,
        command  =>  $::awstats::params::awstats_update_command,
        user     =>  $::awstats::params::awstats_user,
        minute   =>  $crontab_minute,
        hour     =>  $crontab_hour,
        month    =>  $crontab_month,
        monthday =>  $crontab_monthday,
        weekday  =>  $crontab_weekday,
      }
      cron { 'awstats_buildstatic':
        ensure   =>  $crontab_buildstatic,
        command  =>  $::awstats::params::awstats_buildstatic_command,
        user     =>  $::awstats::params::awstats_user,
        minute   =>  $crontab_buildstatic_minute,
        hour     =>  $crontab_buildstatic_hour,
        month    =>  $crontab_buildstatic_month,
        monthday =>  $crontab_buildstatic_monthday,
        weekday  =>  $crontab_buildstatic_weekday,
      }
    }
  } else {
    if $crontab_manage or $crontab_buildstatic {
      fail("Managing crontab is not supported on ${::operatingsystem} / ${::operatingsystemmajrelease}")
    }
  }
}
