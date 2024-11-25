#!/bin/bash

SESSION_NAME="docker_nodes"

CONTAINERS=("node0" "node1" "node2" "node3" "node4")

DOCKER_IMAGE="solana:latest"
DOCKER_OPTIONS="-itd -P --network host"


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <entrypoint> <known-validator>"
    exit 1
fi

ENTRYPOINT="$1"
KNOWN_VALIDATOR="$2"

for CONTAINER in "${CONTAINERS[@]}"; do
    if ! docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER}$"; then
        echo "Starting container: $CONTAINER"
        sudo docker run $DOCKER_OPTIONS --name $CONTAINER $DOCKER_IMAGE
    else
        echo "Container $CONTAINER already exists. Starting it..."
        sudo docker start $CONTAINER
    fi
done

# Start a new tmux session
tmux new-session -d -s $SESSION_NAME

for i in "${!CONTAINERS[@]}"; do
    CONTAINER=${CONTAINERS[$i]}
    if [ $i -eq 0 ]; then
        tmux rename-window -t $SESSION_NAME:0 "$CONTAINER"
        tmux send-keys -t $SESSION_NAME:0 "sudo docker exec -it $CONTAINER bash" C-m
        tmux send-keys -t $SESSION_NAME:0 "cd root && ./quick_start.sh $ENTRYPOINT $KNOWN_VALIDATOR" C-m
    else
        tmux new-window -t $SESSION_NAME -n "$CONTAINER"
        tmux send-keys -t $SESSION_NAME:$i "sudo docker exec -it $CONTAINER bash" C-m
        tmux send-keys -t $SESSION_NAME:$i "cd root && ./quick_start.sh $ENTRYPOINT $KNOWN_VALIDATOR" C-m
    fi
done

tmux attach-session -t $SESSION_NAME
