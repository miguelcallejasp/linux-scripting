################################################################################
#                           SCRIPT ADD EC2 TO CLUSTER ECS                      #
################################################################################

#Change MyCluster
#!/bin/bash
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=starflex
ECS_ENGINE_AUTH_TYPE=docker
ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/":{"username":"mojixcloudops","password":"35c-CWN-7mL-akt","email":"cloudops@mojix.com"}}
ECS_LOGLEVEL=debug
EOF


 memberOf(attribute:db == ok)

attribute:services == yes
attribute:db == ok
