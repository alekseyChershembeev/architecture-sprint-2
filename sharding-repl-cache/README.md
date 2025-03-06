# pymongo-api

## Как запустить

Запускаем mongodb с шардингом и приложение

```shell
docker compose up -d
```


Выполнить скрипт для настройки шардирования и заполнения mongodb данными

```shell
./scripts/mongo-init.sh
```

Или выполнить поэтапно :
1. Инициализация сервиса конфигураций
```shell
docker compose exec -T configSrv mongosh --port 27019 --quiet <<EOF
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27019" }
    ]
  }
);
exit();
EOF
```

2. Инициализация шардов и реплик
```shell
docker compose exec -T shard1_repl1 mongosh --port 27018 --quiet <<EOF
rs.initiate(
  {
    _id: "shard1", 
    members: [
      {_id: 0, host: "shard1_repl1:27018"},
      {_id: 1, host: "shard1_repl2:27017"},
      {_id: 2, host: "shard1_repl3:27016"}
    ]
  }
)
exit();
EOF

docker compose exec -T shard2_repl1 mongosh --port 27021 --quiet <<EOF
rs.initiate(
  {
    _id : "shard2",
    members: [
      { _id : 3, host : "shard2_repl1:27021" },
      { _id : 4, host : "shard2_repl2:27022" },
      { _id : 5, host : "shard2_repl3:27023" }
    ]
  }
);
exit(); 
EOF
```

3. Добавление шардов в роутере
```shell
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.addShard( "shard1/shard1_repl1:27018");
sh.addShard( "shard2/shard2_repl1:27021");
EOF
```

4. Создание БД и заполнение данными
```shell
docker compose exec -T mongos_router mongosh --port 27020 --quiet <<EOF
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insertOne({age:i, name:"ly"+i})
db.helloDoc.countDocuments() 
EOF

```

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

### Проверка шардов и данных в них

```shell
./scripts/mongo-check.sh
```

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs