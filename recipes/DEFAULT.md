Recipes
-------

### aem:default 

This default AEM Chef recipe does the following:

* create the /apps folder
* download from oracle.com and install the latest jdk7 from oracle in apps/java
* create aem system linux user and group
* set up the aem user ulimit according to node['aem']['max_files'] through ulimit chef recipe
* set up iptables to allow ssh onver port 22 and http on 80 442 and the defined node['aem]['port']
* download the latest aem6 jar file from *???*
* unpack it depending on aem runmode, either in /apps/publish or /app/author
* adapt the start script with runmodes, port and other parameters depending on 
	* clustering (mongomk installation, with mongod installation and / or connection setup)
	* debug
	* aem runmode
	* jvm settings
* copy the license.properties from chef-vault encrypted data bags
* create and copy etc/init.d/aem service script as well as needed CQ_JVM_OPTS env var through the use of a etc/default/aem file
* notify a recipicient list defined in the attributes when the cq service is started/stopped (you may enable/disable this through node['aem']['service']['email_notification'] boolean attribute)
* start the service if not started
* wait for the server to respond