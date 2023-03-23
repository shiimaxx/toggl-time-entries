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

def post_time_entry(workspace_id, description, project_id, start, stop)
  uri = URI("https://api.track.toggl.com/api/v9/workspaces/#{workspace_id}/time_entries")

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri.path)
  req["Content-Type"] = 'application/json'
  req.body = {
    description: description,
    project_id: project_id.to_i,
    start: start,
    stop: stop,
    created_with: 'https://github.com/shiimaxx/toggl-time-entries',
    wid: workspace_id.to_i,
  }.to_json
  req.basic_auth(TOGGL_API_TOKEN, 'api_token')
  res = http.request(req)
  puts res.body
end

def ensure_utc(datetime_str)
  datetime = Time.parse(datetime_str)
  datetime.utc? ? datetime_str : datetime.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
end

def main
  workspace_id = -1
  OptionParser.new do |opts|
    opts.on('--workspace-id WORKSPACE_ID') { |v| workspace_id = v }
  end.parse(ARGV)  

  filename = ARGV.last

  if workspace_id.nil?
    puts "Workspace ID not provided"
    exit 1
  end

  if !File.exists?(filename)
    puts "File does not exist"
    exit 1
  end

  CSV.foreach(filename) do |row|
    description, project_id, start, stop = row
    puts description, project_id, ensure_utc(start), ensure_utc(stop)
    post_time_entry(workspace_id, description, project_id, ensure_utc(start), ensure_utc(stop))
    sleep 0.5
  end
end

main
