# -*- encoding: utf-8 -*-
# Copyright (C) 2011, 2012, 2013 by Philippe Bourgau

require 'spec_helper'
require_relative 'api_shared_examples'
require "mes_courses/stores/items/real_dummy_api"
require_relative "real_dummy_generator"

module MesCourses
  module Stores
    module Items

      describe "RealDummyApi", slow: true do
        include ApiSpecMacros

        it_should_behave_like_any_store_items_api

        DEFAULT_STORE_NAME = "www.spec-store.com"

        def generate_store(store_name = DEFAULT_STORE_NAME, item_count = 3)
          RealDummy.wipe_out_store(store_name)
          @store_generator = RealDummy.open(store_name)
          @store_generator.generate(3).categories.and(3).categories.and(item_count).items
          @store = new_store(store_name)
        end

        def new_store(store_name = DEFAULT_STORE_NAME)
          Api.browse(RealDummy.uri(store_name))
        end

        it "should not truncate long item names" do
          @store_generator.
            category(cat_name = "extra long category name").
            category(sub_cat_name = "extra long sub category name").
            item(item_name = "super extra long item name").generate().attributes

          category = new_store.categories.find {|cat| cat_name.start_with?(cat.title)}
          expect(category.attributes[:name]).to eq cat_name

          sub_category = category.categories.find {|sub_cat| sub_cat_name.start_with?(sub_cat.title)}
          expect(sub_category.attributes[:name]).to eq sub_cat_name

          item = sub_category.items.find {|it| item_name.start_with?(it.title)}
          expect(item.attributes[:name]).to eq item_name
        end

        it "should use constant memory" do
          warm_up_measure = memory_usage_for_items(1)

          small_inputs_memory = memory_usage_for_items(1)
          large_inputs_memory = memory_usage_for_items(200)

          expect(large_inputs_memory).to be <= small_inputs_memory * 1.25
        end

        def memory_usage_for_items(item_count)
          generate_store(store_name = "www.spec-perf-store.com", item_count)
          memory_peak_of do
            walk_store(store_name)
          end
        end

        def memory_peak_of
          peak_usage = 0
          finished = false

          initial_usage = current_living_objects
          profiler = Thread.new do
            while not finished
              peak_usage = [peak_usage, current_living_objects].max
              sleep(0.01)
            end
          end

          yield

          finished = true
          profiler.join

          peak_usage - initial_usage
        end

        def current_living_objects
          GC.start
          object_counts = ObjectSpace.count_objects
          object_counts[:TOTAL] - object_counts[:FREE]
        end

        def walk_store(store_name)
          new_store(store_name).categories.each do |category|
            @title = category.title
            @attributes = category.attributes
            category.categories.each do |sub_category|
              @title = sub_category.title
              @attributes = sub_category.attributes
              category.items.each do |item|
                @title = item.title
                @attributes = item.attributes
              end
            end
          end
        end
      end
    end
  end
end
