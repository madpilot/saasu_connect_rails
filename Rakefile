require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test
task :contact_test

desc 'Test the SaasuConnect plugin'
Rake::TestTask.new(:test) do |t|
	t.libs << 'lib'
	t.pattern = 'test/**/*_test.rb'
	t.verbose = true
end

desc 'Test bank_account class from the SaasuConnect plugin'
Rake::TestTask.new(:bank_account_test) do |t|
	t.libs << 'lib'
	t.pattern = 'test/**/bank_account_test.rb'
	t.verbose = true
end

desc 'Test contact class from the SaasuConnect plugin'
Rake::TestTask.new(:contact_test) do |t|
	t.libs << 'lib'
	t.pattern = 'test/**/contact_test.rb'
	t.verbose = true
end

desc 'Test contact category class from the SaasuConnect plugin'
Rake::TestTask.new(:contact_category_test) do |t|
	t.libs << 'lib'
	t.pattern = 'test/**/contact_category_test.rb'
	t.verbose = true
end

desc 'Test transaction category class from the SaasuConnect plugin'
Rake::TestTask.new(:transaction_category_test) do |t|
	t.libs << 'lib'
	t.pattern = 'test/**/transaction_category_test.rb'
	t.verbose = true
end

desc 'Test invoice class from the SaasuConnect plugin'
Rake::TestTask.new(:invoice_test) do |t|
	t.libs << 'lib'
	t.pattern = 'test/**/invoice_test.rb'
	t.verbose = true
end
