#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest/md5'

namespace :rpg do
  desc 'Parse CIS profile JSON result for either Positive or Negative test runs. A txt file will then be generated with which controls passed/failed/skipped/excluded. The results will then be compared to a "Golden" copy to verify the results are as expected.'
  task :check_results, [:log_name, :result_file_name] do |_t, args|
    log_name = args[:log_name]
    result_file_name = args[:result_file_name]

    ruby "scripts/parse_results.rb -l #{log_name}"

    log_md5 = Digest::MD5.hexdigest(File.read("results/#{log_name}.txt"))

    puts 'checking log md5 to verify the results match'
    expected_log_md5 = Digest::MD5.hexdigest(File.read("results/#{result_file_name}.txt"))
    if log_md5 == expected_log_md5
      puts 'pass: log files match'
    else
      puts 'FAIL: md5sums do not match...'
      puts "#{log_name}.txt md5: #{log_md5}"
      puts "#{result_file_name}.txt md5: #{expected_log_md5}"
      puts 'File diff:'
      puts `diff results/#{log_name}.txt results/#{result_file_name}.txt`
      exit 1
    end
  end
end
