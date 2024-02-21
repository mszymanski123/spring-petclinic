FROM eclipse-temurin:17-jdk-jammy AS base
WORKDIR /app
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw dependency:go-offline

FROM base AS dev
COPY src src
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=mysql", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM base AS build
COPY src src
RUN ./mvnw package -DskipTests

FROM eclipse-temurin:17-jdk-jammy AS prod
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/target/spring-petclinic-*.jar ./spring-petclinic.jar
CMD ["java", "-jar", "spring-petclinic.jar"]