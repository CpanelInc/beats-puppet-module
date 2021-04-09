# beats::params - default params for elastic.co metricbeat
class beats::params (
  String    $config_mode           = '0600',
  Boolean   $test_config           = true,
  Integer   $elastic_backoff_init  = 15,
  Integer   $elastic_backoff_max   = 300,
  Integer   $elastic_bulk_max_size = 1024,
  Integer   $elastic_compression   = 3,
  String    $elastic_host          = 'localhost',
  Integer   $elastic_max_retries   = 100,
  Sensitive $elastic_pass          = 'not a real password, look up in Hiera failed',
  Integer   $elastic_port          = 9200,
  Integer   $elastic_timeout       = 120,
  String    $elastic_user          = 'beats_logs',
  String    $ensure                = 'present',
  Integer   $major_version         = 7,
  Boolean   $manage_repo           = true,
  Integer   $queue_events          = 16384,
  Integer   $queue_flush_min       = 8192,
  String    $queue_flush_timeout   = '20s',
  Integer   $reload_period         = 180,
  String    $service_ensure        = 'enabled',
  Boolean   $service_enable        = true,
  Boolean   $service_has_restart   = true,
  Sensitive $ssl_cert              = 'not a real cert, lookup in Hiera failed',
  String    $ssl_cert_ca           = 'not a real cert, lookup in Hiera failed',
  Sensitive $ssl_cert_key          = 'not a real cert key, lookup in Hiera failed',
  String    $ssl_path              = '/etc/pki/tls',
  String    $ssl_subdir_certs      = 'certs',
  String    $ssl_subdir_keys       = 'private',
) {

  case $facts['osfamily'] {
    'RedHat': {
      $repo_data = {
        url => "https://artifacts.elastic.co/packages/oss-${major_version}.x/yum"
      }

    }

    'Debian': {
      $repo_data = {
        url      => 'https://artifacts.elastic.co/packages/7.x/apt',
        repos    => 'stable main',
        # This looks odd, but elastic's repo is the same for all debian based things, and if release is "" or undef, the apt::sources module will default to adding "focal", or whatever ubuntu/debian disto name is there
        # Which doesn't work with elastic.co's repo. This just prints an extra space like so, but works:
            # This file is managed by Puppet. DO NOT EDIT.
            # Elastic repository for .x packages
            # deb https://artifacts.elastic.co/packages/7.x/apt   stable main
        release  => ' ',
        key_hash => {
            id     => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
        }
      }
    }

  }

}

