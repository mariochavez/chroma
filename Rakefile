# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/test_*.rb"]
end

require "standard/rake"

task default: %i[test standard]

require "sdoc" # and use your RDoc task the same way you used it before
require "rdoc/task" # ensure this file is also required in order to use `RDoc::Task`

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "doc/rdoc"      # name of output directory
  rdoc.options << "--format=sdoc" # explictly set the sdoc generator
  rdoc.template = "rails"         # template used on api.rubyonrails.org
end

desc "Run Ruby Next nextify"
task :nextify do
  sh "bundle exec ruby-next nextify -V"
end
