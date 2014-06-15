# -*- encoding: utf-8 -*-
# Copyright (C) 2011, 2012, 2013, 2014 by Philippe Bourgau
# http://philippe.bourgau.net

# This file is part of mes-courses.

# mes-courses is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


require 'auchandirect/scrAPI'

module MesCourses
  module Stores
    module Carts

      class Api

        # factory of store cart api for a given url
        def self.for_url(store_url)
          if store_url == Auchandirect::ScrAPI::Cart.url
            Auchandirect::ScrAPI::Cart
          elsif store_url.include?(Auchandirect::ScrAPI::DummyCart.url)
            Auchandirect::ScrAPI::DummyCart
          else
            raise ArgumentError.new("No store api found for store at '#{store_url}'")
          end
        end
      end
    end
  end
end
