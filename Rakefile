# Author:		Chris Wailes <chris.wailes@gmail.com>
# Project: 	Filigree
# Date:		2013/4/19
# Description:	Filigree's Rakefile.

############
# Requires #
############

# Filigree
require File.expand_path("../lib/filigree/request_file", __FILE__)
require File.expand_path("../lib/filigree/version", __FILE__)

###########
# Bundler #
###########

request_file('bundler', 'Bundler is not installed.') do
	Bundler::GemHelper.install_tasks
end

############
# MiniTest #
############

request_file('rake/testtask', 'Minitest is not installed.') do
	Rake::TestTask.new do |t|
		t.libs << 'test'
		t.test_files = FileList['test/ts_filigree.rb']
	end
end

#########
# Notes #
#########

request_file('rake/notes/rake_task', 'Rake-notes is not installed.')

########
# Reek #
########

request_file('reek/rake/task', 'Reek is not installed.') do
	Reek::Rake::Task.new do |t|
	  t.fail_on_error = false
	end
end

##################
# Rubygems Tasks #
##################

request_file('rubygems/tasks', 'Rubygems-tasks is not installed.') do
	Gem::Tasks.new do |t|
		t.console.command = 'pry'
	end
end

########
# YARD #
########

request_file('yard', 'Yard is not installed.') do
	YARD::Rake::YardocTask.new do |t|
		t.options	= [
			'--title',	'Filigree',
			'-m',		'markdown',
			'-M',		'redcarpet',
			'-c',		'.yardoc/cache',
			'--private'
		]
		
		t.files	= Dir['lib/**/*.rb']
	end
end
