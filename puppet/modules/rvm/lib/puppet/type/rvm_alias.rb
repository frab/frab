Puppet::Type.newtype(:rvm_alias) do
  @doc = "Manage RVM Aliases."

  ensurable

  newparam(:name) do
    desc "The name of the alias to be managed."
    isnamevar
  end

  newparam(:target_ruby) do
    desc "The ruby version that is the target of our alias.
    For example: 'ruby-1.9.2-p290'"
  end

end
