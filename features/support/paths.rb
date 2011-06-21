# Copyright (C) 2010, 2011 by Philippe Bourgau

module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name, response = nil)
    case page_name

    when /the current page/
      "#{response.env['PATH_INFO']}?#{response.env['QUERY_STRING']}"
    when /the home\s?page/
      '/'
    when /the cart page/
      '/cart'
    when /the full dish catalog page/
      '/dish'
    when /the dish creation page/
      '/dish/new'
    when /the "([^"]*)" dish page/
      dish_path(Dish.find_by_name($1))
    when /the "([^"]*)" dish item categories page/
      dish_item_category_index_path(Dish.find_by_name($1))
    when /the "([^"]*)" dish "([^"]*)" item category page/
      dish_item_category_path(Dish.find_by_name($1), ItemCategory.find_by_name($2))
    when /the item categories page/
      item_category_index_path
    when /the "([^"]*)" item category page/
      item_category_path(ItemCategory.find_by_name_and_parent_id($1, ItemCategory.root.id))
    when /the "([^"]*)" item sub category page/
      item_category_path(ItemCategory.find_by_name($1))
    when /the "([^"]*)" item page/
      item_category_path(Item.find_by_name($1))

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
