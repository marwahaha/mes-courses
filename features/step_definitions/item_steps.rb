# -*- encoding: utf-8 -*-
# Copyright (C) 2010, 2011, 2012, 2013 by Philippe Bourgau

Given /^there is an? "([^">]*) > ([^">]*) > ([^">]*)" item"?$/ do |category_name, sub_category_name, item_name|
  @item = categorized_item(category_name, sub_category_name, :name => item_name)
  @item.remote_id = @item.id
  @item.save!
end

Given /^there is an? "([^">]*) > ([^">]*) > ([^">]*)" item at ([0-9\.]+)€"?$/ do |category_name, sub_category_name, item_name, price|
  @item = categorized_item(category_name, sub_category_name, :name => item_name, :price => price.to_f)
  @item.remote_id = @item.id
  @item.save!
end

Given /^the following items are disabled$/ do |item_table|
  item_table.each_item do |cat_name, sub_cat_name, item_name|
    category = ItemCategory.find_by_name(cat_name)
    sub_category = category.children.find_by_name(sub_cat_name)
    item = sub_category.items.find_by_name(item_name)
    item.disable
  end
end

Then /^there should be (\d+) different items with name "([^"]*)""? for sale$/ do |count, name|
  Item.count(:conditions => {:name => name}).should == count.to_i
end

Then /^all items should be organized by type and subtype$/ do
  Item.all_but_lost.each do |item|
    item.item_categories.should_not be_empty
    item.item_categories.each do |item_category|
      item_category.parent.should_not be_nil
    end
  end
end

Then /^all items should have an? (.*)$/ do |attribute|
  items = Item.all_but_lost
  items.should all_do have_non_nil(attribute)
end

Then /^most items should have an? (.*)$/ do |attribute|
  Item.all_but_lost.should mostly have_non_nil(attribute)
end

Then /^I should see the "([^"]*)" of "([^"]*)"$/ do |attribute, item_name|
  item = Item.find_by_name(item_name)
  attribute_text = item.send(attribute).to_s
  page.should have_content(attribute_text)
end

Then /^I should see the "([^"]*)" of "([^"]*)" as img$/ do |attribute, item_name|
  item = Item.find_by_name(item_name)
  attribute_text = item.send(attribute).to_s
  page.should have_xpath(".//img[@src='#{https_url(attribute_text)}']")
end

Then /^new items should have been inserted$/ do
  Item.maximum(:created_at).should > Item.past_metrics[:created_at]
end
Then /^no new item should have been inserted$/ do
  Item.maximum(:created_at).should == Item.past_metrics[:created_at]
end

Then /^some items should have been modified$/ do
  Item.maximum(:updated_at).should > Item.past_metrics[:updated_at]
end
Then /^no item should have been modified$/ do
  Item.maximum(:updated_at).should == Item.past_metrics[:updated_at]
end

Then /^no item should have been deleted$/ do
  Item.count.should == Item.past_metrics[:count]
end

Then /^existing items should not have been modified$/ do
  Item.past_metrics[:all].each do |item|
    item.reload
    item.updated_at.should <= Item.past_metrics[:updated_at]
  end
end

Then /^item organization should not have changed$/ do
  ItemCategory.current_metrics.should == ItemCategory.past_metrics
end

def i_should_see_an_item(item_name)
  page.find('#items-panel').should have_content(item_name)
end

Then /^I should see an? "([^"]*)" item"?$/ do |item_name|
  i_should_see_an_item(item_name)
end

Then /^I should not see an? "([^"]*)" item"?$/ do |item_name|
  page.find('#items-panel').should_not have_content(item_name)
end

Then(/^there should be the following items$/) do |table|
  there_should_be_the_following_items(table)
end

Then /^the following items should be in categories$/ do |table|
  the_following_items_should_be_in_categories(table)
end

Then /^the following items should be disabled$/ do |table|
  the_following_items_should_be_disabled(table)
end

Then /^the following items should have been deleted$/ do |table|
  the_following_items_should_have_been_deleted(table)
end

Then /^the following items should be enabled$/ do |table|
  the_following_items_should_be_enabled(table)
end
