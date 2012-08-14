# -*- encoding: utf-8 -*-
# Copyright (C) 2010, 2011, 2012 by Philippe Bourgau

# Objects able to walk a store and discover available items
class StoreItemsAPI

  def self.browse(store_url)
    if store_url == MesCourses::StoreCarts::DummyStoreCartAPI.url
      DummyStoreItemsAPI.new_default_store(store_url)
    else
      builder(store_url).new(StoreWalkerPage.open(store_url))
    end
  end

  def self.register_builder(name, builder)
    builders[name] = builder
  end

  # Uri of the main page of the store
  # def uri

  # Attributes of the page
  # def attributes

  # Walkers of the root categories of the store
  # def categories

  # Walkers of the root items in the store
  # def items

  private

  def self.builder(store_url)
    builders.each do |name, builder|
      if store_url.include?(name)
        return builder
      end
    end
    raise NotImplementedError.new("Could not find a store item api for '#{store_url}'")
  end

  def self.builders
    @builders ||= {}
  end
end

