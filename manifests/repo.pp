# beats::repo - pull in the open-source beats repo from elastic.co
# this repo covers all their clients: metricbeat, filebeat, packetbeat, etc
class beats::repo (
  Hash   $repo_data = $beats::params::repo_data,
) inherits beats::params {

  case $facts['osfamily'] {
    'RedHat': {
      ensure_resource(
        'yumrepo',
        'beats',
        {
          baseurl  => $repo_data[ 'url' ],
          descr    => "Elastic repository for ${metricbeat::major_version}.x packages",
          enabled  => 1,
          gpgcheck => 1,
          gpgkey   => 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
        }
      )
    }
    'Debian': {
      apt::source { 'elastic.co':
        comment  => "Elastic repository for ${metricbeat::major_version}.x packages",
        release  => $repo_data[ 'release' ],
        location => $repo_data[ 'url' ],
        repos    => $repo_data[ 'repos' ],
        key      => $repo_data[ 'key_hash' ],
      }
    }
    default: {
    }
  }

}
