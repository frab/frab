class rvm::dependencies::oraclelinux {

  if ! defined(Package['which'])           { package { 'which':           ensure => installed } }
  if ! defined(Package['gcc'])             { package { 'gcc':             ensure => installed } }
  if ! defined(Package['gcc-c++'])         { package { 'gcc-c++':         ensure => installed } }
  if ! defined(Package['make'])            { package { 'make':            ensure => installed } }
  if ! defined(Package['gettext-devel'])   { package { 'gettext-devel':   ensure => installed } }
  if ! defined(Package['expat-devel'])     { package { 'expat-devel':     ensure => installed } }
  if ! defined(Package['libcurl-devel'])   { package { 'libcurl-devel':   ensure => installed } }
  if ! defined(Package['zlib-devel'])      { package { 'zlib-devel':      ensure => installed } }
  if ! defined(Package['openssl-devel'])   { package { 'openssl-devel':   ensure => installed } }
  if ! defined(Package['perl'])            { package { 'perl':            ensure => installed } }
  if ! defined(Package['cpio'])            { package { 'cpio':            ensure => installed } }
  if ! defined(Package['expat-devel'])     { package { 'expat-devel':     ensure => installed } }
  if ! defined(Package['gettext-devel'])   { package { 'gettext-devel':   ensure => installed } }
  if ! defined(Package['wget'])            { package { 'wget':            ensure => installed } }
  if ! defined(Package['bzip2'])           { package { 'bzip2':           ensure => installed } }
  if ! defined(Package['sendmail'])        { package { 'sendmail':        ensure => installed } }
  if ! defined(Package['mailx'])           { package { 'mailx':           ensure => installed } }
  if ! defined(Package['libxml2'])         { package { 'libxml2':         ensure => installed } }
  if ! defined(Package['libxml2-devel'])   { package { 'libxml2-devel':   ensure => installed } }
  if ! defined(Package['libxslt'])         { package { 'libxslt':         ensure => installed } }
  if ! defined(Package['libxslt-devel'])   { package { 'libxslt-devel':   ensure => installed } }
  if ! defined(Package['readline-devel'])  { package { 'readline-devel':  ensure => installed } }
  if ! defined(Package['patch'])           { package { 'patch':           ensure => installed } }
  if ! defined(Package['git'])             { package { 'git':             ensure => installed } }
}
