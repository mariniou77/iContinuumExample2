#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║       MONITORING STACK DEMONSTRATION                             ║"
echo "╠══════════════════════════════════════════════════════════════════╣"
echo "║                                                                  ║"
echo "║  Components:                                                     ║"
echo "║  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          ║"
echo "║  │  sFlow-RT   │───▶│ Prometheus  │───▶│   Grafana   │          ║"
echo "║  │  (collect)  │    │  (store)    │    │ (visualize) │          ║"
echo "║  └─────────────┘    └─────────────┘    └─────────────┘          ║"
echo "║       :8008             :9090              :3000                 ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════
# CHECK 1: sFlow-RT
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  1. sFlow-RT (Real-Time Network Analytics)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  Checking sFlow-RT status..."
echo ""

SFLOW_VERSION=$(curl -s http://localhost:8008/version 2>/dev/null)
if [ -n "$SFLOW_VERSION" ]; then
    echo "  ✅ sFlow-RT is running"
    echo "     Version: $SFLOW_VERSION"
    echo ""
    echo "  Connected agents (hosts sending metrics):"
    curl -s http://localhost:8008/agents/json 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for agent, info in data.items():
        print(f'     • {agent}')
except:
    print('     (unable to parse)')
" 2>/dev/null
else
    echo "  ❌ sFlow-RT is not responding"
fi
echo ""

read -p "  Press ENTER to check Prometheus..."
echo ""

# ═══════════════════════════════════════════════════════════════════
# CHECK 2: Prometheus
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  2. Prometheus (Metrics Storage)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  Checking Prometheus status..."
echo ""

PROM_HEALTH=$(curl -s http://localhost:9090/-/healthy 2>/dev/null)
if [ "$PROM_HEALTH" = "Prometheus Server is Healthy." ]; then
    echo "  ✅ Prometheus is healthy"
    echo ""
    echo "  Number of metrics available:"
    METRIC_COUNT=$(curl -s 'http://localhost:9090/api/v1/label/__name__/values' 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(f'     {len(data.get(\"data\", []))} metrics')
except:
    print('     (unable to count)')
" 2>/dev/null)
    echo "$METRIC_COUNT"
    echo ""
    echo "  Sample metrics:"
    curl -s 'http://localhost:9090/api/v1/label/__name__/values' 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for m in data.get('data', [])[:8]:
        print(f'     • {m}')
    if len(data.get('data', [])) > 8:
        print(f'     ... and {len(data.get(\"data\", [])) - 8} more')
except:
    pass
" 2>/dev/null
else
    echo "  ❌ Prometheus is not responding"
fi
echo ""

read -p "  Press ENTER to check Grafana..."
echo ""

# ═══════════════════════════════════════════════════════════════════
# CHECK 3: Grafana
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  3. Grafana (Visualization)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  Checking Grafana status..."
echo ""

GRAFANA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health 2>/dev/null)
if [ "$GRAFANA_STATUS" = "200" ]; then
    echo "  ✅ Grafana is running (HTTP 200)"
    echo ""
    echo "  To access Grafana UI:"
    echo ""
    echo "  1. Create SSH tunnel from your local machine:"
    echo "     ssh -L 3000:localhost:3000 $(whoami)@$(hostname -I | awk '{print $1}')"
    echo ""
    echo "  2. Open in browser: http://localhost:3000"
    echo ""
    echo "  3. Login: admin / admin"
else
    echo "  ❌ Grafana is not responding (HTTP $GRAFANA_STATUS)"
fi
echo ""

read -p "  Press ENTER to see live metrics..."
echo ""

# ═══════════════════════════════════════════════════════════════════
# LIVE METRICS
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  4. Live Metrics from sFlow-RT"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  Network interface traffic (bytes/sec):"
echo ""
curl -s 'http://localhost:8008/metric/ALL/ifinoctets/json' 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data[:6]:
        agent = item.get('agent', 'unknown')
        value = item.get('metricValue', 0)
        iface = item.get('dataSource', 'unknown')
        print(f'     • {agent} ({iface}): {value:,.0f} bytes/sec')
except Exception as e:
    print(f'     (unable to fetch: {e})')
" 2>/dev/null
echo ""

echo "  CPU utilization:"
echo ""
curl -s 'http://localhost:8008/metric/ALL/cpu_utilization/json' 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data[:4]:
        agent = item.get('agent', 'unknown')
        value = item.get('metricValue', 0)
        print(f'     • {agent}: {value:.1f}%')
except:
    print('     (no CPU data available)')
" 2>/dev/null
echo ""

read -p "  Press ENTER to see switch port statistics..."
echo ""

# ═══════════════════════════════════════════════════════════════════
# SWITCH STATISTICS
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  5. Switch Port Statistics (from OVS)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

for sw in s1 s2 s3; do
    echo "  Switch $sw:"
    sudo ovs-ofctl -O OpenFlow13 dump-ports $sw 2>/dev/null | grep -E "rx pkts|tx pkts" | head -4 | while read line; do
        echo "     $line"
    done
    echo ""
done

# ═══════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  ✅ MONITORING STACK SUMMARY"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  ┌─────────────────────────────────────────────────────────────┐"
echo "  │  Component   │ Port  │ Status │ Purpose                     │"
echo "  ├──────────────┼───────┼────────┼─────────────────────────────┤"
echo "  │  sFlow-RT    │ 8008  │   ✅   │ Collect real-time metrics   │"
echo "  │  Prometheus  │ 9090  │   ✅   │ Store time-series data      │"
echo "  │  Grafana     │ 3000  │   ✅   │ Visualize dashboards        │"
echo "  └──────────────┴───────┴────────┴─────────────────────────────┘"
echo ""
echo "  In IntentContinuum (next phase):"
echo "  • These metrics feed into the Intent Watch Loop"
echo "  • LLM analyzes metrics to detect SLO violations"
echo "  • Automatic remediation based on root cause analysis"
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo ""