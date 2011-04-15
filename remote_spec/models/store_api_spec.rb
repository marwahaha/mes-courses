# Copyright (C) 2011 by Philippe Bourgau

require 'rubygems'
require 'spec_helper'
require "lib/offline_test_helper"

include OfflineTestHelper

if offline?
  puts yellow "WARNING: skipping StoreAPI remote spec because tests are running offline."

else

  describe StoreAPI do

    it "should raise when login in with an invalid account" do
      lambda {
        AuchanDirectStoreAPI.new("unknown-account", "wrong-password")
      }.should raise_error(InvalidStoreAccountError)
    end

    context "with a valid account" do

      before(:each) do
        @api = AuchanDirectStoreAPI.new(LOGIN, PASSWORD)
      end
      after(:each) do
        @api.logout
      end

      it "should set the cart value to 0 when emptying the cart" do
        @api.set_item_quantity_in_cart(1, sample_item)

        @api.empty_the_cart
        @api.value_of_the_cart.should == 0
      end

      it "should set the cart value to something greater than 0 when adding items to the cart" do
        @api.empty_the_cart

        @api.set_item_quantity_in_cart(1, sample_item)
        @api.value_of_the_cart.should >  0
      end

      it "should set the cart value to 3 times that of one item when adding 3 items" do
        @api.empty_the_cart

        @api.set_item_quantity_in_cart(1, sample_item)
        item_price = @api.value_of_the_cart

        @api.set_item_quantity_in_cart(3, sample_item)
        @api.value_of_the_cart.should == 3*item_price
      end

      it "should synchronize different sessions with logout login" do
        @api.set_item_quantity_in_cart(1, sample_item)

        AuchanDirectStoreAPI.new(LOGIN, PASSWORD).with_logout do |api2|
          api2.empty_the_cart
        end

        @api.logout
        @api = AuchanDirectStoreAPI.new(LOGIN, PASSWORD)

        @api.value_of_the_cart.should == 0
      end

      LOGIN = "philippe.bourgau@free.fr"
      PASSWORD = "NoahRules78"

      attr_reader :sample_item

      before(:all) do
        @sample_item = extract_sample_item
        @sample_item.should_not be_nil
      end

      private

      def extract_sample_item
        StoreWalker.new(AuchanDirectStoreAPI.url).categories.each do |cat|
          cat.categories.each do |subcat|
            subcat.items.each do |item|
              attributes = item.attributes
              if attributes[:price] != 0.0
                return Item.new(item.attributes)
              end
            end
          end
        end
        return nil
      end

    end

  end

end
