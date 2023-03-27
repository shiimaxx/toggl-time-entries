# toggl-time-entries

toggl-time-entries is a command-line tool for registering work hours using Toggl's Time Entries API.

## Usage

```
Usage: toggl-time-entries [options] <filename>
    -b, --billable                   Register time entries as billable
    -w, --workspace-id WORKSPACE_ID  Workspace ID (required)
    -d, --dry-run                    Display parameters only
```

The argument filename is required. Specify a csv file in the following format.

```
description,project_id,start,stop
```

Refer to the following link to understand what the fields represent:
https://developers.track.toggl.com/docs/api/time_entries#post-timeentries

## API token

toggl-time-entries uses API token to authenticate with Toggl API.
Please set the API Token to the environment variable `TOGGL_API_TOKEN`.

see also https://developers.track.toggl.com/docs/authentication#http-basic-auth-with-api-token
