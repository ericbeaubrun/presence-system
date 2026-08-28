# Système de gestion et de vérification des présences

📖 **[Documentation de l'API](https://ericbeaubrun.github.io/presence-system/)** — hébergée sur GitHub Pages, sources dans [`docs/`](docs/).

## Vue d'ensemble

Le système de gestion et de vérification des présences est une solution complète permettant de gérer la présence d'étudiants ou d'employés à l'aide de cartes à puce NFC. Ce projet a été développé dans le cadre du cours de Bases de données et Réseaux, en dernière année de Licence Informatique à CY Cergy Paris Université. Le système associe un backend Spring Boot sécurisé, une interface web d'administration et un client Python léger connecté à un lecteur NFC ACR122U.

---

## Architecture du système

L'application se compose de trois éléments principaux :

### 1. Serveur backend

Développé en **Java 21** avec **Spring Boot 4.1.0**, suivant une **architecture hexagonale** simplifiée.

Ses responsabilités sont les suivantes :

* Traiter les horodatages de présence
* Recouper les emplois du temps des salles
* Empêcher les pointages en double
* Exposer des API REST sécurisées
* Protéger les endpoints d'administration avec **Spring Security** et l'**authentification HTTP Basic**

## Schéma de la base de données

Le modèle de données est conçu pour gérer efficacement les relations entre les utilisateurs, les cartes NFC qui leur sont attribuées, les séances planifiées et les enregistrements de présence.

![Schéma de la base de données](https://github.com/user-attachments/assets/77ee136e-0f10-4b2b-a648-35ff21574795)

Les entités principales sont :
* **Users** : stocke les informations de profil de chaque personne.
* **Cards** : gère la correspondance entre les UID NFC uniques et les utilisateurs.
* **Sessions** : définit le planning (créneaux horaires et lieux) du suivi de présence.
* **Attendances** : enregistre les pointages effectifs, en reliant utilisateurs, cartes et séances afin d'assurer la vérification et d'éviter les doublons.


### 2. Interface web d'administration

Un tableau de bord web qui communique de manière asynchrone avec l'API REST du backend.

Fonctionnalités :

* Créer des enregistrements de présence
* Consulter l'historique des présences
* Mettre à jour des enregistrements
* Supprimer des enregistrements
* Gestion manuelle des présences par les administrateurs

### 3. Client matériel

Une application **Python** légère qui s'exécute sur un terminal connecté à un **lecteur NFC ACR122U**.

Responsabilités :

* Lire les UID des cartes NFC
* Construire les charges utiles JSON
* Envoyer les événements de présence au serveur backend

---

# Stack technique

## Backend

| Catégorie                    | Technologie             |
| ---------------------------- | ----------------------- |
| Langage                      | Java 21                 |
| Framework                    | Spring Boot 4.1.0       |
| Architecture                 | Architecture hexagonale |
| Sécurité                     | Spring Security         |
| Base de données              | PostgreSQL              |
| ORM                          | Spring Data JPA         |
| Migration                    | Flyway                  |
| Validation                   | Jakarta Validation      |
| Réduction du code répétitif  | Lombok                  |
| Outil de build               | Gradle                  |

### Dépendances Gradle

* `spring-boot-starter-webmvc`
* `spring-boot-starter-security`
* `spring-boot-starter-data-jpa`
* `postgresql`
* `spring-boot-starter-flyway`
* `flyway-database-postgresql`
* `spring-boot-starter-validation`
* `springdoc-openapi-starter-webmvc-ui`
* `lombok`

### Documentation de l'API

La spécification OpenAPI est dérivée des annotations des contrôleurs par `springdoc`. Lorsque
l'application est en cours d'exécution :

* Spécification : **http://localhost:8080/v3/api-docs.yaml**
* Swagger UI : **http://localhost:8080/swagger-ui.html**

Le site publié dans [`docs/`](docs/) est servi par GitHub Pages. Son fichier `openapi.yaml` est
regénéré et commité automatiquement par
[`.github/workflows/api-docs.yml`](.github/workflows/api-docs.yml) à chaque push touchant le
backend — ne le modifiez pas à la main.

---

## Client matériel

### Environnement d'exécution

* Python 3.x

### Bibliothèques

* `pyscard`
* `requests`

---

# Suite de tests

Tous les utilitaires de test se trouvent dans :

```text
src/tests/
```

## admin_test.html

Interface de test exécutée dans le navigateur, utilisée pour :

* Vérifier la configuration CORS
* Tester les endpoints REST sécurisés
* Exécuter des opérations CRUD via l'API Fetch

---

## nfc_reader_client_test.py

Test d'intégration matérielle qui :

* Lit les cartes NFC à l'aide du lecteur ACR122U
* Récupère l'UID de la carte
* Envoie la charge utile JSON générée au serveur backend

---

## postman_test.json

Collection Postman utilisée pour tester l'API.

Réponses attendues :

| Scénario                        | Statut attendu  |
| ------------------------------- | --------------- |
| Badgeage valide                 | 200 OK          |
| Badgeage en double              | 400 Bad Request |
| Badge inconnu                   | 400 Bad Request |
| Aucun cours au planning         | 400 Bad Request |

---

# Installation

## 1. Compiler le projet

Générer le JAR exécutable :

```bash
./gradlew clean bootJar
```

---

## 2. Démarrer les services Docker

Construire et lancer la stack applicative :

```bash
docker compose up -d --build
```

Services par défaut :

* API backend : **http://localhost:8080**
* PostgreSQL : **localhost:1234**

---

## 3. Tester le client matériel NFC

Installer les paquets Python nécessaires :

```bash
pip install requests pyscard
```

Lancer le script de test :

```bash
python src/tests/nfc_reader_client_test.py
```

---

## 4. Exécuter les tests de l'interface d'administration

Démarrer un serveur HTTP local :

```bash
python -m http.server 3000
```

Puis ouvrir le navigateur à l'adresse :

```
http://localhost:3000/src/tests/admin_test.html
```

---

# Prérequis

* Java 21
* Gradle
* Docker & Docker Compose
* Python 3.x
* PostgreSQL
* Lecteur NFC ACR122U
