require 'csv'
require 'json'
require 'net/http'
require 'optparse'
require 'time'
require 'uri'

TOGGL_API_TOKEN = ENV['TOGGL_API_TOKEN']

module TogglTimeEntries
  class CLI

    def initialize(argv)
      @argv = argv
    end

    def get_project_name(workspace_id, project_id)
      if project_id.nil?
        return ''
      end

      uri = URI("https://api.track.toggl.com/api/v9/workspaces/#{workspace_id}/projects/#{project_id}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(uri.path)
      req["Content-Type"] = 'application/json'
      req.basic_auth(TOGGL_API_TOKEN, 'api_token')

      begin
        res = http.request(req)
        JSON.parse(res.body)['name']
      rescue
        project_id
      end
    end

    def post_time_entry(workspace_id, parameters)
      uri = URI("https://api.track.toggl.com/api/v9/workspaces/#{workspace_id}/time_entries")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.path)
      req["Content-Type"] = 'application/json'
      req.body = parameters.to_json
      req.basic_auth(TOGGL_API_TOKEN, 'api_token')
      res = http.request(req)
      res.body
    end

    def utc(datetime)
      datetime.utc? ? datetime : datetime.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    def run
      options = {}

      parser = OptionParser.new
      parser.on('-b', '--billable', 'Register time entries as billable') {|v| options[:billable] = v}
      parser.on('-w', '--workspace-id WORKSPACE_ID', 'Workspace ID (required)') {|v| options[:workspace_id] = v.to_i}
      parser.on('-d', '--dry-run', 'Display parameters only') {|v| options[:dry_run] = v}
      argv = parser.parse(@argv)

      filename = argv[0]

      if options[:workspace_id].nil?
        puts "Workspace ID not provided"
        exit 1
      end

      if !File.exist?(filename)
        puts "File does not exist"
        exit 1
      end

      total_time = 0
      time_entries = {}
      CSV.foreach(filename) do |row|
        description, project_id, date, start_at, end_at = row

        year, month, day = date.split('-').map(&:to_i)
        local_time = Time.local(year, month, day)
        start, stop = Time.parse(start_at, local_time), Time.parse(end_at, local_time)

        if time_entries.key?(start.strftime('%F'))
          time_entries[start.strftime('%F')].push({description: description, project_id: project_id, start: start, stop: stop})
        else
          time_entries[start.strftime('%F')] = [{description: description, project_id: project_id, start: start, stop: stop}]
        end
      end

      weekly_total = 0
      time_entries.each do |date, entries|
        puts "#{date}"
        entries.each do |entry|
          duration = entry[:stop] - entry[:start]
          total_time += duration
          weekly_total += duration
          project_name = get_project_name(options[:workspace_id], entry[:project_id])

          puts "#{entry[:description]}\t#{project_name}\t#{entry[:start].strftime('%H:%M')} - #{entry[:stop].strftime('%H:%M')}\t%02<hours>d:%02<minutes>d:%02<seconds>d" % {hours: duration / 3600, minutes: duration / 60 % 60, seconds: duration % 60}

          unless options[:dry_run]
            parameters = {
              billable: options[:billable].nil? ? false : options[:billable],
              description: entry[:description],
              start: utc(entry[:start]),
              stop: utc(entry[:stop]),
              created_with: 'https://github.com/shiimaxx/toggl-time-entries',
              wid: options[:workspace_id],
            }
            parameters[:project_id] = entry[:project_id].to_i unless entry[:project_id].nil?
            post_time_entry(options[:workspace_id], parameters)
            sleep 0.5
          end
        end
        puts ''
      end

      puts "-" * 80
      hours = total_time / 3600
      minutes = total_time / 60 % 60
      seconds = total_time % 60
      puts "TOTAL HOURS: %02<hours>d:%02<minutes>d:%02<seconds>d" % {hours: hours, minutes: minutes, seconds: seconds}
    end
  end
end
