#!/bin/bash
#
# Enable eval with..
# %s/#eval \$cmd/eval \$cmd/g
#
# Disable eval with..
# %s/eval \$cmd/#eval \$cmd/g

echo ""
read -s -p "Enter hxeadm password: " hxeadmpw

cmd="echo The passwd is: $hxeadmpw"
echo $cmd
eval $cmd

echo ""
echo 'Verify that your /etc/hosts file contains hxehost.'
echo "Example.."
echo '192.168.124.14       hxehost'

echo ""
echo "In the VMWare console, login with.."
echo ""
echo "hxehost login: hxeadm"
echo "Password: $hxeadmpw"

#as root
zypper -n --gpg-auto-import-keys install --no-recommends --auto-agree-with-licenses --force-resolution --type pattern devel_basis

zypper -n --gpg-auto-import-keys install --no-recommends --auto-agree-with-licenses --force-resolution tk-devel tcl-devel libffi-devel openssl-devel readline-devel sqlite3-devel ncurses-devel xz-devel zlib-devel

#as hxeadm

wget http://thedrop.sap-a-team.com/files/hana_ml-1.0.3.tar.gz
wget http://thedrop.sap-a-team.com/files/XS_PYTHON00_0-70003433.ZIP
wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz

tar xzvf Python-3.6.5.tgz
md python_3_6_5
cd Python-3.6.5
./configure --prefix=/usr/sap/HXE/HDB90/hxe_python_ml/python_3_6_5/ --exec-prefix=/usr/sap/HXE/HDB90/hxe_python_ml/python_3_6_5/ ; make -j4 ; make altinstall

cd ../python_3_6_5/bin

ln -s easy_install-3.6 easy_install
ln -s pip3.6 pip
ln -s pydoc3.6 pydoc
ln -s python3.6 python
ln -s pyvenv-3.6 pyvenv

xs create-runtime -p /usr/sap/HXE/HDB90/hxe_python_ml/python_3_6_5/

cd ../..

unzip XS_PYTHON00_0-70003433.ZIP -d sap_dependencies

