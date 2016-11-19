#!/bin/bash
#Date: 6 Juin 2016
#Version 2.2
#Script de création automatisée d'utilisateur FTP
#V2.2 : Ajoute la possibilité de choisir un DB Host
#V2.1 : Envoi des identifiants par email
#V2 : Vérifie si le Home Directory existe et créé ou adapte les droits en fonction des droits du répertoire
#V1.1 : Ajout fonction Login
#V1 : Gère en terme de droits le cas simple ou l'utilisateur ainsi que le home directory sont bindés aux user/group FTPD
#Yann DANIEL - Bayard Presse

#Entrée des credentials MySQL
echo "Rentrez un login admin MySQL :"
read ADMIN
echo "Rentrez le mot de passe du compte $ADMIN : "
read PASSWD
echo "Rentrez la BDD souhaitée :"
read DB
echo "Rentrez l'adresse du serveur MySQL :"
read DBHOST
#Entrée de la valeur utilisateur et génération password
echo "===== Création d'un utilisateur FTP ======"
echo "Veuillez renseigner le nom d'utilisateur à créer :"
read username
echo "Génération du mot de passe pour $username ..."
userpass=$(/usr/bin/openssl rand -hex 16)
echo "le mot de passe pour l'utilisateur $username est : $userpass"

#On créé le userpath si il n'existe pas et l'on associe les droits dessus
echo "quel est le nom du site ?"
read userpath
userpathexists=$(ls /var/www/ | grep $userpath |wc -l)
if [ $userpathexists -lt 1 ]
then
  echo "Création du Home Directory dans /var/www/$userpath"
#On crée le Home Directory et on y associe les droits par défaut
  mkdir -p /var/www/$userpath && chown -R ftpuser:ftpgroup /var/www/$userpath

# On créé l'utilisateur avec les droits par défaut
echo "Ajout de l'utilisateur dans la base FTPUSER"
mysql -h $DBHOST -u $ADMIN -p"$PASSWD" $DB -e "INSERT INTO \`users\` ( \`User\` , \`Password\` , \`Uid\` , \`Gid\` , \`Dir\` ) VALUES ('${username}', MD5('${userpass}') , '2001', '2001', '/var/www/${userpath}');"

else

  #Le répertoire existe, on adapte donc les droits pour l'utilisateurs
  echo "Le répertoire /var/www/$userpath existe déjà"

  #On récupère d'abord l'utilisateur et le groupe propriétaire du répertoire
  usergranted=$(ls -l /var/www |grep $userpath |awk '{print $3}')
  groupgranted=$(ls -l /var/www |grep $userpath |awk '{print $4}')
  #Vérification des valeurs
  echo -e "Le compte $username disposera des mêmes droits que l'utilisateur : $usergranted "
  echo -e " Le compte $username sera membre du groupe : $groupgranted "

# Puis on récupère l'UID et le GID
  PAMUID=$(grep $usergranted /etc/passwd |awk -F ":" '{print $4}')
  PAMGID=$(grep $groupgranted /etc/group |awk -F ":" '{print $3}')

  echo "Ajout de l'utilisateur dans la base FTPUSER"
  mysql -h $DBHOST -u $ADMIN -p"$PASSWD" $DB -e "INSERT INTO \`users\` ( \`User\` , \`Password\` , \`Uid\` , \`Gid\` , \`Dir\` ) VALUES ('${username}', MD5('${userpass}') , '${PAMUID}', '${PAMGID}', '/var/www/${userpath}');"

fi


echo "Indiquez votre adresse email :"
read usermail
#Récapitulatif des données de compte
#Ajout fonction d'envoi des credentials par email
echo -e "Bonjour $username ! Veuillez conserver votre login et mot de passe pour accéder à $userpath : \n ========== \n Login : $username \n ========== \n Password : $userpass \n ========== \n A bientôt !" | mail -s "Vos identifiants FTP" $usermail
echo "Cher $username, vous allez recevoir vos identifiants par email"
echo "A bientôt !"

exit
