require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/spec/**/*_test.rb"]
  t.verbose = false
end

task :default => :test