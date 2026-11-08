# Wazuh SIEM - Windows Security Log & Logon Failure Detection Lab

This lab demonstrates how Wazuh SIEM monitors, ingests, and analyzes Windows Security event logs to detect repeated authentication failures and brute-force attacks against a Windows endpoint.

## Lab Environment

| Component | Configuration |
| --- | --- |
| Attacker / Simulation Host | Kali Linux or Local Script (`192.168.117.128`) |
| Target Endpoint | Windows 10/11 / Windows Server (`192.168.117.135`) |
| SIEM | Wazuh All-in-One on Ubuntu, Dashboard at `https://192.168.117.132` |
| Agent Name & ID | `windows_endpoint_agt`, ID `002` |
| Log Source / Channel | Windows Event Log: `Security` |
| Monitored Event IDs | Event ID `4625` (Logon Failure), Event ID `4624` (Logon Success) |

## Setup and Reproduction

### 1. Install Wazuh Agent on Windows

Open PowerShell as **Administrator** on the Windows machine and run the automated deployment script:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install_wazuh_agent.ps1
```

Or install manually via command prompt / PowerShell:

```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.0-1.msi -OutFile wazuh-agent.msi
msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER="192.168.117.132" WAZUH_AGENT_NAME="windows_endpoint_agt"
Start-Service -Name "WazuhSvc"
```

Verify in the Wazuh Dashboard that the Windows agent shows an **Active** status.

### 2. Verify Audit Policy Configuration

Ensure that Windows is configured to audit failed logon attempts:

```powershell
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
```

Verify current policy settings:

```powershell
auditpol /get /subcategory:"Logon"
```

### 3. Run Attack / Logon Failure Simulation

Execute the simulation script on the target or from an external machine on the same subnet:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\attack_simulation.ps1
```

The script sends repeated failed authentication requests across SMB / Local IPC to generate Event ID `4625` in the Windows Security Log.

### 4. Investigate Alerts in Wazuh Dashboard

1. Navigate to **Threat Hunting -> Events**.
2. Filter for the Windows agent:
   ```text
   agent.name:"windows_endpoint_agt" AND data.win.system.eventID:4625
   ```
3. To view correlated brute-force alerts:
   ```text
   agent.name:"windows_endpoint_agt" AND rule.id:(60115 OR 60204)
   ```
4. Consult [wazuh_queries.md](queries/wazuh_queries.md) for additional queries.

## Results and MITRE ATT&CK Analysis

Wazuh detects individual failed logon events and aggregates them into high-severity brute-force alerts:

| Alert Field | Individual Failure | Correlated Brute Force |
| --- | --- | --- |
| `rule.id` | `60122` | `60115` / `60204` |
| `rule.level` | `5` | `10` |
| `rule.description` | Logon Failure - Unknown user name or bad password | Multiple Windows Logon Failures |
| `rule.mitre.id` | `T1110.001` | `T1110` |
| `rule.mitre.tactic` | `Credential Access` | `Credential Access` |
| `rule.mitre.technique` | `Password Guessing` | `Brute Force` |

## Evidence and Screenshots

> Place evidence screenshots from your lab in the `images/` directory and update the references below.

### 1. Windows Event Viewer (Event ID 4625)
![Windows Security Event Log 4625](images/windows_event_log.png)
*Figure 1: Windows Security log recording Event ID 4625 (Audit Failure) with target account name and status codes.*

### 2. Wazuh Threat Hunting Dashboard
![Wazuh Threat Hunting Dashboard](images/dashboard.png)
*Figure 2: Overview of Windows events and alert severity distribution.*

### 3. Correlated Alert Details
![Alert Details in Wazuh](images/doc_detail_event4625.png)
*Figure 3: Wazuh alert details displaying Rule 60115 / 60122, MITRE ATT&CK mapping T1110, and parsed event fields.*

