# toggl-time-entries

toggl-time-entries is a command-line tool for registering work hours using Toggl's Time Entries API.

## Installation

## Usage

```
Usage: toggl-time-entries [options] <filename>
    -b, --billable                   Register time entries as billable
    -w, --workspace-id WORKSPACE_ID  Workspace ID (required)
    -d, --dry-run                    Display parameters only
```

The argument filename is required. Specify a csv file in the following format.

```
description,project_id,YYYY-MM-DD,hh:mm,hh:mm
```

## API token

toggl-time-entries uses API token to authenticate with Toggl API.
Please set the API Token to the environment variable `TOGGL_API_TOKEN`.

see also https://developers.track.toggl.com/docs/authentication#http-basic-auth-with-api-token

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
