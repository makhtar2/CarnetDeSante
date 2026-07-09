# Scénario et Guide pour la Vidéo de Démonstration (Max 3 min)

Ce document contient le script de voix-off, le déroulé visuel seconde par seconde, et un guide étape par étape pour réaliser votre vidéo de présentation sur **Canva**.

---

## Guide de Réalisation sur Canva

Pour obtenir un rendu professionnel et "motion design" sans outil complexe, suivez ces étapes dans **Canva** :

1.  **Créer le Projet** : Allez sur Canva et recherchez **"Vidéo Mobile"** (format vertical 1080x1920, idéal pour une application mobile) ou **"Vidéo (16:9)"** si vous préférez un format de présentation classique.
2.  **Choisir un Modèle** : Sélectionnez un style minimaliste et épuré avec des couleurs en accord avec le projet (Vert Sarcelle, Blanc, Gris Clair).
3.  **Ajouter un "Cadre Téléphone"** : Dans l'onglet *Éléments*, recherchez "Cadre de téléphone" (Phone mockup) et insérez-le au centre.
4.  **Enregistrer l'Écran** : Lancez votre application sur émulateur ou sur votre téléphone physique. Enregistrez votre écran en réalisant les actions du script ci-dessous (durée totale : ~2 min 30 s).
5.  **Importer et Placer le Rendu** : Importez votre enregistrement d'écran dans Canva et glissez-le directement dans le *Cadre Téléphone*. La vidéo s'adaptera automatiquement à la forme de l'appareil.
6.  **Ajouter des Textes et Transitions** :
    *   Utilisez des animations de texte douces (comme "Apparition" ou "Balayage").
    *   Insérez de courtes transitions (comme "Fondu au noir" ou "Glissement") entre chaque scène.
7.  **Enregistrer la Voix-off** : Cliquez sur *Partager* -> *Présenter et enregistrer* ou utilisez l'outil d'enregistrement audio de Canva pour lire le texte ci-dessous de manière calme et posée.

---

## Déroulé du Script (Chronologie de 2 min 40 s)

### Scène 1 : Introduction et Concept (0:00 - 0:25)
*   **Visuel** : Écran d'accueil Canva avec le titre "E-HealthCard", le sous-titre "Projet de Fin de Module - Sujet 5" et le nom du présentateur. Transition vers l'application dans son cadre de téléphone.
*   **Texte à l'écran** : *E-HealthCard : Le Carnet de Santé Numérique Sécurisé*
*   **Voix-off (Script)** :
    > "Bonjour à tous. Je vais vous présenter E-HealthCard, une application mobile de carnet de santé numérique et de fiche de secours développée sous Flutter. Conçue selon une approche 'Offline-First', elle permet de centraliser et de sécuriser les données médicales d'un patient, même dans les zones isolées ou sans aucune connexion réseau."

---

### Scène 2 : Tableau de bord et Profil Médical (0:25 - 0:55)
*   **Visuel** : Défilement de la page d'accueil (Dashboard) connectée. Clic sur l'onglet **Profil** pour montrer la fiche d'identité de Makhtar Wade, son groupe sanguin O+, sa commune (Touba) et son contact d'urgence (Ibrahima Wade).
*   **Texte à l'écran** : *Profil Médical & Données Vitales*
*   **Voix-off (Script)** :
    > "Voici le tableau de bord de notre patient démo, Makhtar Wade. Le design applique des principes de Material 3 et de Glassmorphism pour un rendu visuel premium. Dans l'espace Profil, l'utilisateur renseigne ses informations critiques : son groupe sanguin, ses allergies, ses antécédents médicaux ainsi que son contact d'urgence, dit contact ICE."

---

### Scène 3 : Saisie des Constantes & Graphique Dynamique (0:55 - 1:25)
*   **Visuel** : Retour à l'accueil. Clic sur "Ajouter une mesure". Saisie d'un nouveau poids (ex: 79 kg), d'une tension et d'une glycémie. Validation du formulaire. Le graphique (VitalChart) se met à jour immédiatement avec la nouvelle courbe.
*   **Texte à l'écran** : *Suivi des Constantes & Graphiques en temps réel*
*   **Voix-off (Script)** :
    > "L'application permet un suivi précis des constantes. L'utilisateur saisit ses mesures via un formulaire validé. Aussitôt enregistrées, les données de poids sont tracées dynamiquement grâce à un composant graphique personnalisé (CustomPainter), permettant de visualiser la courbe d'évolution en un clin d'œil."

---

### Scène 4 : Traitements et Ordonnances Numériques (1:25 - 1:50)
*   **Visuel** : Clic sur l'onglet **Traitements**. Simulation du scan d'ordonnance (clic sur le bouton photo qui pré-remplit instantanément l'ordonnance de grippe). Affichage des rappels locaux configurés.
*   **Texte à l'écran** : *Ordonnances & Rappels de Prises*
*   **Voix-off (Script)** :
    > "Pour le suivi des traitements, E-HealthCard intègre un module de numérisation d'ordonnances. En simulant la prise de photo, l'application extrait et pré-remplit automatiquement la liste des médicaments prescrits et configure des rappels locaux pour ne manquer aucune prise."

---

### Scène 5 : Démonstration du Mode Hors-Ligne & Fiche Secours (1:50 - 2:25)
*   **Visuel** : Activation du bouton interrupteur "Mode réseau indisponible". L'indicateur en haut passe à "Hors ligne" en orange. Clic sur "Ouvrir la fiche secours". L'écran d'urgence rouge apparaît instantanément sans contrôle d'accès lourd.
*   **Texte à l'écran** : *Mode Hors-ligne & Fiche Urgence ICE*
*   **Voix-off (Script)** :
    > "Mettons maintenant l'application hors-ligne. Un indicateur visuel orange confirme la déconnexion. En situation d'urgence ou de zone blanche, la fiche secours reste immédiatement accessible. Les secouristes ont un accès instantané au groupe sanguin, aux allergies critiques et aux boutons d'appels directs vers le SAMU, les Sapeurs-Pompiers et la Police."

---

### Scène 6 : Stockage Chiffré, Journalisation & Conclusion (2:25 - 2:40)
*   **Visuel** : Ajout d'un symptôme (Fièvre, intensité 3/5) en mode déconnecté. Le compteur affiche "1 symptôme en local". Désactivation du mode hors-ligne : la synchronisation s'effectue automatiquement. Transition vers l'écran de fin.
*   **Texte à l'écran** : *Chiffrement Local XOR & Synchronisation automatique*
*   **Voix-off (Script)** :
    > "Toutes ces données locales sont chiffrées de bout en bout via un algorithme XOR et Base64. Les symptômes consignés hors-ligne sont horodatés localement et synchronisés automatiquement dès le retour de la connexion. E-HealthCard allie ainsi conformité médicale, haute disponibilité et sécurité. Merci pour votre attention."
