#!/bin/bash

set -x
set -e

id=`ss-get id`
nodename=`ss-get nodename`
node_instance_name=${nodename}.${id}

yum install -y \
    collectd \
    collectd-write_riemann

cat > /etc/collectd.conf <<EOF
Hostname    "$node_instance_name"
BaseDir     "/var/lib/collectd"
PIDFile     "/var/run/collectd.pid"
PluginDir   "/usr/lib64/collectd"

Interval 10.0

LoadPlugin logfile
<Plugin logfile>
       LogLevel info
       File "/var/log/collectd.log"
       Timestamp true
       PrintSeverity true
</Plugin>

<LoadPlugin load>
  Interval 10.0
</LoadPlugin>

Include "/etc/collectd.d"
EOF

riemann_host=`ss-get autoscaler_hostname`
riemann_port=5555

# Riemann ready synchronization flag!
ss-display "Waiting for Riemann to be ready."
ss-get --timeout 600 autoscaler_ready

cat >/etc/collectd.d/write_riemann.conf<<EOF
LoadPlugin write_riemann

<Plugin "write_riemann">
    <Node "local">
        Host "$riemann_host"
        Port "$riemann_port"
        Protocol UDP
        StoreRates true
        AlwaysAppendDS false
    </Node>
    Tag "$nodename"
    Attribute "node-name" "$nodename"
    Attribute "instance-id" "$id"
</Plugin>

<Target "write">
    Plugin "write_riemann/local"
</Target>
EOF

systemctl enable collectd
systemctl start collectd

ss-display "Sending metrics to Riemann: $riemann_host:$riemann_port"

