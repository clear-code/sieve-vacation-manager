begin
  require "bundler/setup"
rescue LoadError
end
require "rake/clean"

require "pathname"
require "yaml"
require "gettext/tools/task"
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

GetText::Tools::Task.define do |task|
  task.locales = ["ja", "en"]
  task.files = FileList["lib/**/*.rb", "views/*.erb"]
  task.domain = "sieve-vacation-manager"
end

def top_dir
  Pathname(__FILE__).dirname
end

def lib_dir
  (top_dir + "lib").to_s
end

$LOAD_PATH.unshift(lib_dir)

require "sieve-vacation-manager/version"

def load_app_config
  config = YAML.load_file(top_dir + "config" + "settings.yml")
end

name = "sieve-vacation-manager"
version = SieveVacationManager::VERSION
tar = "#{name}-#{version}.tar"
targz = "#{tar}.gz"

desc "Build tarball"
task :dist => targz

task tar => [:gettext] do
  sh "git archive --format=tar --prefix=#{name}-#{version}/ HEAD > #{tar}"
  sh "bundle package"
  FileList["vendor/cache/*.gem"].each do |gem|
    sh "tar --transform 's,^,#{name}-#{version}/,' -r -f #{tar} #{gem}"
  end
  FileList["locale/**/*.mo"].each do |mo|
    sh "tar --transform 's,^,#{name}-#{version}/,' -r -f #{tar} #{mo}"
  end
  sh "tar --transform 's,^,#{name}-#{version}/,' -r -f #{tar} vendor/cache/ruby-managesieve-984ad57917f6"
end

task targz => tar do
  sh "gzip #{tar}"
end
