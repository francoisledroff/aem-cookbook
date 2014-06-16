aem-cookbook
=============


While AEM/CQ installations are very straightforward, there are still plenty of configurations that can be automated using Chef:

* AEM/CQ as a service, 
* ldap authentication, 
* security check list
* Dispatcher installation and configuration, replication agent configurations...
* mod ssl
* and more (firewall, log rotation config)


Requirements
------------
* Tested with chef 11.4.4, 11.6 and 11.8.2
* tested on CentOS 6.4, RHEL 5.5, RHEL 5.10
* requires the use of **chef-vault** 

Our aem recipes are pre-wired to make use of chef-vault to protect and inject secrets (especially in the dispatcher and secure recipe) 



Attributes
----------

There are quite a few, please refer to the source and at recipes docs listed  below.

Recipes
----------


### aem:default 

This default aem Chef recipe does the following:

* download from oracle.com and install the latest jdk6 from oracle in apps/java
* create aem system linux user and group
* download the latest aem.5 jar file from bsi-nexus 
* unpack it depending on cq mode, either in /apps/publish or /app/author
* copy the license.properties from chef-vault encrypted data bags
* copy serverctl shell (shipped with aem.4)
* create and copy etc/init.d/aem service script as well as needed CQ_JVM_OPTS env var through the use of a etc/default/aem file
* enable the newly created aem service 

### aem:start

* start the service if not started
* wait for the server to respond on ping and http


### aem:dispatcher 

This aem Chef recipe will configure apache dispatcher (it does not reuse the community apache2 cookbook, but does reuse some of its techniques and attributes), it does:

* install apache rpm in default OS node['apache']['dir']
* create node['apache']['docroot_dir']
* will download the dispatcher module apache dynamic library binary from our nexus repo 
* add the associated dispatcher module specific conf 
* install and start httpd service
* ensure the httpd service is running

on top of the above, if `node['apache']['ssl']` :

* mod_ssl is installed
* the recipe leverage an ssl conf template (with virtual host) 
* the cq ssl dispatcher module is installed
* create the OpenSSL needed symbolic links for you.

	
### aem:secure 

this recipe will apply the security checklist cf. http://dev.day.com/docs/en/cq/current/deploying/security_checklist.html 

For now it :

* changes the default cq admin credentials and use chef-vault to manage and protect the credentials
* uninstalls and deletes all geometrix packages
* disables the crxde support
* disables webdav

### aem:logrotate

this recipe will rotate all aem and apache log files.


License & Authors
==================

License Apache 2
Francois Le Droff

