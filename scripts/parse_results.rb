#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: create human readable inspec results file [options]'
  opts.on('-lLOG_NAME', '--log_name=LOG_NAME', 'The name of the inspec json log file') do |l|
    options[:log_name] = l
  end
end.parse!
abort('Provide inspec json results file name!') unless options[:log_name]

puts "reading file: results/#{options[:log_name]}.json"
file = File.read("results/#{options[:log_name]}.json")
content = JSON.parse(file)
control_results = {}
content['profiles'].each do |profile|
  profile['controls'].each do |control|
    id = control['id']
    result = control['results'].map { |res| res['status'] }
    control_results[id] = if result.include?('failed')
                            'failed'
                          elsif result.include?('passed')
                            'passed'
                          elsif result.include?('skipped')
                            'skipped'
                          else
                            'excluded'
                          end
  end
end

def write_results(control_results, out_file, type)
  out_file.puts("#{type.capitalize} controls:")
  if control_results.value?(type)
    controls = control_results.select { |_, value| value == type }.keys
    out_file.puts(controls.sort)
    out_file.puts("Total #{type} controls: #{controls.count}", '')
  else
    out_file.puts("Total #{type} controls: 0\n", '')
  end
end

out_file = File.new("results/#{options[:log_name]}.txt", 'w')
write_results(control_results, out_file, 'passed')
write_results(control_results, out_file, 'skipped')
write_results(control_results, out_file, 'failed')
write_results(control_results, out_file, 'excluded')
