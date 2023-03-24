#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'json'
require 'net/http'
require 'optparse'
require 'time'
require 'uri'

VERSION = '0.1.0'

TOGGL_API_TOKEN = ENV['TOGGL_API_TOKEN']

def post_time_entry(workspace_id, parameters)
  uri = URI("https://api.track.toggl.com/api/v9/workspaces/#{workspace_id}/time_entries")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri.path)
  req["Content-Type"] = 'application/json'
  req.body = parameters.to_json
  req.basic_auth(TOGGL_API_TOKEN, 'api_token')
  res = http.request(req)
  puts res.body
end

def ensure_utc(datetime_str)
  datetime = Time.parse(datetime_str)
  datetime.utc? ? datetime_str : datetime.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
end

def main
  options = {}

  parser = OptionParser.new
  parser.on('-b', '--billable', 'Register time entries as billable') {|v| options[:billable] = v}
  parser.on('-w', '--workspace-id WORKSPACE_ID', 'Workspace ID (required)') {|v| options[:workspace_id] = v.to_i}
  parser.on('-d', '--dry-run', 'Display parameters only') {|v| options[:dry_run] = v}
  argv = parser.parse(ARGV)

  filename = argv[0]

  if options[:workspace_id].nil?
    puts "Workspace ID not provided"
    exit 1
  end

  if !File.exists?(filename)
    puts "File does not exist"
    exit 1
  end

  CSV.foreach(filename) do |row|
    description, project_id, start, stop = row
    parameters = {
      billable: options[:billable].nil? ? false : options[:billable],
      description: description,
      project_id: project_id.to_i,
      start: ensure_utc(start),
      stop: ensure_utc(stop),
      created_with: 'https://github.com/shiimaxx/toggl-time-entries',
      wid: options[:workspace_id],
    }
    if options[:dry_run]
      puts parameters
    else
      post_time_entry(options[:workspace_id], parameters)  
      sleep 0.5
    end
  end
end

main
