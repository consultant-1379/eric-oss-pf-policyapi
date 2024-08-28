FROM armdocker.rnd.ericsson.se/proj-orchestration-so/eric-oss-pf-base-image:2.21.0
ENV POLICY_LOGS=/var/log/onap/policy/api
ENV POLICY_HOME=/opt/app/policy/api

RUN zypper in -l -y shadow wget
RUN zypper in -l -y zip
RUN mkdir -p $POLICY_LOGS $POLICY_HOME $POLICY_HOME/bin && \
    groupadd policy && \
    useradd -d $POLICY_HOME -m -s /bin/bash policy && \
    chown -R policy:policy $POLICY_HOME $POLICY_LOGS

RUN wget --no-check-certificate https://arm.epk.ericsson.se/artifactory/list/proj-policy-framework-generic-local/com/ericsson/policy-api/policy-api-tarball-2.1.3-SNAPSHOT-tarball.tar.gz && \
    tar -zxvf policy-api-tarball-2.1.3-SNAPSHOT-tarball.tar.gz --directory $POLICY_HOME && \
    rm policy-api-tarball-2.1.3-SNAPSHOT-tarball.tar.gz

WORKDIR $POLICY_HOME
COPY policy-api.sh  bin/.

# Added to fix SM-111272 & SM-114368
RUN zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/SocketServer.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSSink.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/jdbc/JDBCAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/chainsaw/*

RUN chown -R policy:policy * && chmod 755 bin/*.sh

USER policy
WORKDIR $POLICY_HOME/bin
ENTRYPOINT [ "bash", "./policy-api.sh" ]
