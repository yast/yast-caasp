# System Roles Handlers

This package contains handlers for *Dashboard* and *Worker* system roles.

## Dashboard role

A system which is designed as the dashboard will need to run the special script `/usr/share`
`/usr/share/caasp-container-manifests/activate.sh`. That script will take care of
doing some final configuration and enabling some services.

## Worker role

When installing a system with this role, the Salt minion will be configured to
use a master server specified by the user. The file `/etc/salt/minion.d/master`
will be created (or updated if it exists) using the given value.
