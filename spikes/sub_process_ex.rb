# Copyright (C) 2014 by Philippe Bourgau


puts "I am starting"
(1..3).each do |i|
  STDOUT.write '.'
  STDERR.write '*'
  sleep(1)
end
