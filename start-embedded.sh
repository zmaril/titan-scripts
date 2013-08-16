#!/bin/bash
set -x
sudo killall -9 java
sudo rm -vrf /tmp/cassandra/*
export stamp=`date +%Y%m%d%H%M%S`
bin/gremlin.sh <<SCRIPT
g = TitanFactory.open("config/titan-server-cassandra.properties")
g.makeType().name("name").dataType(String.class).unique(OUT).indexed(Vertex).makePropertyKey();
g.makeType().name("title").dataType(String.class).unique(OUT).indexed(Vertex).makePropertyKey();
GraphSONReader.inputGraph(g,new FileInputStream(new File("/home/ubuntu/marvel.graphson")))
exit
SCRIPT


export JAVA_OPTIONS="-Xms20G -Xmx20G -XX:+UseParNewGC -XX:NewSize=2G -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:SurvivorRatio=8 -XX:MaxTenuringThreshold=1 -XX:CMSInitiatingOccupancyFraction=75 -XX:+UseCMSInitiatingOccupancyOnly -XX:+UseTLAB -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xloggc:/home/ubuntu/results/embedded/gc-$stamp.txt"

echo 3 > sudo /proc/sys/vm/drop_caches
bin/titan.sh config/titan-server-cassandra.properties
