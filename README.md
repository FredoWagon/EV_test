# EV_test

Bonjour Eventmaker !<br/> 
Voici mon test d'intégration.<br/>
Cela s'est bien passé à un détail près :blush:<br/>
Je reviens sur ce détail plus bas.

## Consignes

1. Effectuer une requête sur l'API Eventmaker afin de récupérer la liste des invités d'un événement

2. Créer un fichier CSV à partir de cette liste avec les "headers" suivant :
    - email
    - company_name
    - identity (concaténation du "first_name" et du "last_name" des invités)
    - uid
    - from tesla (champ qui renvoie "true"/"false" si l'invité travaille chez "tesla")

3. Envoyer le fichier sur le server FTP fourni
    - Le nommage du fichier doit être clair et posséder un "timestamp" afin de suivre les versions 

4. Télécharger en retour, ce même fichier, à partir du server FTP

5. Afficher dans le terminal le contenu de ce fichier

## Configuration 

Renseigner les variables de configuration:

Pour la requête API:

    API_KEY = "*****"
    
Pour la connexion FTP:

    FTP_LOGIN = "*****"
    FTP_PASSWORD = "*****"
    
    FTP_HOST = "*****"
    FTP_IP = "*****"
   
## Problème de connexion FTP

J'ai codé ce script samedi en utilisant mon propre
server FTP, tout fonctionnait jusqu'a ce que lundi (hier),
en finalisant le script, j'ai migrer la connexion vers le 
server FTP que vous m'avez fourni.

La connexion s'effectue..

- J'arrive à utiliser certaines methodes fournies par Net::FTP
    tel que "ftp.status()" qui m'indique que la connexion est active.
    
- J'arrive à créer un dossier "/fred"

- J'arrive à me déplacer dans ce dossier

mais.. 

- La methode .list()
- La methode .putbinaryfile()
- La methode .getbinaryfile()

qui me sont nécessaires à la réalisation de l'exercice fige la relation au server FTP
après m'avoir envoyé comme dernier message : 

    get: 227 Entering Passive Mode (172,26,5,74,84,22)
    
Aucun message d'erreur est envoyé, la connexion persiste.
Seulement aucune communication peut s'effectuer à partir d'ici, la relation est comme 
figé et à terme la connexion coupé pour raison de temps.

J'ai passé un certain temps à chercher une solution sans y parvenir, malheureusement :sweat_smile: </br>

De ma compréhension, limitée, d'un server FTP j'imagine grossièrement deux pistes : 
- Ma connexion (peut être sa nature, je passe par mon téléphone)
- La configuration du server FTP

## Proposition d'une solution pour l'execution du script
Afin de voir le script fonctionnel, je vous propose de passer par mon server FTP. </br>
Les variables nécessaires à son utilisation sont fournies dans le mail
que je viens de vous envoyer.

Dans ce cas,</br>
veuillez remplir les champs suivant avec ces variables :

    FTP_LOGIN = "*****"
    FTP_PASSWORD = "*****"
    
    FTP_HOST = "*****"
    FTP_IP = "*****"

veuillez commenter la ligne :

    #FTP_PORT = "*****"
    

  
  
  
  
  
  



  




