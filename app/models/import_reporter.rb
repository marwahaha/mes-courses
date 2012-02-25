# -*- encoding: utf-8 -*-
# Copyright (C) 2011, 2012 by Philippe Bourgau

require 'action_view/helpers/number_helper'
require 'time_span_helper'

# Object responsible for mailing an import report
class ImportReporter < MonitoringMailer
  include ActionView::Helpers::NumberHelper
  include HerokuHelper

  # Reports delta from latest statistics by mail and log
  # def self.deliver_delta

  private

  def generate_subject(delta_stats, expected_items)
    item_stats = delta_stats[ModelStat::ITEM]
    "Import #{result(item_stats, expected_items)} #{pretty_delta(item_stats)}"
  end

  def result(record_stats, expected_items)
    expected_items ||= 0
    delta = record_stats[:delta]

    if record_stats[:count] < expected_items
      "WARNING expected #{expected_items} items"
    elsif delta.nil?
      "OK first time"
    elsif (delta-1).abs < 0.05
      "OK"
    else
      "WARNING"
    end
  end

  def pretty_delta(item_stats)
    delta = item_stats[:delta]
    if delta.nil?
      "+#{item_stats[:count]} records"
    else
      result = number_to_percentage(100 * (delta - 1), :precision => 2, :separator => '.')
      if 1 <= delta
        result = '+' + result
      end
      result
    end
  end

  # mailer template function
  def delta(import_duration_seconds, expected_items)
    delta_stats = ModelStat.generate_delta
    subject = generate_subject(delta_stats, expected_items)

    setup_mail(subject, :content => generate_body(delta_stats, import_duration_seconds))
  end

  def generate_body(delta_stats, import_duration_seconds)
    lines = ModelStat::ALL.map do |record_type|
      record_stats = delta_stats[record_type]
      "#{record_type}: #{record_stats[:old_count]} -> #{record_stats[:count]} #{pretty_delta(record_stats)}"
    end

    lines.push("Import took : #{import_duration_seconds.to_pretty_duration}")
    lines.push("Logs : #{safe_heroku_logs}}")

    lines.join("\n")
  end

end
