# Copyright (C) 2010, 2011 by Philippe Bourgau

class ItemCategoriesController < ApplicationController
  include ApplicationHelper

  before_filter :assign_nesting

  def index
    redirect_to @nesting.item_category_path(ItemCategory.root)
  end

  def show
    assign_html_body_id
    assign_show_sub_category_url_options
    assign_add_item_attributes

    item_category = ItemCategory.find_by_id(params[:id])
    @search_url = @nesting.item_category_path(item_category)

    if (params.has_key?("search"))
      keyword = params["search"]["keyword"]
      @path_bar = search_path_bar(keyword, item_category)
      @categories = []
      @items = Item.search_by_keyword_and_category(keyword, item_category)

    else
      @path_bar = path_bar(item_category)
      @categories = item_category.children
      @items = item_category.items
    end
  end

  private

  def assign_html_body_id
    @body_id = @nesting.html_body_id
  end

  def assign_add_item_attributes
    @add_item_label = @nesting.add_item_label
    @add_item_url_options = @nesting.add_item_url_options
    @add_item_html_options = @nesting.add_item_html_options
  end

  def assign_show_sub_category_url_options
    @show_sub_category_url_options = @nesting.show_sub_category_url_options
  end

  def search_path_bar(keyword, item_category = nil)
    result = path_bar(item_category)
    result.push(PathBar.element_with_no_link(keyword))
    result
  end

  def path_bar(item_category = nil)
    result = @nesting.root_path_bar

    collect_path_bar(item_category, result)

    result
  end

  def collect_path_bar(item_category, result)
    if item_category.nil? || item_category.root?
      result.push PathBar.element("Ingrédients", @nesting.item_categories_path)
    else
      collect_path_bar(item_category.parent, result)
      result.push PathBar.element(item_category.name, @nesting.item_category_path(item_category))
    end
  end

  def assign_nesting
    @nesting = new_nesting
  end
  def new_nesting
    if params[:dish_id].nil?
      ItemCategoriesControllerStandaloneNesting.new
    else
      ItemCategoriesControllerDishNesting.new(params[:dish_id])
    end
  end


end
