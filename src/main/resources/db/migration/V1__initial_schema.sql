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


-- =========================================================================
-- 8. EXTENSION MAJEURE DU JEU DE DONNÉES (DATA SEEDING CONVENABLE)
-- =========================================================================

-- ---------------------------------------------------------
-- AJOUT DE 14 NOUVELLES PERSONNES (Étudiants + Enseignants)
-- ---------------------------------------------------------
INSERT INTO personnes (id_personne, nom, prenom, date_naissance, mail, num_tel, sexe)
VALUES ('22021001', 'Durand', 'Lucas', '2002-03-14', 'lucas.durand@test.fr', '0601020304', 'homme'),
       ('22021002', 'Martin', 'Emma', '2002-07-22', 'emma.martin@test.fr', '0611223344', 'femme'),
       ('22021003', 'Bernard', 'Mathieu', '2001-11-05', 'mathieu.bernard@test.fr', '0622334455', 'homme'),
       ('22021004', 'Dubois', 'Chloé', '2002-05-19', 'chloe.dubois@test.fr', '0633445566', 'femme'),
       ('22021005', 'Thomas', 'Hugo', '2002-01-30', 'hugo.thomas@test.fr', '0644556677', 'homme'),
       ('22021006', 'Robert', 'Julie', '2002-09-12', 'julie.robert@test.fr', '0655667788', 'femme'),
       ('22021007', 'Richard', 'Antoine', '2001-04-25', 'antoine.richard@test.fr', '0666778899', 'homme'),
       ('22021008', 'Petit', 'Sarah', '2002-12-08', 'sarah.petit@test.fr', '0677889900', 'femme'),
       ('22021009', 'Moreau', 'Clara', '2002-10-15', 'clara.moreau@test.fr', '0688990011', 'femme'),
       ('22021010', 'Garcia', 'David', '2001-08-03', 'david.garcia@test.fr', '0699001122', 'homme'),
       ('22021011', 'Boucher', 'Manon', '2002-02-17', 'manon.boucher@test.fr', '0612345678', 'femme'),
       ('22021012', 'Roux', 'Thomas', '2002-06-21', 'thomas.roux@test.fr', '0623456789', 'homme'),
       ('E00000002', 'Lefebvre', 'Sophie', '1980-03-14', 'sophie.lefebvre@univ.fr', '0671727374', 'femme'),
       ('E00000003', 'Rousseau', 'Pierre', '1978-10-22', 'pierre.rousseau@univ.fr', '0681828384', 'homme');

-- ---------------------------------------------------------
-- ASSIGNATION DES ROLES ETUDIANTS ET ENSEIGNANTS
-- ---------------------------------------------------------
INSERT INTO etudiants (id_etudiant, fk_carte, fk_classe)
VALUES ('22021001', '22021001', 'C0001'),
       ('22021002', '22021002', 'C0001'),
       ('22021003', '22021003', 'C0001'),
       ('22021004', '22021004', 'C0001'),
       ('22021005', '22021005', 'C0001'),
       ('22021006', '22021006', 'C0001'),
       ('22021007', '22021007', 'C0001'),
       ('22021008', '22021008', 'C0001'),
       ('22021009', '22021009', 'C0001'),
       ('22021010', '22021010', 'C0001'),
       ('22021011', '22021011', 'C0001'),
       ('22021012', '22021012', 'C0001');

INSERT INTO enseignants (id_enseignant, fk_dep)
VALUES ('E00000002', 'D0001'),
       ('E00000003', 'D0001');

-- Liaison au Groupe A
INSERT INTO appartenir_groupe (fk_etudiant, fk_groupe)
VALUES ('22021001', 'G0001'),
       ('22021002', 'G0001'),
       ('22021003', 'G0001'),
       ('22021004', 'G0001'),
       ('22021005', 'G0001'),
       ('22021006', 'G0001'),
       ('22021007', 'G0001'),
       ('22021008', 'G0001'),
       ('22021009', 'G0001'),
       ('22021010', 'G0001'),
       ('22021011', 'G0001'),
       ('22021012', 'G0001');

-- ---------------------------------------------------------
-- CREATION DE COURS SUR PLUSIEURS SEMAINES (Historique)
-- ---------------------------------------------------------
INSERT INTO cours (id_cours, date_cours, heure_debut, heure_fin, fk_salle)
VALUES
-- Semaine du 08 Juin 2026
('C00010', '2026-06-08', '08:00:00', '12:00:00', 'S0001'),
('C00011', '2026-06-08', '14:00:00', '18:00:00', 'S0001'),
('C00012', '2026-06-09', '09:00:00', '12:00:00', 'S0001'),
('C00013', '2026-06-10', '08:00:00', '12:00:00', 'S0001'),
('C00014', '2026-06-11', '14:00:00', '18:00:00', 'S0001'),
-- Semaine du 15 Juin 2026
('C00015', '2026-06-15', '08:00:00', '12:00:00', 'S0001'),
('C00016', '2026-06-15', '14:00:00', '18:00:00', 'S0001'),
('C00017', '2026-06-16', '09:00:00', '12:00:00', 'S0001'),
('C00018', '2026-06-17', '08:00:00', '12:00:00', 'S0001'),
('C00019', '2026-06-18', '14:00:00', '18:00:00', 'S0001'),
-- Semaine du 22 Juin 2026
('C00020', '2026-06-22', '08:00:00', '12:00:00', 'S0001'),
('C00021', '2026-06-22', '14:00:00', '18:00:00', 'S0001'),
('C00022', '2026-06-23', '09:00:00', '12:00:00', 'S0001'),
('C00023', '2026-06-24', '08:00:00', '12:00:00', 'S0001'),
('C00024', '2026-06-25', '14:00:00', '18:00:00', 'S0001'),
-- Semaine du 29 Juin 2026 (Semaine Récente)
('C00025', '2026-06-29', '08:00:00', '12:00:00', 'S0001'),
('C00026', '2026-06-29', '14:00:00', '18:00:00', 'S0001'),
('C00027', '2026-06-30', '09:00:00', '12:00:00', 'S0001'),
('C00028', '2026-07-01', '08:00:00', '12:00:00', 'S0001'),
('C00029', '2026-07-02', '14:00:00', '18:00:00', 'S0001');

-- Liaison Enseignants aux Cours
INSERT INTO enseigner (fk_enseignant, fk_cours)
VALUES ('E00000001', 'C00010'),
       ('E00000002', 'C00011'),
       ('E00000003', 'C00012'),
       ('E00000001', 'C00013'),
       ('E00000002', 'C00014'),
       ('E00000001', 'C00015'),
       ('E00000002', 'C00016'),
       ('E00000003', 'C00017'),
       ('E00000001', 'C00018'),
       ('E00000002', 'C00019'),
       ('E00000001', 'C00020'),
       ('E00000002', 'C00021'),
       ('E00000003', 'C00022'),
       ('E00000001', 'C00023'),
       ('E00000002', 'C00024'),
       ('E00000001', 'C00025'),
       ('E00000002', 'C00026'),
       ('E00000003', 'C00027'),
       ('E00000001', 'C00028'),
       ('E00000002', 'C00029');


-- ---------------------------------------------------------
-- POINTAGES MASSIFS ET REALISTES (Table assister)
-- ---------------------------------------------------------

-- Cours C00010 (Grand soleil, tout le monde est là ou presque)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00010', 'present', NULL, '07:54:12'),
       ('22021001', 'C00010', 'present', NULL, '07:58:33'),
       ('22021002', 'C00010', 'present', NULL, '08:02:10'), -- Léger Retard
       ('22021003', 'C00010', 'present', NULL, '07:45:00'),
       ('22021004', 'C00010', 'present', NULL, '07:59:01'),
       ('22021005', 'C00010', 'absent justifie', 'Rendez-vous médical', NULL),
       ('22021006', 'C00010', 'present', NULL, '07:51:22'),
       ('22021007', 'C00010', 'present', NULL, '08:15:44'), -- Retard prononcé
       ('22021008', 'C00010', 'present', NULL, '07:56:00'),
       ('22021009', 'C00010', 'present', NULL, '07:55:12'),
       ('22021010', 'C00010', 'present', NULL, '07:58:00'),
       ('22021011', 'C00010', 'present', NULL, '08:00:22'),
       ('22021012', 'C00010', 'present', NULL, '07:49:59');

-- Cours C00011 (Lundi Après-midi)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00011', 'present', NULL, '13:45:00'),
       ('22021001', 'C00011', 'present', NULL, '13:58:00'),
       ('22021002', 'C00011', 'present', NULL, '13:59:00'),
       ('22021003', 'C00011', 'present', NULL, '14:05:12'),
       ('22021004', 'C00011', 'present', NULL, '13:52:00'),
       ('22021005', 'C00011', 'absent justifie', 'Rendez-vous médical', NULL),
       ('22021006', 'C00011', 'present', NULL, '13:50:30'),
       ('22021007', 'C00011', 'present', NULL, '13:55:00'),
       ('22021008', 'C00011', 'present', NULL, '13:57:15'),
       ('22021009', 'C00011', 'present', NULL, '14:22:00'), -- Retard
       ('22021010', 'C00011', 'present', NULL, '13:51:00'),
       ('22021011', 'C00011', 'present', NULL, '13:58:45'),
       ('22021012', 'C00011', 'present', NULL, '13:53:10');

-- Cours C00012 (Mardi Matin)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00012', 'present', NULL, '08:55:00'),
       ('22021001', 'C00012', 'present', NULL, '08:45:00'),
       ('22021002', 'C00012', 'present', NULL, '08:58:22'),
       ('22021003', 'C00012', 'present', NULL, '08:59:00'),
       ('22021004', 'C00012', 'present', NULL, '08:50:11'),
       ('22021005', 'C00012', 'present', NULL, '08:56:40'), -- De retour
       ('22021006', 'C00012', 'present', NULL, '08:44:00'),
       ('22021007', 'C00012', 'present', NULL, '09:01:15'),
       ('22021008', 'C00012', 'present', NULL, '08:57:30'),
       ('22021009', 'C00012', 'present', NULL, '08:53:00'),
       ('22021010', 'C00012', 'absent justifie', 'Grève des transports', NULL),
       ('22021011', 'C00012', 'present', NULL, '08:52:00'),
       ('22021012', 'C00012', 'present', NULL, '08:58:10');

-- Cours C00013 (Mercredi Matin)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00013', 'present', NULL, '07:45:00'),
       ('22021001', 'C00013', 'present', NULL, '07:55:00'),
       ('22021002', 'C00013', 'present', NULL, '07:56:00'),
       ('22021003', 'C00013', 'present', NULL, '07:58:00'),
       ('22021004', 'C00013', 'present', NULL, '08:12:00'),
       ('22021005', 'C00013', 'present', NULL, '07:50:00'),
       ('22021006', 'C00013', 'present', NULL, '07:52:00'),
       ('22021007', 'C00013', 'present', NULL, '07:54:00'),
       ('22021008', 'C00013', 'present', NULL, '07:53:00'),
       ('22021009', 'C00013', 'present', NULL, '07:55:00'),
       ('22021010', 'C00013', 'present', NULL, '07:48:00'),
       ('22021011', 'C00013', 'present', NULL, '07:59:00'),
       ('22021012', 'C00013', 'present', NULL, '07:51:00');

-- Cours C00015 (Semaine suivante - Lundi Matin difficile)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00015', 'present', NULL, '08:04:12'),
       ('22021001', 'C00015', 'present', NULL, '07:55:00'),
       ('22021002', 'C00015', 'present', NULL, '08:12:30'),
       ('22021003', 'C00015', 'present', NULL, '07:59:00'),
       ('22021004', 'C00015', 'absent justifie', 'Permis de conduire', NULL),
       ('22021005', 'C00015', 'present', NULL, '07:51:00'),
       ('22021006', 'C00015', 'present', NULL, '08:00:05'),
       ('22021007', 'C00015', 'present', NULL, '08:32:00'), -- Gros retard
       ('22021008', 'C00015', 'present', NULL, '07:45:00'),
       ('22021009', 'C00015', 'present', NULL, '07:56:12'),
       ('22021010', 'C00015', 'present', NULL, '07:58:00'),
       ('22021011', 'C00015', 'present', NULL, '08:02:11'),
       ('22021012', 'C00015', 'present', NULL, '07:50:00');

-- Cours C00020 (Semaine 3 - Journée pluvieuse)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00020', 'present', NULL, '07:58:00'),
       ('22021001', 'C00020', 'present', NULL, '07:59:15'),
       ('22021002', 'C00020', 'present', NULL, '08:05:00'),
       ('22021003', 'C00020', 'present', NULL, '07:44:00'),
       ('22021004', 'C00020', 'present', NULL, '07:52:12'),
       ('22021005', 'C00020', 'present', NULL, '07:56:00'),
       ('22021006', 'C00020', 'absent justifie', 'Maladie (Grippe)', NULL),
       ('22021007', 'C00020', 'absent justifie', 'Maladie (Grippe)', NULL),
       ('22021008', 'C00020', 'present', NULL, '07:51:00'),
       ('22021009', 'C00020', 'present', NULL, '07:53:30'),
       ('22021010', 'C00020', 'present', NULL, '08:14:00'),
       ('22021011', 'C00020', 'present', NULL, '07:57:00'),
       ('22021012', 'C00020', 'present', NULL, '07:48:00');

-- Cours C00021 (Après-midi du même jour)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00021', 'present', NULL, '13:55:00'),
       ('22021001', 'C00021', 'present', NULL, '13:58:00'),
       ('22021002', 'C00021', 'present', NULL, '13:54:10'),
       ('22021003', 'C00021', 'present', NULL, '13:42:00'),
       ('22021004', 'C00021', 'present', NULL, '13:51:00'),
       ('22021005', 'C00021', 'present', NULL, '13:59:59'),
       ('22021006', 'C00021', 'absent justifie', 'Maladie (Grippe)', NULL),
       ('22021007', 'C00021', 'absent justifie', 'Maladie (Grippe)', NULL),
       ('22021008', 'C00021', 'present', NULL, '13:48:00'),
       ('22021009', 'C00021', 'present', NULL, '13:52:00'),
       ('22021010', 'C00021', 'present', NULL, '13:56:00'),
       ('22021011', 'C00021', 'present', NULL, '14:03:00'),
       ('22021012', 'C00021', 'present', NULL, '13:50:00');

-- Cours C00025 (Fin Juin - Session Récente Réussie)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00025', 'present', NULL, '07:52:11'),
       ('22021001', 'C00025', 'present', NULL, '07:56:00'),
       ('22021002', 'C00025', 'present', NULL, '07:58:44'),
       ('22021003', 'C00025', 'present', NULL, '07:51:00'),
       ('22021004', 'C00025', 'present', NULL, '07:54:30'),
       ('22021005', 'C00025', 'present', NULL, '07:53:00'),
       ('22021006', 'C00025', 'present', NULL, '07:55:00'), -- Rétablis
       ('22021007', 'C00025', 'present', NULL, '07:57:12'),
       ('22021008', 'C00025', 'present', NULL, '07:49:00'),
       ('22021009', 'C00025', 'present', NULL, '07:52:00'),
       ('22021010', 'C00025', 'present', NULL, '07:50:00'),
       ('22021011', 'C00025', 'present', NULL, '07:58:00'),
       ('22021012', 'C00025', 'present', NULL, '07:53:15');

-- Cours C00026 (Après-midi du 29 Juin)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00026', 'present', NULL, '13:58:00'),
       ('22021001', 'C00026', 'present', NULL, '13:52:00'),
       ('22021002', 'C00026', 'present', NULL, '13:59:12'),
       ('22021003', 'C00026', 'present', NULL, '13:46:00'),
       ('22021004', 'C00026', 'present', NULL, '13:53:00'),
       ('22021005', 'C00026', 'present', NULL, '13:55:40'),
       ('22021006', 'C00026', 'present', NULL, '13:51:10'),
       ('22021007', 'C00026', 'present', NULL, '14:02:15'),
       ('22021008', 'C00026', 'present', NULL, '13:44:00'),
       ('22021009', 'C00026', 'present', NULL, '13:50:00'),
       ('22021010', 'C00026', 'present', NULL, '13:56:22'),
       ('22021011', 'C00026', 'present', NULL, '13:58:00'),
       ('22021012', 'C00026', 'present', NULL, '13:52:00');

-- Cours C00027 (Mardi 30 Juin)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00027', 'present', NULL, '08:52:00'),
       ('22021001', 'C00027', 'present', NULL, '08:56:00'),
       ('22021002', 'C00027', 'present', NULL, '08:59:00'),
       ('22021003', 'C00027', 'present', NULL, '08:42:12'),
       ('22021004', 'C00027', 'present', NULL, '08:54:00'),
       ('22021005', 'C00027', 'present', NULL, '08:55:00'),
       ('22021006', 'C00027', 'present', NULL, '08:51:00'),
       ('22021007', 'C00027', 'present', NULL, '08:53:30'),
       ('22021008', 'C00027', 'present', NULL, '08:44:00'),
       ('22021009', 'C00027', 'present', NULL, '08:50:00'),
       ('22021010', 'C00027', 'present', NULL, '08:57:00'),
       ('22021011', 'C00027', 'absent justifie', 'Convocation administrative', NULL),
       ('22021012', 'C00027', 'present', NULL, '08:52:45');

-- Cours C00028 (Mercredi 01 Juillet)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00028', 'present', NULL, '07:54:00'),
       ('22021001', 'C00028', 'present', NULL, '07:56:00'),
       ('22021002', 'C00028', 'present', NULL, '07:59:00'),
       ('22021003', 'C00028', 'present', NULL, '07:41:00'),
       ('22021004', 'C00028', 'present', NULL, '07:55:00'),
       ('22021005', 'C00028', 'present', NULL, '07:53:20'),
       ('22021006', 'C00028', 'present', NULL, '07:51:00'),
       ('22021007', 'C00028', 'present', NULL, '07:53:00'),
       ('22021008', 'C00028', 'present', NULL, '07:44:00'),
       ('22021009', 'C00028', 'present', NULL, '07:50:00'),
       ('22021010', 'C00028', 'present', NULL, '08:08:12'), -- En retard
       ('22021011', 'C00028', 'present', NULL, '07:57:00'),
       ('22021012', 'C00028', 'present', NULL, '07:52:00');

-- Cours C00029 (Jeudi 02 Juillet)
INSERT INTO assister (fk_etudiant, fk_cours, status_etudiant, justificatif, heure_arrive)
VALUES ('2202100b', 'C00029', 'present', NULL, '13:58:00'),
       ('22021001', 'C00029', 'present', NULL, '13:51:00'),
       ('22021002', 'C00029', 'present', NULL, '13:59:00'),
       ('22021003', 'C00029', 'present', NULL, '13:46:11'),
       ('22021004', 'C00029', 'present', NULL, '13:53:00'),
       ('22021005', 'C00029', 'present', NULL, '13:55:00'),
       ('22021006', 'C00029', 'present', NULL, '13:51:00'),
       ('22021007', 'C00029', 'present', NULL, '13:56:45'),
       ('22021008', 'C00029', 'present', NULL, '13:44:00'),
       ('22021009', 'C00029', 'present', NULL, '13:50:00'),
       ('22021010', 'C00029', 'present', NULL, '13:54:00'),
       ('22021011', 'C00029', 'present', NULL, '13:58:00'),
       ('22021012', 'C00029', 'present', NULL, '13:52:10');


-- Pour les tests Utilisateur = admin Mot de passe = admin :
INSERT INTO utilisateurs (id_user, identifiant, mot_de_passe, role)
VALUES ('ADM000001',
        'admin',
        '$2y$10$gF8FS8hwjtMjS5jf7hiUPOki0RXRGvj2xydkNfEjkV0qGocjy/GPC',
        'ADMIN') ON CONFLICT (id_user) DO NOTHING;



