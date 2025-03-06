#!/bin/bash

echo "[INFO] Check shard2"

docker compose exec -T shard2 mongosh --port 27019 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

echo "[INFO] Check shard1"

docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF

echo "[INFO] Check mongos_router"

docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
use somedb;
db.helloDoc.countDocuments();
exit();
EOF