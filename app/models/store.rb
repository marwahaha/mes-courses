# Copyright (C) 2010 by Philippe Bourgau

require 'store_scrapper'
require 'incremental_store'

# Backend online store of a distributor
class Store < ActiveRecord::Base

  attr_accessor :scrapper

  def initialize(*)
    super
    self.scrapper = StoreScrapper.new
  end

  # Imports the items sold from the online store to our db
  def import
    scrapper.import(url,IncrementalStore.new(self))
  end

  # Methods called by the importer when he founds something
  def register!(record)
    record.save!
  end
  def known_item(name)
    Item.find_by_name(name)
  end

  def mark_existing_items
    remove_all_marks
    connection.execute("INSERT INTO to_delete_items SELECT id from items")
  end
  def mark_not_sold_out(item)
    connection.execute("DELETE FROM to_delete_items where item_id = #{item.id}")
  end
  def delete_sold_out_items
    connection.execute("DELETE FROM items WHERE id IN (SELECT item_id FROM to_delete_items)")
    remove_all_marks
  end

  private
  def remove_all_marks
    connection.execute("DELETE FROM to_delete_items")
  end

end
