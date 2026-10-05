# Liquibase's official image has no MongoDB support built in. Two packages,
# not one — installing only "mongodb" fails with "Driver class was not
# specified and could not be determined from the url"
# (rules/2-anexos/B-db-mongo.md, "Instalar la extensión").
FROM liquibase/liquibase:4.29

RUN lpm add liquibase-mongodb mongodb --global
