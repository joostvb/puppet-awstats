# == Class: awstats::cron
#
class awstats::cron(
  $crontab_manage             = true,
  $crontab_manage_buildstatic = undef,
  $crontab_update             = { 'minute'   => '*/10',
                                  'hour'     => absent,
                                  'month'    => absent,
                                  'monthday' => absent,
                                  'weekday'  => absent },
  $crontab_buildstatic        = { 'minute'   => '10',
                                  'hour'     => '03',
                                  'month'    => absent,
                                  'monthday' => absent,
                                  'weekday'  => absent }
) inherits ::awstats::params {
  validate_bool($crontab_manage)
  validate_hash($crontab_update)
  validate_hash($crontab_buildstatic)

  if ! $crontab_manage and $crontab_manage_buildstatic {
    warning('Adding cron entry for building static pages, but original cron entry was not purged (crontab_manage=false). Possible duplicate cron entries.')
  }

  include '::awstats'

  if $crontab_manage_buildstatic == undef {
    $_crontab_manage_buildstatic = $crontab_manage
  } else {
    $_crontab_manage_buildstatic = $crontab_manage_buildstatic
  }

  $_ensure_crontab_update = $crontab_manage ? {
    true    =>  'present',
    default =>  'absent',
  }

  $_ensure_crond_original = $crontab_manage ? {
    true    =>  'absent',
    default =>  'present',
  }

  $_ensure_crontab_buildstatic = $_crontab_manage_buildstatic ? {
    true    =>  'present',
    default =>  'absent',
  }

  if $::osfamily == 'Debian' {
    file { $::awstats::params::crontab_path:
      ensure =>  $_ensure_crond_original,
      owner  =>  'root',
      group  =>  'root',
      mode   =>  '0644',
    }
    cron { 'awstats':
      ensure   =>  $_ensure_crontab_update,
      command  =>  $::awstats::params::awstats_update_command,
      user     =>  $::awstats::params::awstats_user,
      minute   =>  $crontab_update['minute'],
      hour     =>  $crontab_update['hour'],
      month    =>  $crontab_update['month'],
      monthday =>  $crontab_update['monthday'],
      weekday  =>  $crontab_update['weekday'],
    }
    cron { 'awstats_buildstatic':
      ensure   =>  $_ensure_crontab_buildstatic,
      command  =>  $::awstats::params::awstats_buildstatic_command,
      user     =>  $::awstats::params::awstats_user,
      minute   =>  $crontab_buildstatic['minute'],
      hour     =>  $crontab_buildstatic['hour'],
      month    =>  $crontab_buildstatic['month'],
      monthday =>  $crontab_buildstatic['monthday'],
      weekday  =>  $crontab_buildstatic['weekday'],
    }
  } else {
    if $crontab_manage or $_crontab_manage_buildstatic {
      fail("Managing crontab is not supported on ${::operatingsystem} / ${::operatingsystemmajrelease}")
    }
  }
}
