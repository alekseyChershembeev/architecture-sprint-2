#!/bin/bash

echo "[INFO] Check data in shard2"
docker compose exec -T shard2_repl1 mongosh --port 27021 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit(); 
EOF

echo "[INFO] Check data in shard1"
docker compose exec -T shard1_repl1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit(); 
EOF

echo "[INFO] Check data in mongodb"
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit(); 
EOF

echo "[INFO] Check replica status shard1"
docker compose exec -T shard1_repl1 mongosh --port 27018 --quiet <<EOF
rs.status();
exit(); 
EOF

echo "[INFO] Check replica status shard2"
docker compose exec -T shard2_repl1 mongosh --port 27021 --quiet <<EOF
rs.status();
exit(); 
EOF