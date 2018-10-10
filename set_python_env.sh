#!/bin/bash
export PYTHONHOME=/usr/sap/HXE/HDB90/hxe_python_ml/python_3_6_5
unset PYTHONSTARTUP
export PATH=$PYTHONHOME/bin:$PATH
export PYTHONUSERBASE=/usr/sap/HXE/HDB90/hxe_python_ml/mta_python_ml/python/vendor/
export PYTHONPATH=$PYTHONUSERBASE
#
# For local building of NodeJS
npm config set @sap:registry "https://npm.sap.com/" ; npm config set registry "https://registry.npmjs.org/" ; npm config set strict-ssl true
#
vcapsvcs=$(cat <<EOF
{
}
EOF
)
export VCAP_SERVICES=$vcapsvcs

cd mta_python_ml/python
