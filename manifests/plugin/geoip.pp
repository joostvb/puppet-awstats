# == Class: awstats::plugin::geoip
#
# This class should be considered private
#
class awstats::plugin::geoip {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $package = $::osfamily ? {
    'Debian'  =>  ['libgeo-ip-perl', 'libgeo-ipfree-perl'],
    'RedHat'  =>  'perl-Geo-IP',
  }

  ensure_packages($package)
}
