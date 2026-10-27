# Wazuh Threat Hunting Queries

This document contains the specific queries used in the Wazuh Dashboard (Threat Hunting -> Events) to analyze the Brute-force attack.

## 1. Filter by Specific Agent
Use this to isolate logs coming only from the target Ubuntu machine.
```text
agent.name:"ubuntu_webserver2_agt"
```

## 2. Isolate SSH Authentication Failures
Use this to filter out generic PAM logs and focus strictly on SSH attacks (this hides Rule 5557 and shows Rule 5760/5763).
```text
agent.name:"ubuntu_webserver2_agt" AND rule.groups:"sshd"
```

## 3. Find High-Severity Brute Force Alerts (Level 10)
Use this to find the exact moment Wazuh triggered the Brute Force alert.
```text
rule.id:5763 OR rule.level:10
```

## 4. Investigate Invalid Users
If the attacker uses a non-existent username (e.g., admin), use this to find it.
```text
rule.groups:"sshd" AND "invalid user"
```
