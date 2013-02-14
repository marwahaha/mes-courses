# Copyright (C) 2013 by Philippe Bourgau

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new("cucumber:dry_run") do |t|
  t.cucumber_opts = "features --dry-run"
end
