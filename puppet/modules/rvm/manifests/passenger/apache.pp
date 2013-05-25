class rvm::passenger::apache(
  $ruby_version,
  $version,
  $rvm_prefix = '/usr/local/',
  $mininstances = '1',
  $maxpoolsize = '6',
  $poolidletime = '300',
  $maxinstancesperapp = '0',
  $spawnmethod = 'smart-lv2'
) {

  case $::operatingsystem {
    Ubuntu,Debian: { include rvm::passenger::apache::ubuntu::pre }
    CentOS,RedHat: { include rvm::passenger::apache::centos::pre }
  }

  class {
    'rvm::passenger::gem':
      ruby_version => $ruby_version,
      version => $version,
  }

  # TODO: How can we get the gempath automatically using the ruby version
  # Can we read the output of a command into a variable?
  # e.g. $gempath = `usr/local/rvm/bin/rvm ${ruby_version} exec rvm gemdir`
  $gempath = "${rvm_prefix}rvm/gems/${ruby_version}/gems"
  $binpath = "${rvm_prefix}rvm/bin/"

  case $::operatingsystem {
    Ubuntu,Debian: {
      if !defined(Class['rvm::passenger::apache::ubuntu::post']) {
        class { 'rvm::passenger::apache::ubuntu::post':
          ruby_version       => $ruby_version,
          version            => $version,
          rvm_prefix         => $rvm_prefix,
          mininstances       => $mininstances,
          maxpoolsize        => $maxpoolsize,
          poolidletime       => $poolidletime,
          maxinstancesperapp => $maxinstancesperapp,
          spawnmethod        => $spawnmethod,
          gempath            => $gempath,
          binpath            => $binpath;
        }
      }
    }
    CentOS,RedHat: {
      if !defined(Class['rvm::passenger::apache::centos::post']) {
        class { 'rvm::passenger::apache::centos::post':
          ruby_version       => $ruby_version,
          version            => $version,
          rvm_prefix         => $rvm_prefix,
          mininstances       => $mininstances,
          maxpoolsize        => $maxpoolsize,
          poolidletime       => $poolidletime,
          maxinstancesperapp => $maxinstancesperapp,
          spawnmethod        => $spawnmethod,
          gempath            => $gempath,
          binpath            => $binpath;
        }
      }
    }
  }
}
