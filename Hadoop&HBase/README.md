# Hadoop&HBase

## Hadoop

### 配置

1. 安装jdk

2. must allow ssh localhost to run without password
   配置hadoop伪分布式的话，需要本机对本机能够进行免密码访问，直接将公钥文件id_rsa.pub的文件追加到authorized_keys中即可
   sudo apt-get install ssh
   cd ~                                             #最好在要配置的用户的家目录下
   ssh-keygen -t rsa                                #生成rsa密钥对，也可以选dsa
   cp ./.ssh/id_rsa.pub ./.ssh/authorized_keys      #id_rsa.pub是公钥，id_rsa是私钥
   ssh localhost                                    #验证，第一次要输入‘yes’确认加入the list of known hosts

3. 安装hadoop
3.1 unpackage到/usr/local
 tar zxvf hbase-0.98.11-hadoop2-bin.tar.gz
 tar zxvf hadoop-2.6.0.tar.gz

3.2 把下面的加到 ~/.bashrc 中，要尽量放到前面(见3.6 note)

export JAVA_HOME=/usr/local/java/jdk1.8.0_77

export HADOOP_HOME=/usr/local/hadoop-2.6.0
export HBASE_HOME=/usr/local/hbase-0.98.11-hadoop2

export CLASSPATH=${CLASSPATH}:`$HADOOP_HOME/bin/hadoop classpath --glob`

export PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${HBASE_HOME}/bin

3.3 sudo chown -R will:will $HADOOP_HOME
    sudo chown -R will:will $HBASE_HOME

3.3 在hadoop安装目录

  $HADOOP_HOME/etc/hadoop/core-site.xml

<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/home/will/work/hdfs</value>    -------------自己设!
    </property>
</configuration>

  $HADOOP_HOME/etc/hadoop/hdfs-site.xml

<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>

3.4 在shell中执行: hdfs namenode -format

3.5 $HADOOP_HOME/sbin/start-dfs.sh   #直接start-dfs.sh就行
   note: must define JAVA_HOME at the very beginning of .bashrc
         otherwise won't be executed in ssh localhost ，否则在hadoop-env.sh中改JAVA_HOME=....  绝对地址
   然后打开页面验证hdfs安装成功: http://localhost:50070/
   stop-dfs.sh

3.6 配置yarn

  $HADOOP_HOME/etc/hadoop/mapred-site.xml

<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapred.job.tracker</name>
        <value>localhost:9001</value>
    </property>
</configuration>

  $HADOOP_HOME/etc/hadoop/yarn-site.xml

<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
</configuration>

   start-yarn.sh 然后打开页面检查yarn: http://localhost:8088/cluster

### 阅读 Hadoop 源码

将 hadoop 源码转成 eclipse 项目导入 eclipse 中

```bash
# sudo apt-get install g++ maven protobuf-compiler=2.5.0 cmake zlib1g-dev findbugs
# cd hadoop 的源码目录
# cd ./hadoop-maven-plugins
# mvn install
# cd ../** 你想构建的项目目录
# mvn eclipse:eclipse -DskipTests
```

## HBase

1. 配置

  $HBASE_HOME/conf/hbase-site.xml

<configuration>
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
    <property>
        <name>hbase.rootdir</name>
        <value>hdfs://localhost:9000/hbase</value>
    </property>
    <property>
        <name>hbase.zookeeper.property.dataDir</name>
        <value>/home/will/work/hbase-zookeeper</value>    -------------自己设!
    </property>
</configuration>

2. start-hbase.sh
    stop-hbase.sh