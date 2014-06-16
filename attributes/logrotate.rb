################################
## logrotate related attributed
################################    
# we could add more options if needed cf. https://github.com/stevendanna/logrotate
# sets the frequency for rotation. Default value is 'weekly'. Valid values are: daily, weekly, monthly, yearly, see the logrotate man page for more information.  
default['aem']['logrotate']['frequency'] = 'daily'
default['aem']['logrotate']['rotate'] = 30

 