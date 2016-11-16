FROM ubuntu
MAINTAINER mukki
RUN  apt-get update
RUN  apt-get -y upgrade
RUN  apt-get -y install apache2 mysql-client  libapache2-mod-perl2 libcurl4-openssl-dev libssl-dev  libapr1-dev libaprutil1-dev libmysqlclient-dev libmagickcore-dev li$
RUN  apt-get -y install subversion libapache2-svn
RUN  mkdir -p /var/lib/svn
RUN  chown -R www-data:www-data /var/lib/svn
RUN  a2enmod dav_svn
#RUN  rm -f /etc/apache2/mods-enabled/dav_svn.conf
WORKDIR  /tmp/redmine/
ADD dav_svn.conf /etc/apache2/mods-enabled/
RUN wget 
ADD  dav_svn.passwd /etc/apache2/
RUN  svnadmin create --fs-type fsfs /var/lib/svn/my_repository
RUN chown -R www-data:www-data /var/lib/svn
ADD  dav_svn.authz /etc/apache2/
RUN  apt-get -y install  software-properties-common
RUN  add-apt-repository ppa:brightbox/ruby-ng
RUN  apt-get update
RUN apt-get -y install ruby2.1 ruby-switch ruby2.1-dev ri2.1 libruby2.1 libssl-dev zlib1g-dev
RUN  ruby-switch --set ruby2.1
RUN  gpg --keyserver hkp://pgp.mit.edu --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN  curl -sSL https://get.rvm.io | bash -s stable
RUN  apt-get -y install ruby1.9.3 ruby1.9.1-dev ri1.9.1 libruby1.9.1 libssl-dev zlib1g-dev
RUN  update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby1.9.1.1.gz --sla$
RUN  gem update
RUN  gem install bundler

WORKDIR  /usr/share
RUN  wget http://www.redmine.org/releases/redmine-3.0.4.tar.gz
RUN  tar xvfz redmine-3.0.4.tar.gz
RUN  rm redmine-3.0.4.tar.gz
RUN  mv redmine-3.0.4 redmine
RUN  chown -R root:root /usr/share/redmine
RUN  chown -R www-data:www-data /usr/share/redmine
RUN chown www-data /usr/share/redmine/config/environment.rb
RUN  ln -s /usr/share/redmine/public /var/www/html/redmine
WORKDIR  /tmp/redmine
ADD  database.yml /usr/share/redmine/config/
WORKDIR /usr/share/redmine/
RUN  bundle install --without development test postgresql sqlite
RUN  rake generate_secret_token
RUN  rake db:migrate RAILS_ENV=production
RUN RAILS_ENV=production REDMINE_LANG=fr bundle exec rake redmine:load_default_data
RUN  chown -R www-data:www-data files log tmp public/plugin_assets
RUN  chmod -R 755 files log tmp public/plugin_assets
RUN  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
RUN apt-get -y install apt-transport-https ca-certificates
WORKDIR /tmp/redmine
ADD  passenger.list /etc/apt/sources.list.d/
RUN  chown www-data:www-data /etc/apt/sources.list.d/passenger.list
RUN  chown root: /etc/apt/sources.list.d/passenger.list
RUN  chmod 777 /etc/apt/sources.list.d/passenger.list
RUN  apt-get update
RUN apt-get -y install libapache2-mod-passenger
RUN rm -f /etc/apache2/mods-available/passenger.conf
WORKDIR /tmp/redmine
ADD  passenger.conf /etc/apache2/mods-available/
ADD  default.conf /etc/apache2/sites-available/
RUN a2enmod passenger
RUN  a2ensite default.conf
RUN a2dissite 000-default.conf
EXPOSE 80
ENTRYPOINT service apache2 restart && sleep 3600

