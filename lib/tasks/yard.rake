require "github/markdown"
require "redcarpet"
require "yard" 
require "yard/rake/yardoc_task" 
  
YARD::Rake::YardocTask.new do |t|
  t.options = %w(--markup-provider=redcarpet --markup=markdown --main=README.md) 
end
