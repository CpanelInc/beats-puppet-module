# beats::install - install Elastic.co MetricBeat or FileBeat
define beats::install (
  Variant[
    Enum[
      'installed',
      'uninstalled',
      'present',
      'absent',
      'latest'
    ],
    SemVer
  ] $ensure     = 'installed',
) {

  case $name {
    'file': {
      info('installing filebeat')
    }
    'metric': {
      info('installing metricbeat')
    }
    default: {
      fail("${name} is not a beat type supported by the beats module. Should be 'file' or 'metric'.")
    }
  }
  $type = $name

  case $facts['osfamily'] {
    'RedHat', 'Debian': {
      info("${::osfamily} is supported.")
    }

    default: {
      fail("${::osfamily} is not supported by the beats module.")
    }
  }

  package{ "${type}beat":
    ensure => $ensure,
  }

  file { "${beat::config_dir}/${type}beat.yml.rpmnew":
    ensure => absent
  }
}
