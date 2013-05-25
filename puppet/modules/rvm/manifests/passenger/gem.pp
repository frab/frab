class rvm::passenger::gem($ruby_version, $version) {
  rvm_gem {
    "passenger":
      ensure       => $version,
      ruby_version => $ruby_version;
  }
}
