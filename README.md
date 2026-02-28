# iContinuumExample2

## Adjustments before first run

### First adjustment

The first thing I adjust is the `Example2/inventory.ini`. There I setted up the IP addresses of the VMs in my GCP account and adjusted the variables.

### Second adjustment

The second adjustment was in `Example2/topology.sh.j2`. There, I made the mininet topology command a bit more precise by addidng the ablolute path and adding the internal_ip of onos_machine instead of the external. Additionally, before adding the switched, I am now checking if there is already some of them, so that in case I run the playbook agin, not to crush. Finally, I changed the agent `eno1` to `ens4` because that's what GCP uses.

### Third adjustment

The third adjustment was in `Example2/kubernetes.yml`. There I adjusted all the varables retirieved by the `inventory.ini` and more detailed to retrieve the internal IPs of the VMs. Additionally a made some changed to lines like: "Adding OVS Brinde" in order the playbook not to brake in case I run it a second time.

### Forth adjustment

The forth adjustment was in `Example2/deployment.yml.j2`. There I just adjusted the slow_machine IP variable

### Fifth adjustment

The fifth adjustment was in `host-sflow.yml.j2`. There I just adjusted the slow_machine IP variable

### Sixth adjsutment

The sixth adjustment was in `prometheus.yml.j2`. There I just adjusted the slow_machine IP variable

### Seventh adjustment

The seventh adjustment was in `mininet.yml`. There I adjusted the IP variables pointing to the VMs. I also deleted the installation of Python because it was throwing an error and isntalled JAva 17 instead of 11 becas sflow was throwing an incopatible arror with Java 11

### Final adjustment

The final adjustment was in `monitor.yml`. There I deleted dublicate installation of sflow (because I install it through `mininet.yml` playbook). dditionally I cahnged the JAVA to 17 as previously.

## Next Steps

After finishing with all the pre-running adjustments, I cloned the repo in the WSL. Then, from inside the folder of the repo, I run the ansible command to start executing the playbooks: 

```bash
ansible-playbook -i Example2/inventory.ini main.yml -e "example_folder=Example2"
```


# OpenLLMIntentContinuum

**LLM-Powered Intent-Based Resource Management for the Compute Continuum**

[![Python 3.8+](https://img.shields.io/badge/python-3.8+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Infrastructure Setup](#infrastructure-setup)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Components](#components)
- [How It Works](#how-it-works)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [References](#references)
- [License](#license)

---

## 🎯 Overview

**OpenLLMIntentContinuum** is an open-source implementation of intent-based resource management for edge-to-cloud computing environments. It uses a local Large Language Model (TinyLlama) to automatically detect performance issues and take corrective actions.

The system continuously monitors application response times and, when Service Level Objectives (SLOs) are violated, it:
1. Collects comprehensive system state (Kubernetes, SDN network, monitoring metrics)
2. Sends the data to a local LLM for root cause analysis
3. Executes the recommended action (e.g., horizontal scaling)

This project is inspired by and extends the concepts from:
- **iContinuum**: An Emulation Toolkit for Intent-Based Computing Across the Edge-to-Cloud Continuum
- **IntentContinuum**: Using LLMs to Support Intent-Based Computing Across the Compute Continuum

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         OpenLLMIntentContinuum                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   User Intent (e.g., Response Time < 3s)                                   │
│        │                                                                    │
│        ▼                                                                    │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │  Intent Watch Loop (intent_watch_loop.py)                           │  │
│   │  • Monitors application response times                              │  │
│   │  • Calculates Exponential Moving Average (EMA)                      │  │
│   │  • Detects SLO violations                                           │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│        │                                                                    │
│        │ Violation Detected                                                 │
│        ▼                                                                    │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │  Data Collector (data_collector.py)                                 │  │
│   │  • Kubernetes: nodes, pods, deployments, resources                  │  │
│   │  • ONOS SDN: switches, links, hosts, topology                       │  │
│   │  • sFlow-RT: CPU, memory, network traffic                           │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│        │                                                                    │
│        ▼                                                                    │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │  Decision Maker (decision_maker.py)                                 │  │
│   │  • Builds prompt with system state                                  │  │
│   │  • Queries TinyLlama via Ollama API                                 │  │
│   │  • Parses and validates LLM recommendation                          │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│        │                                                                    │
│        ▼                                                                    │
│   ┌─────────────────────────────────────────────────────────────────────┐  │
│   │  Action Executor (action_executor.py)                               │  │
│   │  • Horizontal Scaling (kubectl scale)                               │  │
│   │  • Vertical Scaling (future)                                        │  │
│   │  • Service Placement (future)                                       │  │
│   │  • Flow Scheduling (future)                                         │  │
│   └─────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Infrastructure Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Infrastructure Layer                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   SDN-Controller VM                    Kubernetes Cluster                   │
│   ┌─────────────────────┐              ┌─────────────────────┐             │
│   │ • Mininet (OVS)     │              │ Master Node         │             │
│   │ • ONOS Controller   │◄────────────►│ • K3s Control Plane │             │
│   │ • sFlow-RT          │   SDN/GRE    │ • Load Generator    │             │
│   │ • Prometheus        │   Network    └─────────────────────┘             │
│   │ • Grafana           │                       │                          │
│   │ • Ollama (TinyLlama)│              ┌───────┴───────┐                   │
│   │ • IntentContinuum   │              │               │                   │
│   └─────────────────────┘        ┌─────┴─────┐   ┌─────┴─────┐            │
│                                  │ Worker 1  │   │ Worker 2  │            │
│                                  │ • Pods    │   │ • Pods    │            │
│                                  └───────────┘   └───────────┘            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ✨ Features

- **Intent-Based Management**: Define high-level SLOs (e.g., response time < 3s) instead of low-level configurations
- **Local LLM Integration**: Uses TinyLlama via Ollama - no cloud API costs or data privacy concerns
- **Automatic Root Cause Analysis**: LLM analyzes system state to identify issues
- **Automated Remediation**: Executes scaling actions without human intervention
- **Multi-Source Data Collection**: Aggregates data from Kubernetes, ONOS SDN, and sFlow-RT
- **Extensible Architecture**: Easy to add new actions (vertical scaling, service placement, flow scheduling)
- **Real-Time Monitoring**: Continuous monitoring with configurable check intervals

---

## 📋 Prerequisites

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| SDN-Controller VM | 4 vCPU, 4GB RAM | 8 vCPU, 8GB RAM |
| Master Node | 2 vCPU, 4GB RAM | 4 vCPU, 8GB RAM |
| Worker Nodes (x2) | 2 vCPU, 4GB RAM each | 4 vCPU, 8GB RAM each |

### Software Requirements

#### On SDN-Controller VM:
- Ubuntu 20.04 LTS or later
- Python 3.8+
- Docker
- Mininet with Open vSwitch
- ONOS SDN Controller
- sFlow-RT
- Prometheus
- Grafana
- Ollama with TinyLlama model

#### On Kubernetes Cluster:
- K3s (lightweight Kubernetes)
- kubectl configured
- Microservices application deployed

### Network Requirements

- GCP VPC network (or equivalent) connecting all VMs
- SDN overlay network (192.168.100.0/24) via GRE tunnels
- Kubernetes pod network (10.42.0.0/16)

---

## 🏗️ Infrastructure Setup

### 1. SDN-Controller VM Setup

#### Install Mininet and Open vSwitch
```bash
sudo apt-get update
sudo apt-get install -y mininet openvswitch-switch
```

#### Install ONOS SDN Controller
```bash
# Using Docker
docker run -d --name onos \
  -p 8181:8181 -p 8101:8101 -p 6653:6653 \
  onosproject/onos:latest
```

#### Install sFlow-RT
```bash
# Download and run sFlow-RT
wget https://inmon.com/products/sFlow-RT/sflow-rt.tar.gz
tar -xzf sflow-rt.tar.gz
cd sflow-rt
./start.sh
```

#### Install Ollama and TinyLlama
```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull TinyLlama model
ollama pull tinyllama

# Verify
ollama run tinyllama "Hello, what is Kubernetes?"
```

### 2. Kubernetes Cluster Setup

#### Install K3s on Master
```bash
curl -sfL https://get.k3s.io | sh -
```

#### Join Worker Nodes
```bash
# On master, get the token
sudo cat /var/lib/rancher/k3s/server/node-token

# On workers
curl -sfL https://get.k3s.io | K3S_URL=https://<master-ip>:6443 K3S_TOKEN=<token> sh -
```

### 3. Network Configuration

#### Create GRE Tunnels (on each Kubernetes node)
```bash
# Example for connecting to SDN-Controller
sudo ovs-vsctl add-br br1
sudo ovs-vsctl add-port br1 tap0 -- set interface tap0 type=internal
sudo ovs-vsctl add-port br1 tap1 -- set interface tap1 type=gre options:remote_ip=<SDN-CONTROLLER-IP>
sudo ip addr add 192.168.100.X/24 dev tap0
sudo ip link set tap0 up
```

### 4. SSH Key Setup

Enable passwordless SSH from SDN-Controller to Master:
```bash
# On SDN-Controller
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id <username>@<master-ip>

# Or manually add the public key to Master's ~/.ssh/authorized_keys
```

---

## 📦 Installation

### 1. Clone the Repository

```bash
# On SDN-Controller
cd ~
git clone -b dev https://github.com/mariniou77/OpenLLMIntentContinuum.git
cd OpenLLMIntentContinuum
```

### 2. Install Python Dependencies

```bash
pip install -r requirements.txt --break-system-packages
```

### 3. Configure the System

Edit `config.yaml` to match your environment:

```yaml
# Key configurations to update:
endpoints:
  kubernetes_master: "<YOUR-MASTER-IP>"  # e.g., 10.132.0.14
  
application:
  entry_point: "http://<YOUR-MASTER-IP>:5001/resize"
  test_image: "/path/to/test/image.jpg"
```

### 4. Verify Installation

```bash
# Test all components
python3 test_clients.py
```

Expected output:
```
✅ kubernetes: healthy
✅ onos: healthy
✅ sflow_rt: healthy
```

---

## ⚙️ Configuration

### config.yaml

```yaml
# Intent thresholds
intent:
  upper_threshold: 3.0    # Response time above this triggers scale UP
  lower_threshold: 1.0    # Response time below this triggers scale DOWN
  ema_alpha: 0.02         # EMA smoothing factor (0-1)
  check_interval: 5       # Seconds between checks
  wait_after_action: 60   # Seconds to wait after taking action

# Infrastructure endpoints
endpoints:
  ollama: "http://localhost:11434"
  onos: "http://localhost:8181"
  onos_user: "onos"
  onos_password: "rocks"
  sflow_rt: "http://localhost:8008"
  kubernetes_master: "10.132.0.14"

# Application configuration
application:
  entry_point: "http://10.132.0.14:5001/resize"
  test_image: "/home/user/OpenLLMIntentContinuum/images/family.jpg"
  webhooks: "http://microservice2-service:5002/bw,http://microservice3-service:8081/,http://microservice4-service:5004/notify"
  db_url: "http://db-service:5006/track_time"
  logs_url: "http://db-service:5006/log"

# LLM configuration
llm:
  model: "tinyllama"
  temperature: 0.1        # Low temperature for deterministic responses

# Enabled actions
actions:
  horizontal_scaling: true
  vertical_scaling: false
  service_placement: false
  flow_scheduling: false

# Kubernetes deployment constraints
kubernetes:
  namespace: "default"
  deployments:
    - name: "microservice1-deployment"
      min_replicas: 1
      max_replicas: 5
    - name: "microservice2-deployment"
      min_replicas: 1
      max_replicas: 5
    - name: "microservice3-deployment"
      min_replicas: 1
      max_replicas: 5
    - name: "microservice4-deployment"
      min_replicas: 1
      max_replicas: 3
```

---

## 🚀 Usage

### Basic Usage

```bash
# Run IntentContinuum (runs forever until Ctrl+C)
python3 main.py

# Run for a specific number of iterations
python3 main.py --iterations 10

# Run with debug logging
python3 main.py --log-level DEBUG

# Run with custom config file
python3 main.py --config my_config.yaml

# Run quietly (no banner)
python3 main.py --quiet
```

### Command Line Options

| Option | Short | Default | Description |
|--------|-------|---------|-------------|
| `--config` | `-c` | `config.yaml` | Path to configuration file |
| `--iterations` | `-i` | `None` (infinite) | Number of iterations to run |
| `--log-level` | `-l` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `--quiet` | `-q` | `False` | Suppress banner and config summary |

### Example Output

```
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ██╗███╗   ██╗████████╗███████╗███╗   ██╗████████╗              ║
║   ██║████╗  ██║╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝              ║
║   ...                                                            ║
║   LLM-Powered Intent-Based Resource Management                   ║
║   for the Compute Continuum                                      ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

2026-02-05 20:18:46 - INFO - Loaded configuration from config.yaml
2026-02-05 20:18:47 - INFO - Checking component health...
2026-02-05 20:18:47 - INFO -   ✅ kubernetes: healthy
2026-02-05 20:18:47 - INFO -   ✅ onos: healthy
2026-02-05 20:18:47 - INFO -   ✅ sflow_rt: healthy
2026-02-05 20:18:47 - INFO -   ✅ Ollama (LLM): healthy
2026-02-05 20:18:47 - INFO - Starting Intent Watch Loop...
2026-02-05 20:18:48 - INFO - RT: 1.234s | EMA: 1.234s | Thresholds: [1.0, 3.0]
```

---

## 🧩 Components

### File Structure

```
OpenLLMIntentContinuum/
├── main.py                     # Main entry point
├── config.yaml                 # Configuration file
├── requirements.txt            # Python dependencies
├── intent_watch_loop.py        # Core monitoring loop
├── data_collector.py           # System data aggregation
├── decision_maker.py           # LLM integration
├── action_executor.py          # Action execution
├── prompts/
│   └── analysis_prompt.txt     # LLM prompt template
├── utils/
│   ├── __init__.py
│   ├── kubernetes_client.py    # Kubernetes API client
│   ├── onos_client.py          # ONOS REST API client
│   └── sflow_client.py         # sFlow-RT API client
├── images/
│   └── family.jpg              # Test image for microservices
├── scripts/
│   └── setup.sh                # Setup script (optional)
└── README.md                   # This file
```

### Component Descriptions

| Component | File | Description |
|-----------|------|-------------|
| **Main** | `main.py` | Entry point, CLI handling, initialization |
| **Intent Watch Loop** | `intent_watch_loop.py` | Monitors response times, detects violations |
| **Data Collector** | `data_collector.py` | Gathers data from K8s, ONOS, sFlow-RT |
| **Decision Maker** | `decision_maker.py` | LLM integration for analysis |
| **Action Executor** | `action_executor.py` | Executes recommended actions |
| **Kubernetes Client** | `utils/kubernetes_client.py` | K8s operations via SSH+kubectl |
| **ONOS Client** | `utils/onos_client.py` | SDN network operations |
| **sFlow Client** | `utils/sflow_client.py` | Monitoring metrics collection |

---

## ⚙️ How It Works

### 1. Monitoring Phase

The Intent Watch Loop continuously sends requests to the microservice application and measures response times:

```python
# Exponential Moving Average calculation
EMA_t = (1 - α) × EMA_{t-1} + α × RT_t

# Where:
# - α = 0.02 (smoothing factor)
# - RT_t = current response time
# - EMA_{t-1} = previous EMA value
```

### 2. Violation Detection

A violation is detected when:
- **UPPER_THRESHOLD_EXCEEDED**: EMA > 3.0 seconds (response too slow)
- **LOWER_THRESHOLD_EXCEEDED**: EMA < 1.0 seconds (over-provisioned)

### 3. Data Collection

When a violation occurs, the system collects:
- **Kubernetes**: Node status, pod locations, deployment replica counts
- **ONOS SDN**: Network topology, switch status, link information
- **sFlow-RT**: CPU utilization, memory usage, network traffic

### 4. LLM Analysis

The collected data is formatted and sent to TinyLlama:

```
VIOLATION: UPPER_THRESHOLD_EXCEEDED
THRESHOLD: Upper=3.0s, Lower=1.0s

SYSTEM STATE:
[Kubernetes cluster info]
[Network topology]
[Resource utilization]

Recommend an action to resolve this issue.
```

### 5. Action Execution

Based on the LLM recommendation, the system executes:

```bash
# Example: Horizontal scaling
kubectl scale deployment microservice3-deployment --replicas=2
```

### 6. Stabilization

After executing an action, the system waits (default: 60 seconds) for the system to stabilize before resuming monitoring.

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Ollama Not Responding
```bash
# Check Ollama status
systemctl status ollama

# Restart Ollama
sudo systemctl restart ollama

# Test manually
curl http://localhost:11434/api/generate -d '{"model":"tinyllama","prompt":"hello"}'
```

#### 2. Kubernetes Connection Failed
```bash
# Test SSH connection
ssh <username>@<master-ip> 'sudo kubectl get nodes'

# Check SSH key
cat ~/.ssh/id_rsa.pub
# Ensure this key is in Master's ~/.ssh/authorized_keys
```

#### 3. ONOS Not Accessible
```bash
# Check ONOS status
curl -u onos:rocks http://localhost:8181/onos/v1/devices

# Verify ONOS is running
docker ps | grep onos
```

#### 4. Application Returns 500 Error
```bash
# Check required headers
curl -X POST \
  -F "image=@/path/to/image.jpg" \
  -H "X-Request-ID: test-123" \
  -H "X-Webhooks: http://microservice2-service:5002/bw,..." \
  -H "X-Special-Object: person" \
  -H "X-Central-DB-URL: http://db-service:5006/track_time" \
  -H "X-Logs-URL: http://db-service:5006/log" \
  http://<master-ip>:5001/resize
```

#### 5. Request Timeout
```bash
# Test endpoint directly
time curl -X POST -F "image=@test.jpg" http://<master-ip>:5001/resize

# Check pod logs
kubectl logs -l app=microservice1 --tail=50
```

### Debug Mode

Run with debug logging for detailed output:
```bash
python3 main.py --log-level DEBUG --iterations 1
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/<your-username>/OpenLLMIntentContinuum.git
cd OpenLLMIntentContinuum

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run tests
python3 test_clients.py
python3 test_data_collector.py
python3 test_decision_maker.py
python3 test_action_executor.py
python3 test_intent_watch_loop.py
```

---

## 📚 References

### Papers

1. **iContinuum**: Akbari, N., Toosi, A. N., Grundy, J., Khalajzadeh, H., Aslanpour, M. S., & Ilager, S. (2024). *iContinuum: An Emulation Toolkit for Intent-Based Computing Across the Edge-to-Cloud Continuum*. IEEE 17th International Conference on Cloud Computing (CLOUD).

2. **IntentContinuum**: Akbari, N., Grundy, J., Cheema, A., & Toosi, A. N. (2025). *IntentContinuum: Using LLMs to Support Intent-Based Computing Across the Compute Continuum*. arXiv preprint arXiv:2504.04429.

### Technologies

- [Kubernetes](https://kubernetes.io/) - Container orchestration
- [K3s](https://k3s.io/) - Lightweight Kubernetes
- [ONOS](https://opennetworking.org/onos/) - SDN Controller
- [Mininet](http://mininet.org/) - Network emulator
- [Open vSwitch](https://www.openvswitch.org/) - Virtual switch
- [sFlow-RT](https://sflow-rt.com/) - Real-time analytics
- [Ollama](https://ollama.com/) - Local LLM runtime
- [TinyLlama](https://github.com/jzhang38/TinyLlama) - Compact language model

---

## 📊 Project Status

| Feature | Status |
|---------|--------|
| Intent Watch Loop | ✅ Complete |
| Data Collection | ✅ Complete |
| LLM Integration | ✅ Complete |
| Horizontal Scaling | ✅ Complete |
| Vertical Scaling | 🔄 Planned |
| Service Placement | 🔄 Planned |
| Flow Scheduling | 🔄 Planned |
| Grafana Dashboard | 🔄 Planned |

---
