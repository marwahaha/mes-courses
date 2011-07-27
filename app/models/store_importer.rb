# Copyright (C) 2010, 2011 by Philippe Bourgau

require 'rubygems'
require 'lib/logging'

# Objects able to dig into an online store and notify their "store" about
# the items and item categories that they found for sale.
class StoreImporter

  # Imports the items sold from the online store to our db
  def import(walker, store)
    @store = store
    if @store.last_import_finished?
      log :info, "Starting new import from #{walker.uri}"
      @store.starting_import
    else
      log :info, "Resuming import from #{walker.uri}"
    end

    unless_already_visited(walker) do
      dig(walker)
    end

    @store.finishing_import
    log :info, "Finished import"
    @store = nil
  end

  private

  attr_reader :store

  def walk_category(walker, parent)
    unless_already_visited(walker) do
      item_category = store.register_item_category(walker.attributes.merge(:parent => parent))

      dig(walker, item_category)
    end
  end

  def walk_item(walker, item_category)
    unless_already_visited(walker) do
      params = walker.attributes
      params[:item_category] = item_category

      log :debug, "Found item #{params.inspect}"
      store.register_item(params)
    end
  end

  # digs into sub categories and items of walker
  def dig(walker, item_category = nil)
    follow(walker.items, :walk_item, item_category)
    follow(walker.categories, :walk_category, item_category)
  end
  def follow(walkers, message, parent = nil)
    walkers.each do |walker|
      self.send(message, walker, parent)
    end
  end


  def unless_already_visited(walker)
    if store.already_visited_url?(walker.uri.to_s)
      log :debug, "Skipping #{walker.uri}"
    else
      with_rescue "Following link #{walker.uri}" do
        yield
        store.register_visited_url(walker.uri.to_s)
      end
    end
  end

  def with_rescue(summary)
    begin
      log :debug, summary
      yield

    rescue StoreItemsBrowsingError, ActiveRecord::RecordInvalid => e
      # this  should mean a page was not in a importable format
      log :warn, "Failed: \"#{summary}\" because "+ e
      # continue, this will eventually delete the faulty items
    rescue Exception => e
      log :error, "Failed: \"#{summary}\" because "+ e
      raise
    end
  end

  def log(level, message)
    Rails.logger.send(level, message)
  end


end
