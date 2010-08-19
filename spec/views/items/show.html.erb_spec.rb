require 'spec_helper'

describe "items/show.html.erb" do

  before(:each) do
    @items = ["Tomates", "Pommes de terre"].map {|name| stub_model(Item, :name => name) }
    assigns[:items] = @items
  end

  it "displays the name of each item" do
    render
    @items.each {|item| response.should contain(item.name) }
  end

  it "displays a link to add items to the cart" do
    render
    @items.each {|item| response.should have_selector("a", :href => default_path(:controller => 'cart',
                                                                                 :action => 'add_to_cart',
                                                                                 :id => item.id)) }
  end

end

