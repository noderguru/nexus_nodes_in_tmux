```bash
git clone https://github.com/noderguru/start_nexus_nodes_in_tmux.git && cd start_nexus_nodes_in_tmux && chmod +x start_nexus_nodes.sh && nano nodes_cli.txt && ./start_nexus_nodes.sh
```
### обнова руками v0.8.11  (fixes 404 "Failed to submit proof for task")
```bash
tmux ls | grep nexus_node_ | cut -d: -f1 | xargs -r -n1 tmux kill-session -t && \
rm -f /usr/local/bin/nexus-network && \
curl -L https://github.com/nexus-xyz/nexus-cli/releases/download/v0.8.11/nexus-network-linux-x86_64 -o /usr/local/bin/nexus-network && \
chmod +x /usr/local/bin/nexus-network && \
cd /root/start_nexus_nodes_in_tmux && ./start_nexus_nodes.sh
```
### помотреть логи в запущенных сессиях 
```bash
for s in $(tmux list-sessions -F '#S'); do
  echo "===== Session: $s ====="
  tmux capture-pane -pt "$s"
done
```
### перезапуск всех сессий с именем nexus_node_  с тем же ID
```bash
for s in $(tmux list-sessions -F '#S' | grep '^nexus_node_'); do
  NODE_ID="${s#nexus_node_}"
  echo "[INFO] Restarting session: $s (ID: $NODE_ID)"
  tmux kill-session -t "$s"
  sleep 5
  tmux new-session -d -s "$s" "bash -c '
    while true; do
      echo \"[INFO] Running node-id $NODE_ID\"
      nexus-network start --node-id $NODE_ID
      echo \"[WARN] Process exited. Restarting in 5s...\"
      sleep 5
    done
  '"
done
```
### удалить все сессии с именем "nexus_node_"
```bash
tmux ls | grep "^nexus_node_" | cut -d: -f1 | xargs -r -n1 tmux kill-session -t
```
### потребление RAM и CPU каждой ноды внутри сессии
```bash
ps -C nexus-network -o pid,%cpu,%mem,cmd --sort=-%cpu
```



