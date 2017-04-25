# AutoYaST support

When using Containers as a Service Platform (CaaSP), AutoYaST profiles for
workers can be generated using the `caasp-tools` package. However, that's not
the case for dashboard systems.

To properly set up a dashboard system using AutoYaST, some additional tweaks are
needed. Most of them can be achieved by running some small scripts at the end of
the installation (and before the 1st boot) adding them to the
`scripts/chroot-scripts` section.

```xml
<scripts>
  <chroot-scripts config:type="list">
  <!-- put scripts here -->
  </chroot-scripts>
</scripts>
```

## Running the `activate.sh` script

To set up a dashboard system, the `activate.sh` script should be run at the end
of the installation. It can be done by simply adding this script to the
`chroot-scripts` section:

```xml
  <script>
    <chrooted config:type="boolean">true</chrooted>
    <filename>activate.sh</filename>
    <interpreter>shell</interpreter>
    <source><![CDATA[
#!/bin/sh
/usr/share/caasp-container-manifests/activate.sh
]]>
    </source>
  </script>
</chroot-scripts>
```

## Configuring the NTP server

The dashboard system will act as NTP server for cluster workers. By default, the
NTP configuration shipped with SUSE allows workers to synchronize with the
dashboard. However, no remote time source is set.

To do that, is enough with adding `server` lines to the current configuration.
Again, an AutoYaST script will do the trick:

```xml
<chroot-scripts config:type="list">
  <script>
    <chrooted config:type="boolean">true</chrooted>
    <filename>configure-ntpd.sh</filename>
    <interpreter>shell</interpreter>
    <source><![CDATA[
#!/bin/sh
sed '/^server/d' -i /etc/ntp.conf
for server in server1 server2 server3
do
  echo "server ${server} iburst" >> /etc/ntp.conf
done
systemctl enable ntpd
]]>
    </source>
  </script>
</chroot-scripts>
```

Replace the list of servers (`server1 server2 server3`) for your own NTP servers.
