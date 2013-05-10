Puppet::Type.newtype(:rvm_gemset) do
  @doc = "Manage RVM Gemsets."

  def self.title_patterns
    [ [ /^(?:(.*)@)?(.*)$/, [ [ :ruby_version, lambda{|x| x} ], [ :name, lambda{|x| x} ] ] ] ]
  end

  ensurable

  newparam(:name) do
    desc "The name of the gemset to be managed."
    isnamevar
  end

  newparam(:ruby_version) do
    desc "The ruby version to use.  This should be the fully qualified RVM string.
    For example: 'ruby-1.9.2-p290'
    For a full list of known strings: `rvm list known_strings`."

    defaultto "ruby-1.9.2-p290"
    isnamevar
  end

end
