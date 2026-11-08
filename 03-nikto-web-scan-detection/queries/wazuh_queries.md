# Wazuh Threat Hunting Queries - Web Attack & Scanning

Use these queries in **Threat Hunting -> Events** on the Wazuh Dashboard to isolate and inspect web scanning alerts.

## 1. Filter Target Web Server Agent

Select events from the agent hosting the web service:

```text
agent.name:"ubuntu_webserver2_agt"
```

## 2. All Web Server Events (Group Filter)

Filter all alerts categorized under the `web` and `accesslog` rule groups:

```text
agent.name:"ubuntu_webserver2_agt" AND rule.groups:"web"
```

## 3. Nikto Scanner Detection (Rule 31101)

Isolate the specific alert triggered by Nikto's User-Agent string:

```text
agent.name:"ubuntu_webserver2_agt" AND rule.id:31101
```

## 4. Web Attack - High Volume 400 Series Errors (Rule 31106)

Query for bursts of HTTP 400/404 errors caused by directory probing and fuzzing:

```text
agent.name:"ubuntu_webserver2_agt" AND rule.id:31106
```

## 5. Filter by Attacker Source IP

Isolate all web events originating from the attacker machine (Kali Linux):

```text
agent.name:"ubuntu_webserver2_agt" AND rule.groups:"web" AND data.srcip:"192.168.117.128"
```

