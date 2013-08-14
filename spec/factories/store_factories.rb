# -*- encoding: utf-8 -*-
# Copyright (C) 2010, 2011, 2012, 2013 by Philippe Bourgau

FactoryGirl.define do

  sequence :url do |n|
    "http://www.unhandled-store-#{n}.com"
  end

  factory :store do
    url MesCourses::Stores::DummyConstants::STORE_URL
    sponsored_url MesCourses::Stores::DummyConstants::SPONSORED_URL

    trait :unhandled do
      url
      sponsored_url { "#{url}/sponsored" }
    end

  end

end
