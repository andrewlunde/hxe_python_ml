#!/bin/bash
#
# Enable eval with..
# %s/#eval \$cmd/eval \$cmd/g
#
# Disable eval with..
# %s/eval \$cmd/#eval \$cmd/g

echo "Run like this..."
echo "echo \"Start Over\" > /tmp/progress.log"
echo "export HXEADMPW=\"Plak8484\" ; export HANADBPW=\"Plak8484\" ; export HXEINST=\"00\" ; export XSAORG=\"LCFX\" ; export XSASPACE=\"DEV\" ; ./setup.sh"
echo "Starting..."

hxeadmpw=$HXEADMPW
hanadbpw=$HANADBPW
if [ "$HXEINST" = "" ]
then
   echo "Defaulting to instance 90"
   hxeinst="90"
else
   echo "Using instance $HXEINST"
   hxeinst=$HXEINST
fi

if [ "$XSAORG" = "" ]
then
   echo "Defaulting to org named HANAExpress"
   xsaorg="HANAExpress"
else
   echo "Using org $XSAORG"
   xsaorg=$XSAORG
fi

if [ "$XSASPACE" = "" ]
then
   echo "Defaulting to space named ml"
   xsaspace="ml"
else
   echo "Using space $XSASPACE"
   xsaspace=$XSASPACE
fi

PROGRESS_FILE=/tmp/progress.log
export PROGRESS_FILE=$PROGRESS_FILE
last_step="start_progress"

function write_progress ()
{
    local step_name=$1
    echo "$(date '+%F %H:%M:%S') $step_name" >> "$PROGRESS_FILE"

    if [ $? -ne 0 ]; then
        error_out "failed to update progress"
    fi
}

function read_progress
{
    echo "Reading Progress..."
    local step_name
    step_name=$(tail -1 "$PROGRESS_FILE" | cut -d' ' -f 3)

    if [ $? -ne 0 ]; then
        error_out "failed to read progress"
    fi

    if [ -z $step_name ]; then
       step_name="start_progress"
    fi
    last_step=$step_name
}

read_progress
echo "Last Progress: $last_step"

#echo "hxeadmpw: $hxeadmpw"

if [ -z $hxeadmpw ]; then
  read -s -p "Enter hxeadm password: " hxeadmpw
  cmd="echo The passwd is: $hxeadmpw"
  echo $cmd
  #eval $cmd
  write_progress "got_hxeadmpw"
fi

if [ -z $hanadbpw ]; then
  read -s -p "Enter HANA DB SYSTEM user password: " hanadbpw
  cmd="echo The passwd is: $hanadbpw"
  echo $cmd
  #eval $cmd
  write_progress "got_hanadbpw"
fi

read_progress
case $last_step in
    start_progress) 
        echo "starting progress"
        echo ""
	echo "Be sure that you can run the 'xs a' command to list running applications before continuing."
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
        echo ""
        write_progress "stop_non_crit_xsa"
        ;&
    stop_non_crit_xsa) 
	echo ""
        echo "Stopping non-critical XS apps."
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
	echo ""
	cmd="xs target -o "$xsaorg" -s SAP ; xs a | grep STARTED | grep -v hrtt-service | grep -v di-runner | grep -v di-core | grep -v deploy-service | cut -d ' ' -f 1 | while read -r line ; do echo \"Stopping \$line\"; xs stop \$line ; done"
  	echo $cmd
  	#eval $cmd
        write_progress "setup_repos"
        ;&
    setup_repos)
	echo ""
        echo "Setting up Package Repositories."
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
	echo ""
	cmd="sudo zypper -n --gpg-auto-import-keys refresh"
  	echo $cmd
  	#eval $cmd
	cmd="sudo zypper -n --gpg-auto-import-keys install --no-recommends --auto-agree-with-licenses --force-resolution --type pattern devel_basis"
  	echo $cmd
  	#eval $cmd
	cmd="sudo zypper -n --gpg-auto-import-keys install --no-recommends --auto-agree-with-licenses --force-resolution tk-devel tcl-devel libffi-devel openssl-devel readline-devel sqlite3-devel ncurses-devel xz-devel zlib-devel wget git-core nodejs npm lynx jq libzip2 libzip inotify-tools"
  	echo $cmd
  	#eval $cmd
	echo ""
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
	echo ""
        write_progress "clone_project"
        ;&
    clone_project)
	echo ""
        echo "Git Clone the Python ML Project."
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
	echo ""
	cmd="git clone https://github.com/alundesap/mta_python_ml.git"
  	echo $cmd
  	#eval $cmd
        write_progress "build_python_runtime"
        ;&
    build_python_runtime)
	echo ""
        echo "Build and install the pyton runtime."
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
	echo ""
	cmd="wget -c https://www.python.org/ftp/python/3.7.1/Python-3.7.1.tgz"
  	echo $cmd
  	#eval $cmd
	cmd="wget -c http://thedrop.sap-a-team.com/files/hana_ml-1.0.3.tar.gz"
  	echo $cmd
  	#eval $cmd
	cmd="wget -c http://thedrop.sap-a-team.com/files/XS_PYTHON00_1-70003433.ZIP"
  	echo $cmd
  	#eval $cmd
	cmd="tar xzvf Python-3.7.1.tgz ; md python_3_7_1 ; cd Python-3.7.1 ; ./configure --prefix=/usr/sap/HXE/HDB"$hxeinst"/hxe_python_ml/python_3_7_1/ --exec-prefix=/usr/sap/HXE/HDB"$hxeinst"/hxe_python_ml/python_3_7_1/ ; make -j4 ; make altinstall"
  	echo $cmd
  	#eval $cmd
	cmd="cd ../python_3_7_1/bin ; ln -s easy_install-3.6 easy_install ; ln -s pip3.6 pip ; ln -s pydoc3.6 pydoc ; ln -s python3.6 python ; ln -s pyvenv-3.6 pyvenv"
  	echo $cmd
  	#eval $cmd
        echo ""
        echo ""
        echo "Note: When setting up python on your own server:  "
        echo " If you find that the pip command below fails with an inablility to import the _socket library, "
        echo " it’s because the configure/build process under some variations of linux leaves some important libraries in an unexpected location."
        echo " Change into the directory where the target python was installed."
        echo "cd python_3_7_1"
        echo " Copy the files in the lib64 folder into the lib folder"
        echo "cp -avp lib64/* lib"
        echo " Uninstall the runtime. By first finding it’s ID and then deleting it."
        echo ""
        echo ""
	cmd="xs create-runtime -p /usr/sap/HXE/HDB"$hxeinst"/hxe_python_ml/python_3_7_1/"
  	echo $cmd
  	#eval $cmd
	cmd="cd ../.."
  	echo $cmd
  	#eval $cmd
	cmd="unzip XS_PYTHON00_1-70003433.ZIP -d sap_dependencies"
  	echo $cmd
  	#eval $cmd
	cmd=". set_python_env.sh"
  	echo $cmd
  	#eval $cmd
	cmd="mkdir -p vendor ; pip download -d vendor -r requirements.txt --find-links ../../sap_dependencies --find-links ../../hana_ml-1.0.3.tar.gz hana_ml ; cd .."
  	echo $cmd
  	#eval $cmd
        write_progress "prep_hxe_tenant"
        ;&
    prep_hxe_tenant)
	echo ""
        echo "Prepare HANA HXE Tenant for deploys."
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
	echo ""
	cmd="hdbsql -i "$hxeinst" -n localhost:3"$hxeinst"13 -u SYSTEM -p "$hanadbpw" -d SYSTEMDB \"ALTER DATABASE HXE ADD 'scriptserver'\""
  	echo $cmd
  	#eval $cmd
	cmd="xs create-space "$xsaspace" -o "$xsaorg""
  	echo $cmd
  	#eval $cmd
	cmd="xs set-space-role XSA_ADMIN "$xsaorg" "$xsaspace" SpaceManager"
  	echo $cmd
  	#eval $cmd
	cmd="xs set-space-role XSA_ADMIN "$xsaorg" "$xsaspace" SpaceDeveloper"
  	echo $cmd
  	#eval $cmd
	cmd="xs set-space-role XSA_DEV "$xsaorg" "$xsaspace" SpaceManager"
  	echo $cmd
  	#eval $cmd
	cmd="xs set-space-role XSA_DEV "$xsaorg" "$xsaspace" SpaceDeveloper"
  	echo $cmd
  	#eval $cmd
	cmd="xs enable-tenant-database HXE -u SYSTEM -p $hanadbpw -t $hxeadmpw"
  	echo $cmd
  	#eval $cmd
	cmd="xs map-tenant-database HXE -o "$xsaorg" -s "$xsaspace""
  	echo $cmd
  	#eval $cmd
        write_progress "build_ml_demo_app"
        ;&
    build_ml_demo_app)
	echo ""
        echo "Build the DB and Python application modules."
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
	echo ""
	cmd="xs t -s "$xsaspace""
  	echo $cmd
  	#eval $cmd
	cmd="cd /usr/sap/HXE/HDB"$hxeinst"/hxe_python_ml/mta_python_ml"
  	echo $cmd
  	#eval $cmd
	cmd="xs create-service hana hdi-shared python-ml-hdi"
  	echo $cmd
  	#eval $cmd
	cmd="xs create-service xsuaa default python-ml-uaa"
  	echo $cmd
  	#eval $cmd
	cmd="cd db ; npm install ; cd .."
  	echo $cmd
  	#eval $cmd
	cmd="xs push python-ml.db -k 1024M -m 256M -p db --no-start --no-route"
  	echo $cmd
  	#eval $cmd
	cmd="xs bind-service python-ml.db python-ml-hdi"
  	echo $cmd
  	#eval $cmd
	cmd="xs restart python-ml.db --wait-indefinitely ; sleep 15 ; xs stop python-ml.db"
  	echo $cmd
  	#eval $cmd
	cmd="xs push python-ml.python -k 1024M -m 256M -n python -p python --no-start"
  	echo $cmd
  	#eval $cmd
	cmd="xs bind-service python-ml.python python-ml-hdi"
  	echo $cmd
  	#eval $cmd
	cmd="xs bind-service python-ml.python python-ml-uaa"
  	echo $cmd
  	#eval $cmd
	cmd="xs start python-ml.python"
  	echo $cmd
  	#eval $cmd
	cmd="pymodurl=\$(xs app python-ml.python --urls) ; echo \$pymodurl"
  	echo $cmd
  	#eval $cmd
        write_progress "build_web_module"
        ;&
    build_web_module)
        echo ""
        echo "Build the web module and adjust the target route."
        echo ""
	cmd="cd web ; npm install ; cd .."
  	echo $cmd
  	#eval $cmd
	cmd="xs push python-ml.web -k 1024M -m 256M -n web -p web --no-start"
  	echo $cmd
  	#eval $cmd
	cmd="xs bind-service python-ml.web python-ml-uaa"
  	echo $cmd
  	#eval $cmd
	cmd="xs set-env  python-ml.web destinations '[{\"forwardAuthToken\":true, \"name\":\"python_be\", \"url\":\""$pymodurl"\"}]'"
  	echo $cmd
  	#eval $cmd
	cmd="xs start python-ml.web"
  	echo $cmd
  	#eval $cmd
	cmd="pyweburl=\$(xs app python-ml.web --urls) ; echo \$pyweburl"
  	echo $cmd
  	#eval $cmd
        write_progress "get_user_add_role"
        ;&
    get_user_add_role)
        echo "Get the HDI user and add the AFLPAL role."
	cmd="hdiusr=\$(xs env python-ml.python | grep '\"user\"' | cut -d \":\" -f 2 | cut -d '\"' -f 2) ; echo \$hdiusr"
  	echo $cmd
  	#eval $cmd
	cmd="hdbsql -i "$hxeinst" -n localhost:3"$hxeinst"15 -u SYSTEM -p "$hanadbpw" -d HXE \"grant AFL__SYS_AFL_AFLPAL_EXECUTE to "$hdiusr"\""
  	echo $cmd
  	#eval $cmd
	cmd="echo \"Python Demo App can be found at: \"\$pyweburl"
  	echo $cmd
  	#eval $cmd
        write_progress "do_stepX"
        ;&
    do_stepX)
	echo ""
        echo "stepX_thing"
	read -s -p "Continue? (Enter=Yes, Ctrl-C to exit)" contyn
	echo ""
        echo ""
	cmd=""
  	echo $cmd
  	#eval $cmd
        write_progress "scrpt_completed"
        ;;
esac

#write_progress "script_completed"

echo "Ending..."
echo 'Reset with: echo "Start Over" > /tmp/progress.log'
