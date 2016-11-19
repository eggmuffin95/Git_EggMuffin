# Prepare Apache pour executer plusieurs version de PHP avec phpbrew

**ATTENTION !!! POUR L'INSTANT LES TESTS NE SONT PAS SATISFAISANTS !!!**
**C'est preferable d'utiliser le Serveur embarqué PHP et pas Apache**

##Mais si vraiment vous voulez essayer :

**Necessaire seulement si c'est la première fois qu'on installe apxs2**

```bash
# Install apache2-dev package
$ sudo apt-get install apache2-dev
# Verify that apxs2 is now available
$ which apxs2
/usr/bin/apxs2

# Open write access to /usr/lib/apache2/modules
$ sudo chmod -R oga+rw /usr/lib/apache2/modules
# Open write access to /etc/apache2
$ sudo chmod -R oga+rw /etc/apache2
# Open write access to /etc/apache2
$ sudo chmod -R oga+rw /var/lib/apache2

# Give possibility to run a2enmod && a2dismod to normals users
$ sudo ln -s $(sudo which a2enmod) /usr/local/bin/a2enmod
$ sudo ln -s $(sudo which a2dismod) /usr/local/bin/a2dismod
```
