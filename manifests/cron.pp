# == Define: awstats::cron
#
define awstats::cron(
  $crontab_manage   = true,
  $crontab_manage_buildstatic = undef,
  $crontab_update = ['*/10', absent, absent, absent, absent]
  $crontab_buildstatic = ['10', '03', absent, absent, absent]
) {
  validate_bool($crontab_manage)

  include ::awstats::params
  require ::awstats

  if $crontab_manage == false {
    if $crontab_manage_buildstatic == true {
      warning("Adding cron entry for building static pages, but original cron entry was not purged (crontab_manage=false). Possible duplicate cron entries.")
    }
  }

  if $crontab_manage_buildstatic == undef {
    $_crontab_manage_buildstatic = $crontab_manage
  } else {
    $_crontab_manage_buildstatic = $crontab_manage_buildstatic
  }

  $_ensure_crontab_update = $crontab_manage ? {
    'true'  =>  'ensure',
    'false' =>  'absent',
    default =>  'absent',
  }

  $_ensure_crontab_buildstatic = $_crontab_manage_buildstatic ? {
    'true'  =>  'ensure',
    'false' =>  'absent',
    default =>  'absent',
  }

  if $::awstats::params::crontab_path {
    file { $::awstats::params::crontab_path:
      ensure =>  'file',
      owner  =>  'root',
      group  =>  'root',
      mode   =>  '0755',
      purge  =>  $crontab_manage,
    }
    cron { 'awstats':
      ensure   =>  $_ensure_crontab_update,
      command  =>  $::awstats::params::awstats_update_command,
      user     =>  $::awstats::params::awstats_user,
      minute   =>  $crontab_update[0],
      hour     =>  $crontab_update[1],
      month    =>  $crontab_update[2],
      monthday =>  $crontab_update[3],
      weekday  =>  $crontab_update[4],
    }
    cron { 'awstats_buildstatic':
      ensure   =>  $_ensure_crontab_buildstatic,
      command  =>  $::awstats::params::awstats_buildstatic_command,
      user     =>  $::awstats::params::awstats_user,
      minute   =>  $crontab_buildstatic[0],
      hour     =>  $crontab_buildstatic[1],
      month    =>  $crontab_buildstatic[2],
      monthday =>  $crontab_buildstatic[3],
      weekday  =>  $crontab_buildstatic[4],
    }
  } else {
    if $crontab_manage or $_crontab_manage_buildstatic {
      fail("Managing crontab is not supported on ${::operatingsystem} / ${::operatingsystemmajrelease}")
    }
  }
}
