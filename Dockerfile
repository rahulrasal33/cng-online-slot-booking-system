FROM tomcat:9.0-jdk17-temurin AS build

WORKDIR /app
COPY src/main/java/ ./src/main/java/
COPY src/main/webapp/WEB-INF/lib/ ./WEB-INF/lib/
RUN mkdir -p ./WEB-INF/classes \
    && javac -encoding UTF-8 -cp "./WEB-INF/lib/*" -d ./WEB-INF/classes $(find src/main/java -name "*.java")

FROM tomcat:9.0-jre17-temurin

RUN rm -rf /usr/local/tomcat/webapps/*
COPY src/main/webapp/ /usr/local/tomcat/webapps/ROOT/
COPY --from=build /app/WEB-INF/classes/ /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/
RUN rm -f /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/javax.servlet-api-*.jar

EXPOSE 8080
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/\" \"$CATALINA_HOME/conf/server.xml\" && exec catalina.sh run"]
