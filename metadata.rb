name             'aaem'
maintainer       'Francois Le Droff'
maintainer_email 'francois.le.droff@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures aem/cq'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends 'chef-vault-util', '~> 1.0.1'
depends 'java', '~> 1.22.0'
depends 'ulimit', '~> 0.3.2'
depends 'logrotate', '~> 1.6.0'
