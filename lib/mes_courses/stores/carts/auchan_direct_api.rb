# -*- encoding: utf-8 -*-
# Copyright (C) 2011, 2012, 2013 by Philippe Bourgau

require_relative 'api'
require 'json'

module MesCourses
  module Stores
    module Carts

      # Store API for AuchanDirect store
      class AuchanDirectApi < Api

        FORMDATA_PARAMETER = 't:formdata'
        LOGIN_PARAMETER = 'inputLogin'
        PASSWORD_PARAMETER = 'inputPwd'

        # main url of the store
        def self.url
          "http://www.auchandirect.fr"
        end

        # Logins to auchan direct store
        def initialize(login, password)
          @agent = Mechanize.new
          do_login(login, password)
          raise InvalidAccountError unless logged_in?
        end

        # html form for a client browser to login
        def self.login_form_html
          buffers = []

          buffers << "<form action=\"#{login_url}\" method=\"post\" id=\"authenticateForm\" name=\"authenticateForm\">"

          post_parameters.merge(FORMDATA_PARAMETER => login_form_data(Mechanize.new)).each do |name, value|
            buffers << input_tag_html('hidden', name, value)
          end

          buffers << input_tag_html('text', LOGIN_PARAMETER)
          buffers << input_tag_html('password', PASSWORD_PARAMETER)

          buffers << "<input value=\"Allez-y !\" id=\"authenticateFormSubmit\" type=\"submit\"/>"
          buffers << "</form>"

          buffers.join.html_safe
        end
        def self.input_tag_html(type, name, value = '')
           "<input value=\"#{value}\" name=\"#{name}\" type=\"#{type}\"/>"
        end

        # url at which a client browser can logout
        def self.logout_url
          url + logout_path
        end

        # logs out from the store
        def logout
          get(self.class.logout_path)
        end

        # total value of the remote cart
        def cart_value
          cart_page = get("/monpanier")
          cart_page.search("span.prix-total").first.content.gsub(/€$/,"").to_f
        end

        # empties the cart of the current user
        def empty_the_cart
          post("/boutiques.blockzones.popuphandler.cleanbasketpopup.cleanbasket")
        end

        # adds items to the cart of the current user
        def add_to_cart(quantity, item_remote_id)
          quantity.times do
            post("/boutiques.mozaique.thumbnailproduct.addproducttobasket/#{item_remote_id}")
          end
        end

        private

        def do_login(login,password)
          formdata = login_form_data(@agent)

          post(login_path,
               FORMDATA_PARAMETER => formdata,
               LOGIN_PARAMETER => login,
               PASSWORD_PARAMETER => password)
        end

        def self.login_path
          "/boutiques.blockzones.popuphandler.authenticatepopup.authenticateform"
        end

        def self.login_url
          url + login_path
        end

        def self.login_form_data(agent)
          home_page = agent.get(AuchanDirectApi.url)

          login_form_json = post(agent, "/boutiques.paniervolant.customerinfos:showsigninpopup", {}, {'Referer' => home_page.uri})

          html_body = JSON.parse(login_form_json.body)["zones"]["secondPopupZone"]
          doc = Nokogiri::HTML("<html><body>#{html_body}</body></html>")
          doc.xpath("//input[@name='#{FORMDATA_PARAMETER}']/@value").first.content
        end

        def logged_in?
          main_page = get("/Accueil")
          !main_page.body.include?("Identifiez-vous")
        end

        def get(path)
          @agent.get(url + path)
        end

        def post(path, parameters = {}, headers = {})
          self.class.post(@agent, path, parameters, headers)
        end

        def self.post(agent, path, parameters = {}, headers = {})
          agent.post(url + path, post_parameters.merge(parameters), fast_header.merge(headers))
        end

        def self.fast_header
          {'X-Requested-With' => 'XMLHttpRequest'}
        end

        def self.logout_path
          parametrized_path("/boutiques.paniervolant.customerinfos:totallogout", post_parameters)
        end

        def self.parametrized_path(path, parameters)
          string_parameters = parameters.map do |key,value|
            "#{key}=#{value}"
          end
          "#{path}?#{string_parameters.join('&')}"
        end

        def self.post_parameters
          {'t:ac' => "Accueil", 't:cp' => 'gabarit/generated'}
        end

        def method_missing(method_sym, *arguments, &block)
          if delegate_to_class?(method_sym)
            self.class.send(method_sym, *arguments, &block)
          else
            super
          end
        end

        def respond_to?(method_sym)
          super or delegate_to_class?(method_sym)
        end
        def delegate_to_class?(method_sym)
          self.class.respond_to?(method_sym)
        end
      end
    end
  end
end
