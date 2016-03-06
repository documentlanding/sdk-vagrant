Introduction
============

[Main Document Landing SDK Documentation](https://github.com/documentlanding/sdk-bundle)

This vagrant box and detailed suggestions exist to make installing
a local virtual machine and jumping straight into local development
as streamlined as possible.

The VM uses VirtualBox. Ubuntu 14.04 LTS, NGINX, PHP5-FPM and MySQL 
are installed and configured for immediate functionality. The latest
Document Landing SDK is downloaded and configured automatically.

Use of ngrok is also detailed here for local testing of the SDK.
If you're unfamiliar with ngrok, it is incredibly useful.  Not only
does it create a public address for your local site, it allows 
re-runs of incoming requests and profiling of responses.


Recommended Procedure
=====================

1) Local Installations
----------------------

 - https://www.vagrantup.com/downloads
 - https://www.virtualbox.org/wiki/Downloads
 - https://ngrok.com
 - Download this repository


2) Create the VM
----------------

```
cd your/local/path/to/documentlanding/sdk-vagrant
vagrant up
```

The site is now available at http://localhost:4002 or http://192.168.50.5 .
192.168.50.5 is simply used to make local DNS rules easy, if desired.


3) Login to the VM
------------------

SFTP Client Settings:

```
Server: 192.168.50.5
User: vagrant
Password: vagrant
```

Or Command line:

```
cd your/local/path/to/documentlanding/sdk-vagrant
vagrant ssh
```

4) Change API Key
-----------------

Navigate to app/config/config.yml and change "sdk_api_key" value.
This is the "API Key" value required in the Custom Service page of
Document Landing.


5) Start ngrok
--------------

```
ngrok 4002
```

ngrok assigns a public url ({subdomain}.ngrok.com) that now points
to your local 4002 port, which is mapped forward to port 80 of your VM.
You can create an account with ngrok if you want to control your
subdomain.


6) Custom Service Settings at Document Landing
----------------------------------------------

Submission URL:  http://{subdomain}.ngrok.com/api/lead/create-or-update

Fields URL:  http://{subdomain}.ngrok.com/api/lead/fields

Lead Load URL:  http://{subdomain}.ngrok.com/api/lead/load

API Key:  Whatever you decided in step 4.


Last Thoughts
=============

The rest of the implementation details can be found in the comments within
the files in SdkDemoBundle.  Here are a couple useful things to know if you're not 
accustomed to Symfony2 (http://symfony.com/doc/current/book/index.html) or
Vagrant.

If you make changes DocumentLanding\SdkDemoBundle\Entity\Lead, you will need the changes
to be made in MySQL.

First SSH into the (running) VM.

```
cd your/local/path/to/documentlanding/sdk-vagrant
cd vagrant
vagrant ssh
```

Then from within the VM run the following command.

```
sudo php app/console doctrine:schema:update --force
```