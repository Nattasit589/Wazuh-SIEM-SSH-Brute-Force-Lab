# Wazuh Threat Hunting Queries

Use these queries in **Threat Hunting -> Events**. Select the test's time range and account for VM/dashboard time zones. The latest screenshots use agent `ubuntu_webserver2_agt`; the selected SSH alert records source IP `192.168.117.128` and destination user `root`.

## 1. Target Agent

This is the agent filter visible in the latest dashboard screenshot.

```text
agent.name:"ubuntu_webserver2_agt"
```

## 2. SSH Events

This is the filter visible in `Event_Log.png`. It selects SSH-group alerts and excludes generic PAM-only events such as Rule `5557`. It includes more than authentication failures: the screenshot also shows Rule `5758` for exceeded authentication attempts.

```text
agent.name:"ubuntu_webserver2_agt" AND rule.groups:"sshd"
```

## 3. Correlated Brute Force Alert

This additional query isolates Rule `5763` for the target agent. The latest selected document has Level `10` and MITRE `T1110 - Brute Force`. Searching for every Level `10` alert would also include unrelated rules.

```text
agent.name:"ubuntu_webserver2_agt" AND rule.id:5763
```

## 4. Individual SSH Authentication Failures

This additional query isolates Rule `5760` (Level `5`). In the Wazuh 4.14 ruleset, this rule includes MITRE `T1110.001 - Password Guessing`; that is separate from the `T1110` mapping displayed on Rule `5763`.

```text
agent.name:"ubuntu_webserver2_agt" AND rule.id:5760
```

## 5. Source IP and Target Account

Use this additional query to narrow the SSH alerts to the source and destination-user fields visible in `Doc_Detail1.png`.

```text
agent.name:"ubuntu_webserver2_agt" AND rule.groups:"sshd" AND data.srcip:"192.168.117.128" AND data.dstuser:"root"
```

## 6. Optional Investigation of Invalid Users

The latest Hydra run targets `root`. For a separate test with the course exercise's nonexistent account, use this query; it is not evidence of the latest run.

```text
agent.name:"ubuntu_webserver2_agt" AND rule.groups:"sshd" AND full_log:"nonexistent"
```
