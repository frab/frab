class rvm::dependencies::ubuntu {

  if ! defined(Package['build-essential'])      { package { 'build-essential':      ensure => installed } }
  if ! defined(Package['bison'])                { package { 'bison':                ensure => installed } }
  if ! defined(Package['openssl'])              { package { 'openssl':              ensure => installed } }
  if ! defined(Package['libreadline6'])         { package { 'libreadline6':         ensure => installed } }
  if ! defined(Package['libreadline6-dev'])     { package { 'libreadline6-dev':     ensure => installed } }
  if ! defined(Package['curl'])                 { package { 'curl':                 ensure => installed } }
  if ! defined(Package['git-core'])             { package { 'git-core':             ensure => installed } }
  if ! defined(Package['zlib1g'])               { package { 'zlib1g':               ensure => installed } }
  if ! defined(Package['zlib1g-dev'])           { package { 'zlib1g-dev':           ensure => installed } }
  if ! defined(Package['libssl-dev'])           { package { 'libssl-dev':           ensure => installed } }
  if ! defined(Package['libyaml-dev'])          { package { 'libyaml-dev':          ensure => installed } }
  if ! defined(Package['libsqlite3-0'])         { package { 'libsqlite3-0':         ensure => installed } }
  if ! defined(Package['libsqlite3-dev'])       { package { 'libsqlite3-dev':       ensure => installed } }
  if ! defined(Package['sqlite3'])              { package { 'sqlite3':              ensure => installed } }
  if ! defined(Package['libxml2-dev'])          { package { 'libxml2-dev':          ensure => installed } }
  if ! defined(Package['libxslt1-dev'])         { package { 'libxslt1-dev':         ensure => installed, alias => 'libxslt-dev' } }
  if ! defined(Package['autoconf'])             { package { 'autoconf':             ensure => installed } }
  if ! defined(Package['libc6-dev'])            { package { 'libc6-dev':            ensure => installed } }

}
