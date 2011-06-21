# Copyright (C) 2010, 2011 by Philippe Bourgau

namespace :stores do

  task :create_auchan_direct => :environment do
    Store.find_or_create_by_url(AuchanDirectStoreCartAPI.url)
  end

  task :create_dummy_store => :environment do
    Store.find_or_create_by_url(DummyStoreCartAPI.url)
  end

  desc "Import stores, by default, (re)import all existing stores, if url=http://... is specified, imports (and maybe creates) this store only."
  task :import => :environment do
    ModelStat::update!

    begin
      stores = stores_to_import()
      Rails.logger.info "Importing #{stores.length.to_s} stores"
      stores.each do |store|
        Rails.logger.info "Importing items from #{store.url}"
        store.import
        Rails.logger.info "Done"
      end
    rescue Exception => e
      Rails.logger.fatal "Import unexpectedly stoped with exception #{e.inspect}"
      raise
    end

    ImportReporter.deliver_delta
  end

  private
  # array of stores to import, according to the 'url' environment variable
  def stores_to_import
    if ENV['url'].nil?
      Store.find(:all)
    else
      [Store.find_or_create_by_url(ENV['url'])]
    end
  end

end
