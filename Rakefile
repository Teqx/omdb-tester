# Rakefile (for tests)

require "rake/testtask"
Rake::TestTask.new do |t|
  t.test_files = FileList['suite/*_spec.rb']
  t.verbose = true
end

task default: :test