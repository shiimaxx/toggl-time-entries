# toggl-time-entries

toggl-time-entries is a command-line tool for registering work hours using Toggl's Time Entries API.

## Usage

```
toggl-time-entries --workspace-id <workspace id> filename
```

The argument filename is required. Specify a csv file in the following format.

```
description,project_id,start,stop
```

Refer to the following link to understand what the fields represent:
https://developers.track.toggl.com/docs/api/time_entries#post-timeentries
