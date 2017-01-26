# check_snmp_proc.sh
## This is small Nagios plugin for checking status of processes (or quantity of them) via SNMP</H5>

This plugin uses the [utils.sh from monitoring-plugins.org](https://github.com/monitoring-plugins/monitoring-plugins/blob/v2.2/plugins-scripts/utils.sh.in) to be able to use ranges for warning and critical thresholds.

### Usage:
```
./check_snmp_proc -H 127.0.0.1 -C public -N ssh -w 3 -c 0

Where:
  -H hostname /string/
     Name or IP address of host (default 127.0.0.1)
  -C OID /string/
     Community name for the host SNMP agent (default public)
  -N Process name /string/
     Exact process name (default snmpd)
  -w warning level /integer/
     Warning level of running processes (default: 0)
  -c critical level /integer/
     Critical level of running processes (default: 0)
  -m minimum level /integer/
     Minimum level for performance data (default: 0)
  -M maximum level /integer/
     Maximum level for performance data (default: 100)
  -h help
     Print this help screen
  -V version number
     Print version and license information </dd>

  This plugin uses the 'snmpwalk' command included with the NET-SNMP package.
  This nagios plugins comes with ABSOLUTELY NO WARRANTY. So, enjoy ;)
```
### Icinga2 Configuration
```
object CheckCommand "snmp_proc" {
  import "plugin-check-command"

  command = [ PluginGitDir + "/check_snmp_proc.sh" ]

  arguments = {
    "-H" = {
      value = "$snmp_proc_host$"
      description = "Name or IP address of host (default 127.0.0.1 but overwritten by address)"
      required = false
      skip_key = false
      order = 1
    }
    "-C" = {
      value = "$snmp_proc_community$"
      description = "Community name for the host SNMP agent (default public)"
      required = false
      skip_key = false
      order = 2
    }
    "-N" = {
      value = "$snmp_proc_name$"  
      description = "Exact process name (default snmpd)"
      required = false
      skip_key = false
      order = 3
    }
    "-w" = {
      value = "$snmp_proc_warning$"
      description = "Warning level of running processes (default: 0)"
      required = false
      skip_key = false
      order = 4
    }
    "-c" = {
      value = "$snmp_proc_critical$"
      description = "Critical level of running processes (default: 0)"
      required = false
      skip_key = false
      order = 5
    }
    "-m" = {
      value = "$snmp_proc_min$"
      description = "Minimum for performance data (default: 0)"
      required = false
      skip_key = false
      order = 6
    }
    "-M" = {
      value = "$snmp_proc_max$"
      description = "Maximum for performance data (default: 100)"
      required = false
      skip_key = false
      order = 7
    }
  }

  vars.snmp_proc_host = "$address$"
}

```


```
apply Service for (snmp_proc => config in host.vars.snmp_proc) {
  import "generic-service"

  check_command = "snmp_proc"

  display_name = config.display_name

  if (config.groups) {
    groups = config.groups
  }

  if (config.check_interval) {
    check_interval = config.check_interval
  }

  if (config.retry_interval) {
    retry_interval = config.retry_interval
  }

  if (config.max_check_attempts) {
    max_check_attempts = config.max_check_attempts
  }

  vars += config
}
```

```
object Host "snmphost.test" {
  import "generic-host"
  display_name = "SNMP Test Host"
  address = "127.0.0.1"

  vars.snmp_proc[ "service_name" ] = {
    display_name = "Check SNMP service via SNMP process list"

#    snmp_proc_community = "public"
    snmp_proc_name = "snmp"
    snmp_proc_warning = "40"
    snmp_proc_critical = "40"

#    check_interval = 10m
#    retry_interval = 10m
    max_check_attempts = 1
  }

}
```


