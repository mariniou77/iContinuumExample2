# On SDN-Controller
cat << 'EOF' > ~/demo4_network_control.sh
#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║       SDN NETWORK CONTROL - INTERACTIVE DEMO                     ║"
echo "╠══════════════════════════════════════════════════════════════════╣"
echo "║                                                                  ║"
echo "║  Before running this, start a continuous ping on MASTER:         ║"
echo "║                                                                  ║"
echo "║     ping 192.168.100.101                                         ║"
echo "║                                                                  ║"
echo "║  Watch the ping times change as we modify the network!           ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Clean up any existing rules
sudo tc qdisc del dev s1-eth2 root 2>/dev/null

echo "  Current network state: NORMAL (no modifications)"
echo ""
read -p "  Press ENTER when ping is running on Master..."
echo ""

# ═══════════════════════════════════════════════════════════════════
# TEST 1: ADD LATENCY
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  TEST 1: ADD 50ms LATENCY"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
read -p "  Press ENTER to ADD 50ms delay..."
echo ""
echo "  Executing: sudo tc qdisc add dev s1-eth2 root netem delay 50ms"
sudo tc qdisc add dev s1-eth2 root netem delay 50ms
echo ""
echo "  ✅ 50ms delay ADDED"
echo ""
echo "  👀 Watch Master terminal - ping should now show ~110ms instead of ~11ms"
echo ""

read -p "  Press ENTER to REMOVE delay..."
echo ""
echo "  Executing: sudo tc qdisc del dev s1-eth2 root"
sudo tc qdisc del dev s1-eth2 root
echo ""
echo "  ✅ Delay REMOVED - ping should return to ~11ms"
echo ""

# ═══════════════════════════════════════════════════════════════════
# TEST 2: ADD MORE LATENCY
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  TEST 2: ADD 100ms LATENCY (simulating intercontinental link)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
read -p "  Press ENTER to ADD 100ms delay..."
echo ""
echo "  Executing: sudo tc qdisc add dev s1-eth2 root netem delay 100ms"
sudo tc qdisc add dev s1-eth2 root netem delay 100ms
echo ""
echo "  ✅ 100ms delay ADDED"
echo ""
echo "  👀 Watch Master terminal - ping should now show ~210ms"
echo ""

read -p "  Press ENTER to REMOVE delay..."
echo ""
sudo tc qdisc del dev s1-eth2 root
echo ""
echo "  ✅ Delay REMOVED"
echo ""

# ═══════════════════════════════════════════════════════════════════
# TEST 3: PACKET LOSS
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  TEST 3: ADD 30% PACKET LOSS (simulating unreliable network)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
read -p "  Press ENTER to ADD 30% packet loss..."
echo ""
echo "  Executing: sudo tc qdisc add dev s1-eth2 root netem loss 30%"
sudo tc qdisc add dev s1-eth2 root netem loss 30%
echo ""
echo "  ✅ 30% packet loss ADDED"
echo ""
echo "  👀 Watch Master terminal - some pings will timeout!"
echo ""

read -p "  Press ENTER to REMOVE packet loss..."
echo ""
sudo tc qdisc del dev s1-eth2 root
echo ""
echo "  ✅ Packet loss REMOVED"
echo ""

# ═══════════════════════════════════════════════════════════════════
# TEST 4: LATENCY + JITTER
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  TEST 4: ADD 50ms LATENCY + 20ms JITTER (simulating mobile network)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
read -p "  Press ENTER to ADD latency with jitter..."
echo ""
echo "  Executing: sudo tc qdisc add dev s1-eth2 root netem delay 50ms 20ms"
sudo tc qdisc add dev s1-eth2 root netem delay 50ms 20ms
echo ""
echo "  ✅ 50ms delay with ±20ms jitter ADDED"
echo ""
echo "  👀 Watch Master terminal - ping times will vary between ~90ms and ~130ms"
echo ""

read -p "  Press ENTER to REMOVE..."
echo ""
sudo tc qdisc del dev s1-eth2 root
echo ""
echo "  ✅ Latency + jitter REMOVED"
echo ""

# ═══════════════════════════════════════════════════════════════════
# TEST 5: BANDWIDTH LIMIT
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  TEST 5: LIMIT BANDWIDTH TO 1 Mbps"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  Note: Bandwidth limiting is less visible with small ping packets."
echo "        It affects large data transfers more significantly."
echo ""
read -p "  Press ENTER to ADD 1 Mbps bandwidth limit..."
echo ""
echo "  Executing: sudo tc qdisc add dev s1-eth2 root tbf rate 1mbit burst 32kbit latency 400ms"
sudo tc qdisc add dev s1-eth2 root tbf rate 1mbit burst 32kbit latency 400ms
echo ""
echo "  ✅ Bandwidth limited to 1 Mbps"
echo ""
echo "  👀 Ping may show slightly higher latency due to queuing"
echo ""

read -p "  Press ENTER to REMOVE bandwidth limit..."
echo ""
sudo tc qdisc del dev s1-eth2 root
echo ""
echo "  ✅ Bandwidth limit REMOVED"
echo ""

# ═══════════════════════════════════════════════════════════════════
# CLEANUP AND SUMMARY
# ═══════════════════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════════════"
echo "  ✅ ALL TESTS COMPLETE"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  Summary of what we demonstrated:"
echo ""
echo "  ┌────────────────────────────────────────────────────────────────┐"
echo "  │  Test    │ Command                        │ Effect             │"
echo "  ├──────────┼────────────────────────────────┼────────────────────┤"
echo "  │  Delay   │ netem delay 50ms               │ +100ms RTT         │"
echo "  │  Delay   │ netem delay 100ms              │ +200ms RTT         │"
echo "  │  Loss    │ netem loss 30%                 │ 30% packets lost   │"
echo "  │  Jitter  │ netem delay 50ms 20ms          │ Variable latency   │"
echo "  │  BW Limit│ tbf rate 1mbit                 │ Throttled transfer │"
echo "  └──────────┴────────────────────────────────┴────────────────────┘"
echo ""
echo "  Key Takeaway: SDN enables dynamic network control for testing"
echo "                edge-cloud applications under various conditions!"
echo ""
echo "  You can now stop the ping on Master (Ctrl+C)"
echo ""

EOF
chmod +x ~/demo4_network_control.sh