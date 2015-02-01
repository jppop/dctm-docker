FROM tomcat:7

MAINTAINER Jean-Pierre FRANCONIERI <jean-pierre.franconieri@soprasteria.com>

# copy DA war
COPY bundles/da.war ${CATALINA_HOME}/webapps/

# add the script to configue DFC
COPY bundles/make-dfc.properties ${CATALINA_HOME}/bin/

# the entrypoint (wrap catalina script)
COPY bundles/entrypoint.sh ${CATALINA_HOME}/docker-entrypoint.sh

RUN chmod a+x ${CATALINA_HOME}/docker-entrypoint.sh \
 && chmod a+x ${CATALINA_HOME}/bin/make-dfc.properties

# tomcat tuning for DA
ENV CUSTOM_CATALINA_OPTS="-server -Xms512m -Xmx1024m -DMaxPermSize=128 -XX:+UseParallelOldGC" \
    CUSTOM_JAVA_OPTS="-Ddfc.properties.file=${CATALINA_HOME}/conf/dfc.properties"
RUN echo "org.apache.jasper.compiler.Parser.STRICT_WHITESPACE=false" >> ${CATALINA_HOME}/conf/catalina.properties

# ovveride web.xml (disable jsp pooling)
COPY bundles/web.xml ${CATALINA_HOME}/conf/

WORKDIR ${CATALINA_HOME}
# FIXME: can't use variable in ENTRYPOINT directive
ENTRYPOINT [ "./docker-entrypoint.sh", "catalina.sh", "run" ]
CMD ["catalina.sh", "run"]
