# Wazuh SIEM - SSH Brute Force Detection Lab

## 📌 Project Overview
This repository documents an academic/home lab project focused on deploying an open-source SIEM (Wazuh) and performing threat hunting to detect an SSH Brute-force attack on a Linux endpoint. 

The goal of this lab is to simulate a real-world attack scenario, capture the generated security logs, and analyze the alerts using the MITRE ATT&CK framework.

## 🏗️ Architecture
- **Attacker Machine:** Kali Linux (Using Hydra)
- **Target Endpoint:** Ubuntu Server (Wazuh Agent Installed)
- **SIEM Server:** Ubuntu Server (Wazuh Manager, Indexer, Dashboard)

## 🚀 Lab Setup & Execution

### 1. SIEM Deployment
Deployed the Wazuh All-in-One server on an Ubuntu VM. Configured the firewall to allow HTTPS (Port 443) access to the dashboard.
*(See `scripts/install_wazuh_server.sh`)*

### 2. Agent Deployment
Installed and configured the Wazuh Agent on the target Ubuntu server, connecting it to the Wazuh Manager.
*(See `scripts/install_wazuh_agent.sh`)*

### 3. Attack Simulation
Simulated an SSH Brute-force attack from Kali Linux targeting the Ubuntu endpoint. A custom 15-line dictionary was used to trigger the brute-force threshold rapidly.
*(See `scripts/attack_simulation.sh`)*

### 4. Threat Hunting & Analysis
Utilized the Wazuh Dashboard to filter raw logs and isolate SSH authentication failures. 

## 🔍 Analysis & Findings
- Successfully detected multiple `sshd: authentication failed` events (Rule 5760, Level 5).
- Triggered a **Level 10 Alert (Rule 5763 - SSH Brute Force)** after multiple rapid login failures.
- Mapped the attack to **MITRE ATT&CK: T1110.001 (Password Guessing)** under the **Credential Access** tactic.

### Evidence
*(Note: Replace the image paths below with your actual screenshots)*
![Dashboard](images/dashboard.png)
![Events Filter](images/events.png)
![MITRE Mapping](images/document_details.png)

## 🛠️ Tools Used
- **Wazuh** (SIEM / XDR)
- **Kali Linux** (Hydra)
- **Ubuntu Server** (Target)
- **VMware Workstation** (Virtualization)

## ⚠️ Disclaimer
This project was conducted in an isolated, controlled virtual lab environment for educational purposes only. The techniques demonstrated here should never be used against systems without explicit authorization.
