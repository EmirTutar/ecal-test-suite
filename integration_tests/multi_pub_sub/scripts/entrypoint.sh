#!/bin/bash

ROLE=$1        # multi_publisher | multi_publisher2 | multi_subscriber | multi_subscriber2 | local_all_multi
MODE=$2        # local_shm | local_udp | local_tcp | network_udp | network_tcp
TOPIC=$3       # topic name
NAME=$4        # optional name override
EXTRA=$5       # optional extra args

if [ -z "$ROLE" ] || [ -z "$MODE" ]; then
  echo "Usage: $0 <multi_publisher|multi_publisher2|multi_subscriber|multi_subscriber2|local_all_multi> <mode> [topic] [name] [extra args]"
  exit 1
fi

TOPIC=${TOPIC:-test_topic}
cd /app/src/build

if [ "$ROLE" = "multi_publisher" ]; then
  echo "[Entrypoint] Starting multi_publisher in mode $MODE"
  ARGS="--mode $MODE --topic $TOPIC"
  ./multi_publisher $ARGS $EXTRA

elif [ "$ROLE" = "multi_publisher2" ]; then
  echo "[Entrypoint] Starting multi_publisher2 in mode $MODE"
  ARGS="--mode $MODE --topic $TOPIC"
  ./multi_publisher2 $ARGS $EXTRA

elif [ "$ROLE" = "multi_subscriber" ]; then
  echo "[Entrypoint] Starting multi_subscriber in mode $MODE"
  ARGS="--mode $MODE --topic $TOPIC"
  ./multi_subscriber $ARGS $EXTRA
  sleep 1

elif [ "$ROLE" = "multi_subscriber2" ]; then
  echo "[Entrypoint] Starting multi_subscriber2 in mode $MODE"
  ARGS="--mode $MODE --topic $TOPIC"
  ./multi_subscriber2 $ARGS $EXTRA
  sleep 1

elif [ "$ROLE" = "local_multi" ]; then
  echo "[Entrypoint] Starting local multi pub/sub test in mode $MODE"

  ARGS="--mode $MODE --topic $TOPIC"

  ./multi_publisher $ARGS &
  PUB1_PID=$!

  ./multi_publisher2 $ARGS &
  PUB2_PID=$!
  sleep 1
  
  ./multi_subscriber $ARGS &
  SUB1_PID=$!

  ./multi_subscriber2 $ARGS &
  SUB2_PID=$!

  wait $PUB1_PID
  wait $PUB2_PID
  wait $SUB1_PID
  wait $SUB2_PID

else
  echo "[Entrypoint] Unknown role: $ROLE"
  exit 1
fi