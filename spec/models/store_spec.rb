# -*- encoding: utf-8 -*-
# Copyright (C) 2010, 2011, 2012, 2013 by Philippe Bourgau

require 'spec_helper'

describe Store do

  # setting static constants up
  before(:each) do
    @valid_attributes = { :url => "http://www.ze-store.com", :expected_items => 10, :sponsored_url => "http://www.ze-store.com/sponsored" }

    @importer = mock(MesCourses::Stores::Imports::Base).as_null_object
    MesCourses::Stores::Imports::Base.stub(:new).and_return(@importer)

    Store.stub(:maximum).with(:expected_items).and_return(0)
  end

  it "should create a new instance given valid attributes" do
    Store.create!(@valid_attributes)
  end

  it "should ask its importer to import" do
    store = Store.new(@valid_attributes)

    browser = stub("Store Items API")
    MesCourses::Stores::Items::Api.stub(:browse).and_return(browser)

    robust_browser = stub(MesCourses::Utils::Retrier)
    MesCourses::Utils::Retrier.stub(:new).with(browser, anything).and_return(robust_browser)

    incremental_store = stub("Incremental store")
    MesCourses::Stores::Imports::Incremental.stub(:new).with(store).and_return(incremental_store)

    @importer.should_receive(:import).with(robust_browser, incremental_store)

    store.import
  end

  it "should use its url host as name" do
    Store.new(:url => "http://www.hard-discount-store.eco/index").name.should == "www.hard-discount-store.eco"
  end

  context "the cart api" do
    before :each do
      @store = FactoryGirl.build(:store)
    end

    it "should know the logout url of the cart api" do
      @store.logout_url.should == MesCourses::Stores::Carts::DummyApi.logout_url
    end

    it "should know the login form of the cart api" do
      credentials = MesCourses::Utils::Credentials.new("a login", "a password")
      @store.login_form_html(credentials).should == MesCourses::Stores::Carts::DummyApi.login_form_html(credentials.login, credentials.password)
    end

    it "should yield the session to the cart api" do
      MesCourses::Stores::Carts::DummyApi.on_result_from(:login) {|api| @dummy_api = api}

      @store.with_session(MesCourses::Stores::Carts::DummyApi.valid_login, MesCourses::Stores::Carts::DummyApi.valid_password) do |session|
        session.should_not be_nil
        @dummy_api.log.should include(:login)
      end

      @dummy_api.should_not be_nil
      @dummy_api.log.should include(:logout)
    end

  end

  context "importing all stores" do

    before :each do
      @stores = Array.new(2) { stub_model(Store) }
      @stores.each { |store| store.stub(:import) }
      Store.stub(:all).and_return(@stores)
    end

    it "should import all stores" do
      @stores.each { |store| store.should_receive(:import) }

      Store.import
    end

    it "update the stats first" do
      ModelStat.should_receive(:update!).ordered
      @stores.each { |store| store.should_receive(:import).ordered }

      Store.import
    end

    it "should deliver an import report email with time spent" do
      start_time = Time.local(2011, 10, 29, 16, 30, 24)
      end_time = Time.local(2011, 10, 29, 17, 48, 12)
      MesCourses::Utils::Timing.stub(:now).and_return(start_time, end_time)

      ImportReporter.should_receive(:delta).with(end_time - start_time, anything).and_return(email = stub("Email"))
      email.should_receive(:deliver)

      Store.import
    end

    it "should deliver an import report email" do
      expected_items = 3000
      Store.stub(:maximum).with(:expected_items).and_return(expected_items)

      ImportReporter.should_receive(:delta).with(anything, expected_items).and_return(email = stub("Email"))
      email.should_receive(:deliver)

      Store.import
    end

  end

  it "global import with an url should only import the specified store" do
    url = "http://www.discountagogo.com"

    store = stub_model(Store)
    Store.stub(:find_or_create_by_url).with(url).and_return(store)

    store.should_receive(:import)

    Store.import(url)
  end

end
