# beats::service - manage elastic.co metricbeat on Linux
define beats::service (
  Optional[Enum['running','stopped']] $ensure = 'running',
  Boolean                             $enable = true,
) {

  service {"${name}beat":
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => $beats::service_has_restart,
  }
}
