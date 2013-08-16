#!/bin/bash
#!/bin/bash
set -x
sudo killall -9 java
sudo rm -vrf /var/lib/cassandra/*
export stamp=`date +%Y%m%d%H%M%S`
export JVM_OPTS="-Xmx10G -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xloggc:/home/ubuntu/results/local/gc-cassandra-$stamp.txt"
sudo ~/apache-cassandra-1.2.8/bin/cassandra
sleep 10

bin/gremlin.sh <<SCRIPT
g = TitanFactory.open("bin/cassandra.local")
g.makeType().name("name").dataType(String.class).unique(OUT).indexed(Vertex).makePropertyKey();
g.makeType().name("title").dataType(String.class).unique(OUT).indexed(Vertex).makePropertyKey();
GraphSONReader.inputGraph(g,new FileInputStream(new File("/home/ubuntu/marvel.graphson")))
exit
SCRIPT


export JAVA_OPTIONS="-Xmx10G -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Xloggc:/home/ubuntu/results/local/gc-titan-$stamp.txt"
echo 3 > sudo /proc/sys/vm/drop_caches
bin/titan.sh bin/cassandra.local
