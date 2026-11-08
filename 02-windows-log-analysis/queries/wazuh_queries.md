# Wazuh Threat Hunting Queries - Windows Security

Use these queries in **Threat Hunting -> Events** on the Wazuh Dashboard. Remember to adjust the time range filter to cover the execution time of the simulation.

## 1. Filter Windows Agent

Isolate events originating specifically from the Windows endpoint:

```text
agent.name:"windows_endpoint_agt"
```

## 2. All Logon Failure Events (Event ID 4625)

Display all logon failure events captured from the Windows Security channel:

```text
agent.name:"windows_endpoint_agt" AND data.win.system.eventID:4625
```

## 3. Single Logon Failure Rule (Rule 60122)

Query for individual logon failure alerts (Level 5):

```text
agent.name:"windows_endpoint_agt" AND rule.id:60122
```

## 4. Correlated Multiple Logon Failures (Brute Force Alert)

Query for correlated threshold alerts triggered by multiple consecutive failed attempts (Level 10):

```text
agent.name:"windows_endpoint_agt" AND rule.id:(60115 OR 60204)
```

## 5. Filter by Target Account Name

Isolate failed logon attempts targeting a specific username (e.g., `Administrator`):

```text
agent.name:"windows_endpoint_agt" AND data.win.eventdata.targetUserName:"Administrator"
```

## 6. Filter by Source Network Address

Find failed logon attempts originating from a specific IP address (e.g., attacker IP):

```text
agent.name:"windows_endpoint_agt" AND data.win.eventdata.ipAddress:"192.168.117.128"
```

