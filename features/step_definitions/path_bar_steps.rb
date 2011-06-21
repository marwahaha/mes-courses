# Copyright (C) 2011 by Philippe Bourgau

require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require 'webrat/core/locators/link_locator'

def path_bar_link_constraint(path_bar_line)
  if path_bar_line =~ /^a link "([^\"]*)" to (.+ page)$/
    text = $1
    page_name = $2
    "[text()='#{text}'][@href='#{path_to(page_name, request)}']"

  elsif path_bar_line =~ /^"([^\"]*)"$/
    text = $1
    "[text()='#{text}']"

  end
end

Then /^The path bar should be$/ do |path_bar_lines|
  path_bar_lines.each_with_index do |path_bar_line, index|
    response.should have_xpath("//div[@id='path-bar']/a[#{index+1}]#{path_bar_link_constraint(path_bar_line)}")
  end
  response.should_not have_xpath("//div[@id='path-bar']/a[#{path_bar_lines.lines.count+2}]")
end
