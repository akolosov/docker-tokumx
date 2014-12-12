#!/bin/bash

if [ -n "$MONGODB_SINGLE_SERVER" ]; then
  echo "Starting up single MongoDB server"
  /usr/bin/mongod --config $MONGOD_CONFIG_FILE --dbpath $MONGODB_DATA_PATH --port $MONGODB_MAIN_PORT --httpinterface --notablescan --noprealloc --smallfiles $OPTIONS     
fi

if [ -n "$MONGODB_IS_MASTER" ]; then
  echo "Starting up MongoDB Master"
  /usr/bin/mongod --config $MONGOD_CONFIG_FILE --dbpath $MONGODB_DATA_PATH --port $MONGODB_MAIN_PORT --httpinterface --notablescan --noprealloc --smallfiles --master $OPTIONS
fi

if [ -n "$MONGODB_IS_SLAVE_FOR" ]; then
  echo "Starting up MongoDB Slave for $MONGODB_IS_SLAVE_FOR"
  /usr/bin/mongod --config $MONGOD_CONFIG_FILE --dbpath $MONGODB_DATA_PATH --port $MONGODB_MAIN_PORT --httpinterface --notablescan --noprealloc --smallfiles --slave --source $MONGODB_IS_SLAVE_FOR:$MONGODB_MAIN_PORT $OPTIONS
fi

if [ -n "$MONGODB_REPLICA_SET" ]; then
  echo "Starting up MongoDB replica set $MONGODB_REPLICA_SET"
  /usr/bin/mongod --config $MONGOD_CONFIG_FILE --dbpath $MONGODB_DATA_PATH --port $MONGODB_MAIN_PORT --httpinterface --notablescan --noprealloc --smallfiles --replSet $MONGODB_REPLICA_SET $OPTIONS
fi

if [ -n "$MONGODB_CONFIG_SET" ]; then
  echo "Starting up MongoDB config server $MONGODB_CONFIG_SET"
  /usr/bin/mongod --config $MONGOD_CFG_CONFIG_FILE --configsvr --dbpath $MONGODB_METADATA_PATH --port $MONGODB_CONFIG_PORT $OPTIONS  
fi

if [ -n "$MONGODB_ROUTER_SET" ]; then
  echo "Starting up MongoDB router $MONGODB_ROUTER_SET"
  /usr/bin/mongos --config $MONGOS_CONFIG_FILE --configdb $MONGODB_CONFIG_SERVERS --port $MONGODB_ROUTER_PORT $OPTIONS
fi

if [ -n "$MONGODB_REPLICA_SET_INITIATE" ]; then
  sleep 2
  echo "Initiating up MongoDB replica set"
  echo "rs.initiate($MONGODB_REPLICA_SET_INITIATE_STRING);"|/usr/bin/mongo --host mongo-server --port $MONGODB_MAIN_PORT
fi

if [ -n "$MONGODB_REPLICA_SET_READPREF" ]; then
  sleep 2
  echo "Setting up MongoDB replica set readPref()"
  echo "db.getMongo().setReadPref('$MONGODB_REPLICA_SET_READPREF');"|/usr/bin/mongo --host mongo-server --port $MONGODB_MAIN_PORT
fi

if [ -n "$MONGODB_REPLICA_SET_ADD_HOST" ]; then
  sleep 2
  echo "Adding to MongoDB replica set host $MONGODB_REPLICA_SET_ADD_HOST"
  echo "rs.add('$MONGODB_REPLICA_SET_ADD_HOST');"|/usr/bin/mongo --host mongo-server --port $MONGODB_MAIN_PORT
fi

if [ -n "$MONGODB_REPLICA_SET_ADD_ARBITER" ]; then
  sleep 2
  echo "Adding to MongoDB replica set arbiter $MONGODB_REPLICA_SET_ADD_ARBITER"
  echo "rs.addArb('$MONGODB_REPLICA_SET_ADD_ARBITER');"|/usr/bin/mongo --host mongo-server --port $MONGODB_MAIN_PORT
fi

if [ -n "$MONGODB_REPLICA_SET_ADD_TO_SHARD" ]; then
  sleep 2
  echo "Adding MongoDB replica set $MONGODB_REPLICA_SET_ADD_TO_SHARD to sharding cluster"
  echo "sh.addShard('$MONGODB_REPLICA_SET_ADD_TO_SHARD');
        sh.status();"|/usr/bin/mongo --host mongo-router --port $MONGODB_ROUTER_PORT
fi

if [ -n "$MONGODB_ENABLE_DATABASE_SHARDING" ]; then
  sleep 2
  echo "Enabling MongoDB database $MONGODB_ENABLE_DATABASE_SHARDING sharding in cluster"
  echo "use $MONGODB_ENABLE_DATABASE_SHARDING
        sh.enableSharding('$MONGODB_ENABLE_DATABASE_SHARDING');
        sh.status();"|/usr/bin/mongo --host mongo-router --port $MONGODB_ROUTER_PORT
fi

if [ -n "$MONGODB_ENABLE_COLLECTION_SHARDING" ]; then
  sleep 2
  echo "Enabling MongoDB collection $MONGODB_ENABLE_COLLECTION_SHARDING sharding in cluster"
  export DATABASE=`echo $MONGODB_ENABLE_COLLECTION_SHARDING|sed 's/\.[^\.]*$//'` 
  export COLLECTION=`echo $MONGODB_ENABLE_COLLECTION_SHARDING|sed 's/^.*\.//'` 
  echo "use $DATABASE
        db.$COLLECTION.ensureIndex({ _id : 'hashed' })
        sh.shardCollection('$MONGODB_ENABLE_COLLECTION_SHARDING', { '_id': 'hashed' });
        sh.status();"|/usr/bin/mongo --host mongo-router --port $MONGODB_ROUTER_PORT
fi

if [ -n "$MONGODB_SET_SERVICE_IP" ]; then
  sleep 2
  echo "Changing up MongoDB replica set host to $MONGODB_SET_SERVICE_IP:$MONGODB_MAIN_PORT"
  echo "cfg = rs.conf();
        cfg.members[0].host = '$MONGODB_SET_SERVICE_IP:$MONGODB_MAIN_PORT';
        rs.reconfig(cfg, { force: true });
        rs.status();"|/usr/bin/mongo --host mongo-server --port $MONGODB_MAIN_PORT
fi

if [ -n "$MONGODB_LOG_ROTATE" ]; then
  echo "Rotating up MongoDB logfiles"
	killall -SIGUSR1 mongod
	killall -SIGUSR1 mongos
fi
