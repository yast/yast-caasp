# AutoYaST support

When using Containers as a Service Platform (CaaSP), AutoYaST profiles for
workers can be generated using the `caasp-tools` package. However, that's not
the case for dashboard systems.

To properly set up a dashboard system using AutoYaST, the `activate.sh` script
should be run at the end of the installation. So don't forget to add the following
snippet to your AutoYaST profile:

```xml
<scripts>
  <chroot-scripts config:type="list">
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
</scripts>
```
