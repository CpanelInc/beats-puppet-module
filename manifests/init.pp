# beats::init - metricbeat for use with ODFE (opendistro.github.org)
class beats(
) inherits beats::params {
  class { 'beats::repo': }->
    beats::install{ 'file':
      ensure => $beats::params::ensure,
    }->
    beats::install{ 'metric':
      ensure => $beats::params::ensure,
    }->
    beats::conf{ 'file':
      ensure => $beats::params::ensure,
    }->
    beats::conf{ 'metric':
      ensure => $beats::params::ensure,
    }->
    beats::service{ 'file':
      ensure => $beats::params::service_ensure,
      enable => $beats::params::service_enable,
    }->
    beats::service{ 'metric':
      ensure => $beats::params::service_ensure,
      enable => $beats::params::service_enable,
    }
}
