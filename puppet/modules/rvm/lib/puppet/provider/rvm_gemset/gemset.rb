# RVM gemset support
Puppet::Type.type(:rvm_gemset).provide(:gemset) do
  desc "RVM gemset support."

  commands :rvmcmd => "/usr/local/rvm/bin/rvm"

  def ruby_version
    resource[:ruby_version]
  end

  def gemset_name
    resource[:name]
  end

  def gemsetcommand
    [command(:rvmcmd), ruby_version, "exec", "rvm", "gemset"]
  end

  def gemsetcommand_force
    [command(:rvmcmd), ruby_version, "exec", "rvm", "--force", "gemset"]
  end

  def gemset_list
    command = gemsetcommand + ['list']

    list = []
    begin
      list = execute(command).split("\n").collect do |line|
        line.strip if line =~ /^\s+\S+/
      end.compact
    rescue Puppet::ExecutionFailure => detail
    end

    list
  end

  def create
    command = gemsetcommand + ['create', gemset_name]
    execute(command)
  end

  def destroy
    command = gemsetcommand_force + ['delete', gemset_name]
    execute(command)
  end

  def exists?
    gemset_list.include? gemset_name
  end
end
