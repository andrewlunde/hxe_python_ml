# hxe_python_ml

This project takes a stock HXE Rev33 system and gathers up all the requirements to demonstrate the HANA Python Machine Learning API.  A blog post describing the steps performed by the setup.sh script can be found here.

[Setting up a HANA Express Python Machine Learning API Demo VM](https://blogs.sap.com/2018/11/03/setting-up-a-hana-express-python-machine-learning-api-demo-vm/)

Video:
[Introducing the Python Client API for SAP HANA In-Database Predictive and Machine Learning](https://video.sap.com/media/t/1_0bw54r9a/)


Installation:
[Install the SAP HANA Python Client API for Machine Learning Algorithms](https://help.sap.com/viewer/783036ccbc12499489de18559ce8ff69/2.0.03/en-US/f3365096bb2440fcafdb30e9f51877f1.html?q=python%20%22machine%20learning%22)


API Docs:
[Python Client API for machine learning algorithms](https://help.sap.com/http.svc/rc/3f0dbe754b194c42a6bf3405697b711f/2.0.03/en-US/html/index.html)


```
. set_python_env.sh
```

hxeadm@hxehost:/usr/sap/HXE/HDB90/hxe_python_ml/mta_python_ml/python>

```
jupyter notebook
```

[HANA Python ML : Recognizing hand-written digits](http://hxehost:8080/notebooks/hana_ml_digit_classification.ipynb)

First get the HANA Express Downloader by registering for HANA Express.

https://www.sap.com/sap-hana-express

Be sure to read and agree to the developer license agreement.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_3.png)

Pick the downloader for your platform.  Apple isn’t supported directly so we’ll use the Platform-independent DM.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_6.png)

This will download the file HXEDownloadManager.jar.  In order to run the downloader you must have java installed on your local machine.

Open a terminal window and change to your Downloads directory.

```
cd ~/Downloads
java -jar HXEDownloadManager.jar
```

This will run the HXE Download Manager.

Double check that the Version is 2.00.033.00.20180925.2 and that you’ve selected the Server + apps and Clients for Linux options.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_11.png)

This can take some time depending on your internet connection speed.

Once the download is completed, you’ll have a file called hxexsa.ova and one called clients_linux_x86_64.tgz in your Downloads.

Run VMWare Fusion or your preferred hypervisor app and import the ova file.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_13.png)

On my machine this took about 8 minutes.  Don’t be tempted to give your vm less than 12GB.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_16.png)

When the vm starts up, Confirm the keyboard configuration and change the time zone if desired.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_18.png)

You probably want to set your VM to use bridged networking mode.  Bridged mode allows your VM to get it's own IP that is peer to your host machine.  See your hypervisor documentation for details.

Consult the Getting_Started_HANAexpress_VM.pdf file that was downloaded for details of setting up your machine’s hosts file to override the name resolution for the hostname hxehost.

You should be able to ping your VM from your host machine as hxehost.

```
ping hxehost
```

WAIT! .. resist attempting to login right away.  Give the system about 15 minutes to settle before continuing.  Set a timer for 15 minutes and go get a cup of coffee.

…you waited, right? OK, let’s continue.

Login using the hxeadm user entering password HXEHana1(the default).  You will be prompted to enter the (current) HXEHana1 password again and then your new password twice.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_20-1.png)

Do not forget this password!  It will become the password for the os hxeadm user, the XSA_ADMIN, XSA_DEV users.   See the Getting_Started_HANAexpress_VM.pdf file for details.

You will then be prompted for the password of the db SYSTEM user in both the SYSTEMDB and the tenant HXE db.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_22.png)

If your system needs a proxy setting to reach the internet, configure it now.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_26.png)

The system will now do a bunch of installation/configuration/adjustment/tuning.  This can take at least 30 minutes and you should wait for this to complete before continuing.  More coffee?

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_28.png)

Last chance before continuing.

![](https://blogs.sap.com/wp-content/uploads/2018/11/blog_20181102_30.png)

From this point we’ll ssh into our server with the built-in mac ssh client.  In windows you’ll want to use Putty and Putty-gen to get things set up.  I’m also setting up for passwordless ssh’ing into the server.  There are several ways to do this so I won’t go into detail.  For a quick setup, use ssh-keygen and ssh-copy-id.

```
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub hxeadm@hxehost
```

Open a terminal or ssh client window and ssh to the server.

---

Check that the xs api endpoint is set.

If it isn’t, use the following.

```
xs api https://hxehost:39030/ --cacert=/hana/shared/HXE/xs/controller_data/controller/ssl-pub/router/default.root.crt.pem
```
If the XSA_ADMIN user isn’t logged it, Use this to login and the password set above.
```
xs login -u XSA_ADMIN
```
By default the XS Advanced application runtime has a LOT of things running.  Since we’re very tight on memory we can turn nearly everything off but just the critical apps.  Run these commands.
```
xs target -o HANAExpress -s SAP ; xs a | grep STARTED | grep -v hrtt-service | grep -v di-runner | grep -v di-core | grep -v deploy-service | cut -d ' ' -f 1 | while read -r line ; do echo "Stopping $line"; xs stop $line ; done
```
Note that once the above commands have finished, you won’t be able to access the xsa-cockpit, hana-cockpit, or webide or any other xsa utility.

Run the following to see what’s still started.
```
xs a | grep STARTED
```
The hxeadm user is by default set up to be able to sudo into the root user.

Become the root user by starting a new /bin/bash shell.
```
sudo /bin/bash
```

Double check the IP that your VM is using by running this as root.

```
ifconfig eth0 | grep "inet addr"
```

Setup up the repos so that we can get the needed software loaded.

```
sudo zypper ar http://download.opensuse.org/distribution/leap/42.2/repo/oss/ oss
sudo zypper ar http://download.opensuse.org/distribution/leap/42.2/repo/non-oss/ non-oss
sudo zypper ar http://download.opensuse.org/update/leap/42.2/oss/ update-oss
sudo zypper ar http://download.opensuse.org/update/leap/42.2/non-oss/ update-non-oss
sudo zypper -n --gpg-auto-import-keys refresh
```

Get the git client so that we can clone this repo on the VM.

```
sudo zypper -n --gpg-auto-import-keys install --no-recommends --auto-agree-with-licenses --force-resolution git-core
```

Clone this repo in the hxeadm default directory.

```
cd /usr/sap/HXE/HDB90
git clone https://github.com/alundesap/hxe_python_ml.git
cd hxe_python_ml
```
---

Now run the setup.sh script found in this repo as the hxeadm user.  Be sure to enter the passwords you provided in the steps above.

```
cd /usr/sap/HXE/HDB90/hxe_python_ml/
./setup.sh
```
