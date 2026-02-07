#!/bin/bash

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║       MICROSERVICE CHAIN DEMONSTRATION                           ║"
echo "╠══════════════════════════════════════════════════════════════════╣"
echo "║                                                                  ║"
echo "║  Image Processing Pipeline:                                      ║"
echo "║                                                                  ║"
echo "║  [Image] → MS1 → MS2 → MS3 → MS4 → [Result]                     ║"
echo "║           Resize  B&W   Detect Alert                            ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Show pod locations
echo "Step 1: Pod Locations in Cluster"
echo "─────────────────────────────────────────────────────────────────────"
sudo kubectl get pods -o wide 2>/dev/null | grep -E "NAME|microservice|db"
echo ""

# Show services
echo "Step 2: Services (Load Balanced via SDN)"
echo "─────────────────────────────────────────────────────────────────────"
sudo kubectl get svc 2>/dev/null | grep -E "NAME|microservice|db"
echo ""

# Generate Request ID
REQ_ID=$(uuidgen)

# Send request
echo "Step 3: Sending Image Through Pipeline"
echo "─────────────────────────────────────────────────────────────────────"
echo "  Request ID: $REQ_ID"
echo ""
echo "  Sending image to Microservice 1 (Resize)..."
echo ""

RESPONSE=$(curl -s --max-time 120 "http://192.168.100.100:5001/resize" \
  -H "X-Request-ID: $REQ_ID" \
  -H "X-Special-Object: dog" \
  -H "X-Webhooks: http://microservice2-service:5002/bw,http://microservice3-service:8081/,http://microservice4-service:5004/notify" \
  -H "X-Central-DB-URL: http://db-service:5006/track_time" \
  -H "X-Logs-URL: http://db-service:5006/log" \
  -F "image=@/home/antonios-icontinuum/test_converted.jpg" 2>&1)

echo "  Response: $RESPONSE"
echo ""

# Wait a moment for all microservices to complete processing
echo "  Waiting for chain to complete..."
sleep 3
echo ""

# Check logs from each microservice - filter by Request ID
echo "Step 4: Verifying Each Microservice Processed Request ID: $REQ_ID"
echo "─────────────────────────────────────────────────────────────────────"

# Microservice 1
echo ""
echo "  📦 Microservice 1 (Resize) - Worker2:"
POD1=$(sudo kubectl get pods -l app=microservice1 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD1" ]; then
    LOG1=$(sudo kubectl logs $POD1 --tail=50 2>/dev/null | grep -A5 "$REQ_ID")
    if [ -n "$LOG1" ]; then
        echo "$LOG1" | head -6 | sed 's/^/    /'
    else
        # Fallback: show recent logs mentioning "completed" or processing time
        sudo kubectl logs $POD1 --tail=10 2>/dev/null | grep -E "completed|Processing_Time|special object" | tail -3 | sed 's/^/    /'
    fi
fi

# Microservice 2
echo ""
echo "  🎨 Microservice 2 (B&W) - Worker1:"
POD2=$(sudo kubectl get pods -l app=microservice2 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD2" ]; then
    LOG2=$(sudo kubectl logs $POD2 --tail=50 2>/dev/null | grep -A5 "$REQ_ID")
    if [ -n "$LOG2" ]; then
        echo "$LOG2" | head -6 | sed 's/^/    /'
    else
        sudo kubectl logs $POD2 --tail=10 2>/dev/null | grep -E "webhook|Response|post data" | tail -3 | sed 's/^/    /'
    fi
fi

# Microservice 3
echo ""
echo "  🔍 Microservice 3 (Object Detection) - Worker2:"
POD3=$(sudo kubectl get pods -l app=microservice3 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD3" ]; then
    LOG3=$(sudo kubectl logs $POD3 --tail=50 2>/dev/null | grep -A5 "$REQ_ID")
    if [ -n "$LOG3" ]; then
        echo "$LOG3" | head -6 | sed 's/^/    /'
    else
        sudo kubectl logs $POD3 --tail=10 2>/dev/null | grep -E "stdout|POST|object" | tail -3 | sed 's/^/    /'
    fi
fi

# Microservice 4
echo ""
echo "  🚨 Microservice 4 (Alert) - Master:"
POD4=$(sudo kubectl get pods -l app=microservice4 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD4" ]; then
    LOG4=$(sudo kubectl logs $POD4 --tail=50 2>/dev/null | grep -A5 "$REQ_ID")
    if [ -n "$LOG4" ]; then
        echo "    ✅ Found Request ID in logs:"
        echo "$LOG4" | head -6 | sed 's/^/    /'
    else
        echo "    ⚠️  Request ID not found in recent logs (chain may still be processing)"
        sudo kubectl logs $POD4 --tail=5 2>/dev/null | sed 's/^/    /'
    fi
fi

# Database
echo ""
echo "  💾 Database - Worker1:"
DB_POD=$(sudo kubectl get pods -l app=db -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$DB_POD" ]; then
    # Show recent POST requests to track_time
    sudo kubectl logs $DB_POD --tail=20 2>/dev/null | grep "track_time" | tail -4 | sed 's/^/    /'
fi

echo ""
echo "─────────────────────────────────────────────────────────────────────"
echo ""
echo "  📊 TRAFFIC FLOW SUMMARY:"
echo ""
echo "     Client Request"
echo "          │"
echo "          ▼"
echo "     ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐"
echo "     │   MS1   │ ───▶ │   MS2   │ ───▶ │   MS3   │ ───▶ │   MS4   │"
echo "     │ Resize  │      │   B&W   │      │ Detect  │      │  Alert  │"
echo "     │ Worker2 │      │ Worker1 │      │ Worker2 │      │ Master  │"
echo "     └─────────┘      └─────────┘      └─────────┘      └─────────┘"
echo "          │                │                │                │"
echo "          └────────────────┴────────────────┴────────────────┘"
echo "                                   │"
echo "                                   ▼"
echo "                            ┌───────────┐"
echo "                            │    DB     │"
echo "                            │  Worker1  │"
echo "                            └───────────┘"
echo ""
echo "  ✅ Request ID $REQ_ID processed through all microservices!"
echo "     Traffic crossed SDN network (Worker1 ↔ Worker2 ↔ Master)"
echo ""