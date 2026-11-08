# Wazuh SIEM - Nikto Web Vulnerability Scan Detection Lab

This lab demonstrates how Wazuh SIEM detects active web reconnaissance and automated vulnerability scanning performed by Nikto against an Apache web server endpoint.

## Lab Environment

| Component | Configuration |
| --- | --- |
| Attacker | Kali Linux (`192.168.117.128`) with Nikto v2.5.0 |
| Target Endpoint | Ubuntu Server with Apache2 (`192.168.117.131:80`) |
| SIEM | Wazuh All-in-One on Ubuntu, Dashboard at `https://192.168.117.132` |
| Agent Name & ID | `ubuntu_webserver2_agt`, ID `001` |
| Log Source | `/var/log/apache2/access.log` (Apache combined/common format) |
| Monitored Protocol | HTTP (Port 80) |

## Setup and Reproduction

### 1. Set Up Web Server and Enable Log Collection

On the target Ubuntu endpoint, run the web server setup script to install Apache2 and ensure log forwarding is enabled in `/var/ossec/etc/ossec.conf`:

```bash
bash scripts/setup_webserver.sh
```

Verify that the Apache access log block exists in `/var/ossec/etc/ossec.conf`:

```xml
<localfile>
  <log_format>apache</log_format>
  <location>/var/log/apache2/access.log</location>
</localfile>
```

Restart the Wazuh Agent service if modified:
```bash
sudo systemctl restart wazuh-agent
sudo systemctl status wazuh-agent --no-pager
```

### 2. Execute Nikto Web Scan from Attacker VM

On Kali Linux, run the automated scan helper script:

```bash
bash scripts/run_nikto_scan.sh
```

Or execute Nikto directly against the target web server:

```bash
nikto -h http://192.168.117.131 -Tuning 1,2,3
```

### 3. Check Apache Access Logs on Target

Verify that incoming scan requests from Nikto are recorded in the Apache access log:

```bash
sudo tail -n 30 /var/log/apache2/access.log
```

You will observe requests containing the `Nikto` user-agent and repeated probing for common paths.

### 4. Investigate Alerts in Wazuh Dashboard

1. Open **Threat Hunting -> Events**.
2. Filter for the web server agent and web rule group:
   ```text
   agent.name:"ubuntu_webserver2_agt" AND rule.groups:"web"
   ```
3. To view the specific Nikto detection alert:
   ```text
   agent.name:"ubuntu_webserver2_agt" AND rule.id:31101
   ```
4. Consult [wazuh_queries.md](queries/wazuh_queries.md) for more query examples.

## Results and MITRE ATT&CK Analysis

Wazuh detects the scanner User-Agent and monitors the sudden influx of HTTP 400-series client errors:

| Alert Field | Nikto Scanner Detected | HTTP 400 Series Error Burst |
| --- | --- | --- |
| `rule.id` | `31101` | `31106` |
| `rule.level` | `6` | `6` |
| `rule.description` | `Nikto web scanner detected.` | `Web attack: 400 series error codes from single source.` |
| `rule.mitre.id` | `T1595.002` | `T1595.002` |
| `rule.mitre.tactic` | `Reconnaissance` | `Reconnaissance` |
| `rule.mitre.technique` | `Active Scanning: Vulnerability Scanning` | `Active Scanning: Vulnerability Scanning` |

## Evidence and Screenshots

> Place evidence screenshots from your lab in the `images/` directory and update the references below.

### 1. Nikto Scanner Terminal Run
![Nikto scan output on Kali Linux](images/nikto_terminal.png)
*Figure 1: Nikto terminal output scanning the target web server and identifying server headers and paths.*

### 2. Wazuh Threat Hunting Events
![Wazuh Threat Hunting Web Alerts](images/events.png)
*Figure 2: Events showing Rule 31101 (Nikto web scanner detected) and Rule 31106.*

### 3. Alert Document Details & MITRE Mapping
![Alert Document Details](images/document_details.png)
*Figure 3: Selected alert document displaying client IP, request URI, User-Agent, and MITRE ATT&CK T1595.002 mapping.*

