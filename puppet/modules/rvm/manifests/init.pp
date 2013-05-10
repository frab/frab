class rvm($version='latest', $install_rvm=true) {
  stage { 'rvm-install': before => Stage['main'] }

  if $install_rvm {
    class {
      'rvm::dependencies': stage => 'rvm-install';
      'rvm::system':       stage => 'rvm-install', version => $version;
    }
  }
}
