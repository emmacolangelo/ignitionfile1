FROM scratch

RUN apt-get -y update

# Standard Architecture Example
# https://inductiveautomation.com/ignition/architectures
# https://inductiveautomation.com/static/pdf/IgnitionArchitecture-Standard.pdf
---
x-default-logging:
  &default-logging
  logging:
    options:
      max-size: '100m'
      max-file: '5'
    driver: json-file

x-ignition-opts:
  &ignition-opts
  <<: *default-logging
  image: inductiveautomation/ignition:${IGNITION_VERSION:-latest}
  env_file: gw-init/gateway.env
  secrets:
    - gateway-admin-password

services:
  gateway:
    <<: *ignition-opts
    hostname: gateway
    ports:
      - 8088:8088
    command: >
      -n Ignition-standard
      -m ${GATEWAY_MAX_MEMORY:-1024}
      -r /restore.gwbk
      -a gateway.localtest.me
      -h 8088
      -s 8043
    environment:
      GATEWAY_NETWORK_REQUIRESSL: false
      GATEWAY_NETWORK_SECURITYPOLICY: SpecifiedList
      GATEWAY_NETWORK_WHITELIST: Ignition-gatewayr-backup,Ignition-standard-backup
    volumes:
      - gateway-data:/usr/local/bin/ignition/data
      - ./gw-backup:/backup
      - ./gw-init/base.gwbk:/restore.gwbk
      - ./gw-init/gateway-${COMPOSE_PROFILES:-independent}.xml:/usr/local/bin/ignition/data/redundancy.xml

  gatewayr:
    <<: *ignition-opts
    hostname: gatewayr
    ports:
      - 8089:8088
    command: >
      -m ${GATEWAY_MAX_MEMORY:-1024}
      -a gatewayr.localtest.me
      -h 8089
      -s 8043
    profiles:
      - redundancy
    environment:
      ACCEPT_IGNITION_EULA: "Y"
      GATEWAY_ADMIN_USERNAME: admin
      GATEWAY_ADMIN_PASSWORD_FILE: /run/secrets/gateway-admin-password
    volumes:
      - gatewayr-data:/usr/local/bin/ignition/data
      - ./gw-init/gatewayr-redundancy.xml:/usr/local/bin/ignition/data/redundancy.xml

  db:
    <<: *default-logging
    image: mariadb:${MARIADB_VERSION:-latest}
    ports:
      - 3306:3306
    environment:
      MARIADB_USER: ignition
      MARIADB_PASSWORD: ignition
      MARIADB_DATABASE: ignition
      MARIADB_ROOT_PASSWORD: ignition
    volumes:
      - db-data:/var/lib/mysql
    
secrets:
  gateway-admin-password:
    file: secrets/gateway-admin-password

volumes:
  gateway-data:
  gatewayr-data:
  db-data:
