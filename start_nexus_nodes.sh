#!/bin/bash

# === Config ===
NODE_FILE="nodes_cli.txt"
NEXUS_BIN="/usr/local/bin/nexus-network"
TMUX_PREFIX="nexus_node_"
DELAY_SECONDS=15
NEXUS_URL="https://github.com/nexus-xyz/nexus-cli/releases/download/v0.8.18/nexus-network-linux-x86_64"

# === Step 1: Setup ===

echo "?? Installing dependencies..."
apt update && apt install -y curl tmux sudo

if [ ! -f "$NEXUS_BIN" ]; then
    echo "?? Downloading nexus-network binary..."
    curl -L "$NEXUS_URL" -o "$NEXUS_BIN" && chmod +x "$NEXUS_BIN"
fi

# === Step 2: Validate ===
[ -x "$NEXUS_BIN" ] || { echo "? nexus-network is not executable"; exit 1; }
[ -f "$NODE_FILE" ] || { echo "? Node ID file not found: $NODE_FILE"; exit 1; }

# === Step 3: Normalize Node IDs ===
IDS=$(tr '\t ' '\n' < "$NODE_FILE" | grep -E '^[0-9]+$' | sort -u)

[ -z "$IDS" ] && { echo "? No valid node IDs found in $NODE_FILE"; exit 1; }

# === Step 4: Run tmux sessions with restart loop ===
for NODE_ID in $IDS; do
    SESSION_NAME="${TMUX_PREFIX}${NODE_ID}"
    LOG_FILE="$LOG_DIR/${NODE_ID}.log"

    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "??  Session already exists: $SESSION_NAME — skipping"
        continue
    fi

    echo "?? Starting node ID $NODE_ID in tmux session: $SESSION_NAME"

    CMD="$NEXUS_BIN start --node-id $NODE_ID"

tmux new-session -d -s "$SESSION_NAME" "bash -c '
echo \"[INFO] Running: $CMD\"
$CMD
echo \"[WARN] Process exited.\"
exec bash
'"

    echo "? Waiting $DELAY_SECONDS seconds before next..."
    sleep "$DELAY_SECONDS"
done

echo "All nodes launched in tmux sessions."
