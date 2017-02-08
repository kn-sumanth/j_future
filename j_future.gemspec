# -*- encoding: utf-8 -*-
require "./lib/j_future/version"

Gem::Specification.new do |s|
  s.name        = 'j_future'
  s.version     = JFuture::VERSION
  s.platform    = 'java'
  s.authors     = ['Sumanth K N']
  s.email       = ['kn.sumanth@gmail.com']
  s.homepage    = 'https://github.com/kn-sumanth/j_future'
  s.description = s.summary = %q{simple future object framework for jruby}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.license = 'MIT'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest', '>= 5.0.0'
  s.add_development_dependency 'rake'
end
