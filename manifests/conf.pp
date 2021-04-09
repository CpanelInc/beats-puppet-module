# beats::conf - configure an instance ofelastic.co filebeat or metricbeat
define beats::conf (
  String    $config_mode           = $::beats::params::config_mode,
  Boolean   $test_config           = $::beats::params::test_config,
  Integer   $elastic_backoff_init  = $::beats::params::elastic_backoff_init,
  Integer   $elastic_backoff_max   = $::beats::params::elastic_backoff_max,
  Integer   $elastic_bulk_max_size = $::beats::params::elastic_bulk_max_size,
  Integer   $elastic_compression   = $::beats::params::elastic_compression,
  String    $elastic_host          = $::beats::params::elastic_host,
  Integer   $elastic_max_retries   = $::beats::params::elastic_max_retries,
  Sensitive $elastic_pass          = $::beats::params::elastic_pass,
  Integer   $elastic_port          = $::beats::params::elastic_port,
  Integer   $elastic_timeout       = $::beats::params::elastic_timeout,
  String    $elastic_user          = $::beats::params::elastic_user,
  String    $ensure                = $::beats::params::ensure,
  Integer   $major_version         = $::beats::params::major_version,
  Boolean   $manage_repo           = $::beats::params::manage_repo,
  Integer   $queue_events          = $::beats::params::queue_events,
  Integer   $queue_flush_min       = $::beats::params::queue_flush_min,
  String    $queue_flush_timeout   = $::beats::params::queue_flush_timeout,
  Integer   $reload_period         = $::beats::params::reload_period,
  String    $service_ensure        = $::beats::params::service_ensure,
  Boolean   $service_enable        = $::beats::params::service_enable,
  Boolean   $service_has_restart   = $::beats::params::service_has_restart,
  Sensitive $ssl_cert              = $::beats::params::ssl_cert,
  String    $ssl_cert_ca           = $::beats::params::ssl_cert_ca,
  Sensitive $ssl_cert_key          = $::beats::params::ssl_cert_key,
  String    $ssl_path              = $::beats::params::ssl_path,
  String    $ssl_subdir_certs      = $::beats::params::ssl_subdir_certs,
  String    $ssl_subdir_keys       = $::beats::params::ssl_subdir_keys,
  Array[String, 1] $modules        = [ 'auditd', 'haproxy', 'kvm', 'nginx', 'postgresql' ]
  # or for example
  # $modules = [ 'httpd', 'haproxy', 'kvm', 'mysql', 'nginx', 'system' ]
  # or whatever the best defaults would be. not sure yet. but overridable from Hiera.
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
  $ssl_path_ca   = "${ssl_path}/${ssl_subdir_certs}/${type}beat_ca.crt"
  $ssl_path_cert = "${ssl_path}/${ssl_subdir_certs}/${type}beat.crt"
  $ssl_path_key  = "${ssl_path}/${ssl_subdir_keys}/${type}beat.key"

  $yum_repo_url = "https://artifacts.elastic.co/packages/oss-${major_version}.x/yum"

  $elastic_index = "${type}beat-%{[agent.version]}-%{+yyyy.MM.dd}"

  case $::kernel {
    'Linux': {
      $config_dir       = "/etc/${type}beat"
      $package_ensure   = $ensure
      $tmp_dir          = '/tmp'
    }
    default: {
      fail("${::kernel} is not supported by ${type}beat.")
    }
  }

  File {
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  ensure_resource( 'file', "${ssl_path}/${ssl_subdir_keys}",
  {
    ensure => $ensure,
    mode   => '0711',
  })

  file { $ssl_path_cert :
    content => "${ssl_cert}",
  }

  file { $ssl_path_ca :
    content => "${ssl_cert_ca}",
  }

  file { $ssl_path_key :
    content => "${ssl_cert_key}",
    mode    => '0600'
  }

  $validate_cmd = $test_config ? {
    false   => undef,
    default => $major_version ? {
      "5"     => "/usr/share/${type}beat/bin/${type}beat -configtest -c %",
      default => "/usr/share/${type}beat/bin/${type}beat --path.config ${config_dir} test config",
    }
  }

  file { "${config_dir}/${type}beat.yml":
    ensure   => $ensure,
    require  => File[
      $ssl_path_cert,
      $ssl_path_ca,
      $ssl_path_key
    ],
    owner   => 'root',
    group   => 'root',
    mode    => $config_mode,
    content => template("beats/${type}beat.yml"),
    # puppet tries to validate metricbeat.yml BEFORE initial deployment
    # validate_cmd => $validate_cmd,
  }

  file{ "${config_dir}/modules.d/system.yml":
    ensure  => $ensure,
    require => Package["${type}beat"],
    owner   => 'root',
    group   => 'root',
    mode    => $config_mode,
    content => template("beats/mod/${type}/system.yml"),
  }
  if defined( Service['httpd'] ) {
    file{ "${config_dir}/modules.d/apache.yml":
      ensure  => $ensure,
      require => Package["${type}beat"],
      owner   => 'root',
      group   => 'root',
      mode    => $config_mode,
      content => template("beats/mod/${type}/apache.yml"),
    }
  }
  $modules.each |$mod| {
    if defined( Service[$mod] ) {
      file{ "${config_dir}/modules.d/${mod}.yml":
        ensure  => $ensure,
        require => Package["${type}beat"],
        owner   => 'root',
        group   => 'root',
        mode    => $config_mode,
        content => template("beats/mod/${type}/${mod}.yml"),
      }
      file{ "${config_dir}/modules.d/${mod}.yml.disabled":
        ensure => 'absent'
      }
    }
  }

}

