FROM openjdk:8u242-jre

WORKDIR /opt

ENV HADOOP_VERSION=3.2.1
ENV METASTORE_VERSION=3.0.0

ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin
ENV APACHE_REPO=https://mirrors.tuna.tsinghua.edu.cn/apache

RUN curl -L ${APACHE_REPO}/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf -
RUN curl -L ${APACHE_REPO}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf -
RUN curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
    rm -rf  mysql-connector-java-8.0.19
RUN wget -c https://jdbc.postgresql.org/download/postgresql-42.2.11.jar &&\
    cp postgresql-42.2.11.jar ${HIVE_HOME}/lib/ && \
    rm -rf postgresql-42.2.11.jar

RUN ls $HADOOP_HOME/share/hadoop/common/lib | grep guava && \
  ls $HIVE_HOME/lib | grep guava && \
  cp $HADOOP_HOME/share/hadoop/common/lib/guava-27.0-jre.jar $HIVE_HOME/lib/ && \
  rm $HIVE_HOME/lib/guava-19.0.jar

COPY conf/metastore-site.xml ${HIVE_HOME}/conf
COPY scripts/entrypoint.sh /entrypoint.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
