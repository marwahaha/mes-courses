# -*- encoding: utf-8 -*-
# Copyright (C) 2010, 2011 by Philippe Bourgau

require 'spec_helper'

shared_examples_for "Any MonitoringMailer" do
  extend MonitoringMailerMacros

  before(:each) do
    HerokuHelper.stub(:app_name).and_return("mes-courses-tests")
  end

  def send_monitoring_email(*parameters)
    parameters = @mailer_default_parameters if parameters.empty?

    @emails = ActionMailer::Base.deliveries
    @emails.clear()

    @mailer_class.send(("deliver_" + @mailer_template.to_s).intern, *parameters)

    @email = @emails.last
    @subject = @email.subject
    @body = @email.body
  end

  it "should send a non empty email" do
    send_monitoring_email

    @emails.should have(1).entry
    @email.to.should_not be_empty
  end

  it "should have a subject including the app name" do
    send_monitoring_email

    @subject.should include(HerokuHelper.app_name)
  end
end

module MonitoringMailerMacros

  def should_contain_the_logs
    it "should contain the logs" do
      log_text = "all the long logs"
      HerokuHelper.stub(:safe_heroku_logs).and_return(log_text)

      send_monitoring_email

      @body.should include(log_text)
    end
  end

end
