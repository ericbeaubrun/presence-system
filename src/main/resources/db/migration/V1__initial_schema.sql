-- =========================================================================
-- 1. NETTOYAGE (Sécurité pour Flyway au cas où)
-- =========================================================================
DROP TABLE IF EXISTS utilisateurs CASCADE;
DROP TABLE IF EXISTS assister CASCADE;
DROP TABLE IF EXISTS cours CASCADE;
DROP TABLE IF EXISTS lecteurs CASCADE;
DROP TABLE IF EXISTS enseigner CASCADE;
DROP TABLE IF EXISTS appartenir_groupe CASCADE;
DROP TABLE IF EXISTS etudiants CASCADE;
DROP TABLE IF EXISTS groupes CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS departements CASCADE;
DROP TABLE IF EXISTS enseignants CASCADE;
DROP TABLE IF EXISTS salles CASCADE;
DROP TABLE IF EXISTS personnes CASCADE;

DROP TYPE IF EXISTS genre CASCADE;
DROP TYPE IF EXISTS etat_etudiant CASCADE;
DROP TYPE IF EXISTS etat_carte CASCADE;
DROP TYPE IF EXISTS type_salle CASCADE;
DROP TYPE IF EXISTS etat_lecteur CASCADE;
DROP TYPE IF EXISTS etat_salle CASCADE;
DROP TYPE IF EXISTS status_assister CASCADE;

-- =========================================================================
-- 2. CRÉATION DES TYPES ENUM
-- =========================================================================
CREATE TYPE genre AS ENUM ('homme', 'femme', 'non binaire');
CREATE TYPE etat_etudiant AS ENUM ('inscrit', 'non inscrit');
CREATE TYPE etat_carte AS ENUM ('valide', 'perdu', 'banni');
CREATE TYPE type_salle AS ENUM ('amphitheatre', 'reunion', 'bureau', 'td', 'tp', 'reseau');
CREATE TYPE etat_lecteur AS ENUM ('fonctionel', 'en panne', 'en reparation');
CREATE TYPE etat_salle AS ENUM ('normal', 'indisponible', 'en travaux');
CREATE TYPE status_assister AS ENUM ('present', 'absent justifie');

-- =========================================================================
-- 3. CRÉATION DES TABLES STRUCTURELLES DE BASE
-- =========================================================================
CREATE TABLE personnes
(
    id_personne    CHAR(9) PRIMARY KEY,
    nom            VARCHAR(50) NOT NULL,
    prenom         VARCHAR(50) NOT NULL,
    date_naissance DATE,
    mail           VARCHAR(100),
    num_tel        VARCHAR(15),
    sexe           genre
);

CREATE TABLE departements
(
    id_dep  CHAR(9) PRIMARY KEY,
    nom_dep VARCHAR(50) NOT NULL
);

CREATE TABLE classes
(
    id_classe  CHAR(9) PRIMARY KEY,
    nom_classe VARCHAR(50) NOT NULL,
    fk_dep     CHAR(9) REFERENCES departements (id_dep)
);

CREATE TABLE groupes
(
    id_groupe CHAR(9) PRIMARY KEY,
    nom       VARCHAR(50) NOT NULL,
    fk_classe CHAR(9) REFERENCES classes (id_classe)
);

CREATE TABLE salles
(
    id_salle   CHAR(9) PRIMARY KEY,
    nom_salle  VARCHAR(50) NOT NULL,
    cap_salle  INT,
    type       type_salle,
    etat_salle etat_salle
);

-- =========================================================================
-- 4. CRÉATION DES ROLES (Enseignants, Étudiants, Utilisateurs)
-- =========================================================================
CREATE TABLE enseignants
(
    id_enseignant CHAR(9) PRIMARY KEY,
    fk_dep        CHAR(9) REFERENCES departements (id_dep),
    CONSTRAINT fk_enseignant_personne FOREIGN KEY (id_enseignant) REFERENCES personnes (id_personne)
);

CREATE TABLE etudiants
(
    id_etudiant CHAR(9) PRIMARY KEY,
    fk_carte    CHAR(8) UNIQUE NOT NULL,
    fk_classe   CHAR(9) REFERENCES classes (id_classe),
    CONSTRAINT fk_etudiant_personne FOREIGN KEY (id_etudiant) REFERENCES personnes (id_personne)
);

CREATE TABLE utilisateurs
(
    id_user      CHAR(9) PRIMARY KEY,
    identifiant  VARCHAR(50) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255)       NOT NULL,
    role         VARCHAR(20)        NOT NULL,
    CONSTRAINT fk_utilisateur_personne FOREIGN KEY (id_user) REFERENCES personnes (id_personne)
);

-- =========================================================================
-- 5. MATÉRIEL IOT & SYSTÈME DE POINTAGE
-- =========================================================================
CREATE TABLE lecteurs
(
    id_lecteur   CHAR(5) PRIMARY KEY,
    etat_lecteur etat_lecteur,
    fk_salle     CHAR(9) REFERENCES salles (id_salle)
);

CREATE TABLE cours
(
    id_cours    CHAR(9) PRIMARY KEY,
    date_cours  DATE NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin   TIME NOT NULL,
    fk_salle    CHAR(9) REFERENCES salles (id_salle)
);

-- =========================================================================
-- 6. TABLES D'ASSOCIATIONS (Relations Many-To-Many)
-- =========================================================================
CREATE TABLE appartenir_groupe
(
    fk_etudiant CHAR(9) REFERENCES etudiants (id_etudiant),
    fk_groupe   CHAR(9) REFERENCES groupes (id_groupe),
    PRIMARY KEY (fk_etudiant, fk_groupe)
);

CREATE TABLE enseigner
(
    fk_enseignant CHAR(9) REFERENCES enseignants (id_enseignant),
    fk_cours      CHAR(9) REFERENCES cours (id_cours),
    PRIMARY KEY (fk_enseignant, fk_cours)
);

CREATE TABLE assister
(
    fk_etudiant     CHAR(9) REFERENCES etudiants (id_etudiant),
    fk_cours        CHAR(9) REFERENCES cours (id_cours),
    status_etudiant status_assister NOT NULL,
    justificatif    VARCHAR(255),
    heure_arrive    TIME,
    PRIMARY KEY (fk_etudiant, fk_cours)
);

-- =========================================================================
-- 7. JEU DE DONNÉES DE TEST (DATA SEEDING)
-- =========================================================================

-- Données Département, Classe, Groupe
INSERT INTO departements
VALUES ('D0001', 'Informatique');
INSERT INTO classes
VALUES ('C0001', 'Licence 3 Informatique', 'D0001');
INSERT INTO groupes
VALUES ('G0001', 'Groupe A', 'C0001');

-- Données Salles & Lecteurs IoT
INSERT INTO salles
VALUES ('S0001', 'Salle Reseau 101', 30, 'reseau', 'normal');
INSERT INTO lecteurs
VALUES ('L0001', 'fonctionel', 'S0001');

-- Données Personnes & Étudiants (Jean Dupont)
INSERT INTO personnes
VALUES ('2202100b', 'Dupont', 'Jean', '2002-01-01', 'jean.dupont@test.fr', '0600000000', 'homme');
INSERT INTO etudiants
VALUES ('2202100b', '2202100b', 'C0001');
INSERT INTO appartenir_groupe
VALUES ('2202100b', 'G0001');

INSERT INTO personnes
VALUES ('E00000001', 'Martin', 'Marc', '1975-05-12', 'marc.martin@univ.fr', '0611223344', 'homme');

INSERT INTO enseignants
VALUES ('E00000001', 'D0001');

INSERT INTO cours
VALUES ('C00002', CURRENT_DATE, '08:00:00', '12:00:00', 'S0001');
INSERT INTO enseigner
VALUES ('E00000001', 'C00002');

INSERT INTO assister
VALUES ('2202100b', 'C00002', 'present', NULL, '09:00:00');

INSERT INTO personnes (id_personne, nom, prenom, date_naissance, mail, num_tel, sexe)
VALUES ('ADM000001', 'Admin', 'Système', NULL, 'admin@presence-sys.fr', NULL,
        NULL) ON CONFLICT (id_personne) DO NOTHING;

INSERT INTO utilisateurs (id_user, identifiant, mot_de_passe, role)
VALUES ('ADM000001',
        'admin',
        'password_hash',
        'ADMIN') ON CONFLICT (id_user) DO NOTHING;