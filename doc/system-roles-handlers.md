# System Roles Handlers

This package contains handlers for *Dashboard* and *Worker* system roles.

## Dashboard role

A system which is designed as the dashboard will need to run the special script `/usr/share`
`/usr/share/caasp-container-manifests/activate.sh`. That script will take care of
doing some final configuration and enabling some services.

## Worker role

When installing a system with this role, a master server will be specified by the user.

The Salt minion will be configured using that master server, which means that the file
`/etc/salt/minion.d/master` will be created (or updated if it exists) using the given value.

The master server will be used also as a ntp server. The handler will configure systemd timesyncd
as the ntp client modifying the `/etc/systemd/timesyncd` NTP attribute with the given value.
