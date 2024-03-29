# Executive Summary

Our IT team has configured a robust logging solution based on open source
tooling.  On Linux, we use *rsyslog* and *auditd* to save all login attempts,
all firewall blocks, the Linux syslog, and various other indicators of
compromise.  On Windows, we use *nxlog* and *Sysmon* to save the Windows Event
Log.  As a log aggregator, we chose *Graylog*, a popular open source solution
that is extensible and very robust.  The logging was configured using
*Ansible*, an open source automation platform created by RedHat.

Attached you will find:

- An explanation of our logging solution
- Screenshots of the logging in action including examples of filtering
- The ansible playbooks we used to configure the logging which includes the log config files

## Log Aggregation

We chose Graylog, built on Elasticsearch and MongoDB, as our log aggregator.
Graylog is an open source powerful log aggregation and SIEM tool with strong 
filtering capabilties.  It is battle tested and trusted by many organizations
and we are confident it will be able to meet our business needs in the future.

To deploy this solution, our team used Ansible, an automation framework built
by RedHat, to deploy the logging solution.  Ansible allows for the automated
management of remote systems using only ssh with instructions written in a
simple yml syntax.  Attached you will find the Ansible playbooks used to
configure logging on both Linux and Windows machines

## Logs Collected

### Linux

On Linux, we use rsyslog to forward our logs to the central Graylog server as
well as collect the Syslog and ufw logs, as well as auditd to keep a record of
every bash command executed on the system.  We log all shell commands both to
have a record of the changes we made to the machine but also to ensure that
any malicious commands are saved, making it very difficult for any attacker to
execute malicious paylods on our machine without large amounts of custom
tooling. Rsyslog is the native Linux solution and comes preinstalled on every
machine we use, with auditd being installed seperately and integrating with
Linux's default auditing capabilities.

### Windows

On Windows, we install the nxlog agent to forward our logs to the central 
Graylog server, Sysmon (with a custom config) to log security critical events,
and the Windows Event Viewer's default log collection capabilities.
Specifically, we collect the following logs:

- Application
- Security
- System
- Sysmon

For Sysmon, we use the SwiftOnSecurity config (url attached below) to filter
the Sysmon logs, which are famously noisy, obtuse, and difficult to understand
on their own.  This config filters this log down to 18 high fidelity indicators
of compromise.

https://github.com/SwiftOnSecurity/sysmon-config
