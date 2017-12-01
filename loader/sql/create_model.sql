

--
-- Modelo de datos para el datamart de prestaciones
--


-- --------------------------------------------------------
-- 
-- Tablas de staging stg_*
-- 
-- Esas tablas se cargan de forma temporal para subir los 
-- datos a la BBDD. Luego el tratamiento se realiza dentro
-- de la base de datos.
-- 
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `stg_descripteur` (
  `T_DESCRIPTEUR_ID` int(6) NULL,
  `LibelleDescripteur` varchar(255) NULL,
  `SautDescripteur` varchar(255) NULL,
  `Valeur` varchar(25) NULL,
  `CodeDescripteur` varchar(50) NULL,
  `RangDescripteur` float NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `description` text NULL,
  `isSession` tinyint(1) NULL,
  `saisissable` tinyint(1) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  INDEX stg_descripteur_ld (`load_date`)
);

CREATE TABLE IF NOT EXISTS `stg_modalite` (
  `T_MODALITE_ID` int(11) NULL,
  `LibelleModalite` varchar(150) NULL,
  `TypeModalite` varchar(25) NULL,
  `CodeModalite` varchar(20) NULL,
  `RangModalite` int(11) NULL,
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `visible` tinyint(1) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  INDEX stg_modalite_ld (`load_date`)
);

CREATE TABLE IF NOT EXISTS `stg_observation` (
  `T_OBSERVATION_ID` int(11) NULL,
  `CodeObservation` varchar(50) NULL,
  `ObservationPublic` varchar(10) NULL,
  `ObservationValide` varchar(10) NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `verouiller` binary(1),
  `created` datetime NULL,
  `id_enqu` int(11) NULL,
  `suivi` mediumtext NULL,
  `accem` int(1) NULL,
  `export` int(11) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  INDEX stg_observation_ld (`load_date`)
);

CREATE TABLE IF NOT EXISTS `stg_obs_descript` (
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Valeur` longtext,
  `created` datetime NULL,
  `id_enqu` text NULL,
  `suivi` mediumtext NULL,
  `session` int(11) NULL,
  `Fecha_Modificacion` timestamp NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  INDEX stg_obs_descript_ld (`load_date`)
);

CREATE TABLE IF NOT EXISTS `stg_obs_mod` (
  `id_obs_mod` int(11) NULL,
  `date_debut` datetime NULL,
  `date_fin` datetime NULL,
  `T_MODALITE_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Reponse` tinyint(4) NULL,
  `id_enq` int(4) NULL,
  `session` int(11) NULL,
  `Fecha_Modificacion` timestamp NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  INDEX stg_obs_mod_ld (`load_date`)
);

CREATE TABLE IF NOT EXISTS `stg_personne` (
  `T_PERSONNE_ID` int(11) NULL,
  `Nom` varchar(50) NULL,
  `Prenom` varchar(50) NULL,
  `DateNaissance` date NULL,
  `Telephone` varchar(14) NULL,
  `Email` varchar(50) NULL,
  `Succursale` varchar(100) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

CREATE TABLE IF NOT EXISTS `stg_questionnaire` (
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `LibelleQuestionnaire` varchar(50) NULL,
  `CleModification` varchar(50) NULL,
  `CleSaisie` varchar(50) NULL,
  `CleSuppression` varchar(50) NULL,
  `CleValidation` varchar(50) NULL,
  `ClePublique` varchar(50) NULL,
  `CleVisualisation` varchar(50) NULL,
  `GID` varchar(50) NULL,
  `ValiditeReponse` varchar(10) NULL,
  `publicationReponse` varchar(10) NULL,
  `id_projet` int(11) NULL,
  `T_PAYS_ID` int(11) NULL,
  `CleExpert` varchar(50) NULL,
  `Suivi` char(1) NULL,
  `DescrGroupe` char(30) NULL,
  `DescrGroupe2` char(3) NULL,
  `DescrRech` char(2) NULL,
  `saisie` binary(1) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

CREATE TABLE IF NOT EXISTS `stg_compte` (
  `T_COMPTE_ID` int(20) NULL,
  `Login` varchar(50) NULL,
  `MotdePasse` varchar(20) NULL,
  `DateConnexion` date NULL, -- pb: el valor por defecto 0000-00-00 no es una fecha valida...
  `HeureConnexion` time NULL,
  `repertoire` varchar(255) NULL,
  `T_PERSONNE_ID` int(11) NULL,
  `langue` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

CREATE TABLE IF NOT EXISTS `stg_groupe` (
  `id_groupe` int(11) NULL,
  `nom_groupe` varchar(50) NULL,
  `code_groupe` char(5) NULL,
  `id_projet` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

CREATE TABLE IF NOT EXISTS `stg_lier_groupe` (
  `id_lier_groupe` int(11) NULL,
  `id_user` int(11) NULL,
  `id_groupe` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

CREATE TABLE IF NOT EXISTS `stg_liste_droits` (
  `id_liste_droits` int(11) NULL,
  `id_user` int(11) NULL,
  `Y_droit` varchar(30) NULL,
  `valeur_droit` longtext NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
) COMMENT='droits pour 1 utilisateur';

CREATE TABLE IF NOT EXISTS `stg_succursale_groupe` (
  `id_sg` int(11) NULL,
  `province` varchar(25) NULL,
  `succursale` varchar(25) NULL,
  `code` varchar(2) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);



-- --------------------------------------------------------
--
-- Tablas Operational Data Store ods_*
--
-- Esas tablas son un espejo del sistema e-gorrion.
-- Permiten validar que no se han perdido datos entre el 
-- sistema original y el espejo.
--
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ods_descripteur` (
  `T_DESCRIPTEUR_ID` int(6) NULL,
  `LibelleDescripteur` varchar(255) NULL,
  `SautDescripteur` varchar(255) NULL,
  `Valeur` varchar(25) NULL,
  `CodeDescripteur` varchar(50) NULL,
  `RangDescripteur` float NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `description` text NULL,
  `isSession` tinyint(1) NULL,
  `saisissable` tinyint(1) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_DESCRIPTEUR_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_modalite` (
  `T_MODALITE_ID` int(11) NULL,
  `LibelleModalite` varchar(150) NULL,
  `TypeModalite` varchar(25) NULL,
  `CodeModalite` varchar(20) NULL,
  `RangModalite` int(11) NULL,
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `visible` tinyint(1) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_MODALITE_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_observation` (
  `T_OBSERVATION_ID` int(11) NULL,
  `CodeObservation` varchar(50) NULL,
  `ObservationPublic` varchar(10) NULL,
  `ObservationValide` varchar(10) NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `verouiller` binary(1),
  `created` datetime NULL,
  `id_enqu` int(11) NULL,
  `suivi` mediumtext NULL,
  `accem` int(1) NULL,
  `export` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_OBSERVATION_ID`),
  INDEX observation_quest (`T_OBSERVATION_ID`,`T_QUESTIONNAIRE_ID`),
  INDEX observation_dd(`data_date`)
);
-- CREATE INDEX ind_observation ON ods_observation (`T_OBSERVATION_ID`,`ObservationValide`,`T_QUESTIONNAIRE_ID`);

CREATE TABLE IF NOT EXISTS `ods_obs_descript` (
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Valeur` longtext,
  `created` datetime NULL,
  `id_enqu` text NULL,
  `suivi` mediumtext NULL,
  `session` int(11) NULL,
  `Fecha_Modificacion` timestamp NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_DESCRIPTEUR_ID`,`T_OBSERVATION_ID`,`session`),
  INDEX obs_descript_dd (`data_date`)
);
/*PARTITION BY RANGE(UNIX_TIMESTAMP(`Fecha_Modificacion`)) (
PARTITION start        VALUES LESS THAN (0),
PARTITION p2000        VALUES LESS THAN (unix_timestamp('2001-01-01 00:00:00')),
PARTITION p2001        VALUES LESS THAN (unix_timestamp('2002-01-01 00:00:00')),
PARTITION p2002        VALUES LESS THAN (unix_timestamp('2003-01-01 00:00:00')),
PARTITION p2003        VALUES LESS THAN (unix_timestamp('2004-01-01 00:00:00')),
PARTITION p2004        VALUES LESS THAN (unix_timestamp('2005-01-01 00:00:00')),
PARTITION p2005        VALUES LESS THAN (unix_timestamp('2006-01-01 00:00:00')),
PARTITION p2006        VALUES LESS THAN (unix_timestamp('2007-01-01 00:00:00')),
PARTITION p2007        VALUES LESS THAN (unix_timestamp('2008-01-01 00:00:00')),
PARTITION p2008        VALUES LESS THAN (unix_timestamp('2009-01-01 00:00:00')),
PARTITION p2009        VALUES LESS THAN (unix_timestamp('2010-01-01 00:00:00')),
PARTITION p2010        VALUES LESS THAN (unix_timestamp('2011-01-01 00:00:00')),
PARTITION p2011        VALUES LESS THAN (unix_timestamp('2012-01-01 00:00:00')),
PARTITION p2012        VALUES LESS THAN (unix_timestamp('2013-01-01 00:00:00')),
PARTITION p2013        VALUES LESS THAN (unix_timestamp('2014-01-01 00:00:00')),
PARTITION p2014        VALUES LESS THAN (unix_timestamp('2015-01-01 00:00:00')),
PARTITION p2015        VALUES LESS THAN (unix_timestamp('2016-01-01 00:00:00')),
PARTITION p2016        VALUES LESS THAN (unix_timestamp('2017-01-01 00:00:00')),
PARTITION future       VALUES LESS THAN MAXVALUE
);*/

CREATE TABLE IF NOT EXISTS `ods_obs_mod` (
  `id_obs_mod` int(11) NULL,
  `date_debut` datetime NULL,
  `date_fin` datetime NULL,
  `T_MODALITE_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Reponse` tinyint(4) NULL,
  `id_enq` int(4) NULL,
  `session` int(11) NULL,
  `Fecha_Modificacion` timestamp NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_obs_mod`),
  INDEX obs_mod_key (`T_OBSERVATION_ID`,`T_MODALITE_ID`,`session`,`date_debut`,`date_fin`,`id_enq`),
  INDEX obs_mod_observation (`T_OBSERVATION_ID`),
  INDEX obs_mod_modalite (`T_MODALITE_ID`),
  INDEX obs_mod_dd (`data_date`)
);
-- CREATE INDEX ind_prestaciones ON ods_obs_mod (`T_OBSERVATION_ID`,`T_MODALITE_ID`,`session`,`date_debut`,`date_fin`,`id_enq`) ;
/*PARTITION BY RANGE(`Fecha_Modificacion`) (
PARTITION start        VALUES LESS THAN (0),
PARTITION p2000        VALUES LESS THAN (unix_timestamp('2001-01-01')),
PARTITION p2001        VALUES LESS THAN (unix_timestamp('2002-01-01')),
PARTITION p2002        VALUES LESS THAN (unix_timestamp('2003-01-01')),
PARTITION p2003        VALUES LESS THAN (unix_timestamp('2004-01-01')),
PARTITION p2004        VALUES LESS THAN (unix_timestamp('2005-01-01')),
PARTITION p2005        VALUES LESS THAN (unix_timestamp('2006-01-01')),
PARTITION p2006        VALUES LESS THAN (unix_timestamp('2007-01-01')),
PARTITION p2007        VALUES LESS THAN (unix_timestamp('2008-01-01')),
PARTITION p2008        VALUES LESS THAN (unix_timestamp('2009-01-01')),
PARTITION p2009        VALUES LESS THAN (unix_timestamp('2010-01-01')),
PARTITION p2010        VALUES LESS THAN (unix_timestamp('2011-01-01')),
PARTITION p2011        VALUES LESS THAN (unix_timestamp('2012-01-01')),
PARTITION p2012        VALUES LESS THAN (unix_timestamp('2013-01-01')),
PARTITION p2013        VALUES LESS THAN (unix_timestamp('2014-01-01')),
PARTITION p2014        VALUES LESS THAN (unix_timestamp('2015-01-01')),
PARTITION p2015        VALUES LESS THAN (unix_timestamp('2016-01-01')),
PARTITION p2016        VALUES LESS THAN (unix_timestamp('2017-01-01')),
PARTITION future       VALUES LESS THAN MAXVALUE
);*/

CREATE TABLE IF NOT EXISTS `ods_personne` (
  `T_PERSONNE_ID` int(11) NULL,
  `Nom` varchar(50) NULL,
  `Prenom` varchar(50) NULL,
  `DateNaissance` date NULL,
  `Telephone` varchar(14) NULL,
  `Email` varchar(50) NULL,
  `Succursale` varchar(100) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_PERSONNE_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_questionnaire` (
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `LibelleQuestionnaire` varchar(50) NULL,
  `CleModification` varchar(50) NULL,
  `CleSaisie` varchar(50) NULL,
  `CleSuppression` varchar(50) NULL,
  `CleValidation` varchar(50) NULL,
  `ClePublique` varchar(50) NULL,
  `CleVisualisation` varchar(50) NULL,
  `GID` varchar(50) NULL,
  `ValiditeReponse` varchar(10) NULL,
  `publicationReponse` varchar(10) NULL,
  `id_projet` int(11) NULL,
  `T_PAYS_ID` int(11) NULL,
  `CleExpert` varchar(50) NULL,
  `Suivi` char(1) NULL,
  `DescrGroupe` char(30) NULL,
  `DescrGroupe2` char(3) NULL,
  `DescrRech` char(2) NULL,
  `saisie` binary(1) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_QUESTIONNAIRE_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_compte` (
  `T_COMPTE_ID` int(20) NULL,
  `Login` varchar(50) NULL,
  `MotdePasse` varchar(20) NULL,
  `DateConnexion` date NULL,
  `HeureConnexion` time NULL,
  `repertoire` varchar(255) NULL,
  `T_PERSONNE_ID` int(11) NULL,
  `langue` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_COMPTE_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_groupe` (
  `id_groupe` int(11) NULL,
  `nom_groupe` varchar(50) NULL,
  `code_groupe` char(5) NULL,
  `id_projet` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_groupe`)
);

CREATE TABLE IF NOT EXISTS `ods_lier_groupe` (
  `id_lier_groupe` int(11) NULL,
  `id_user` int(11) NULL,
  `id_groupe` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_lier_groupe`)
);

CREATE TABLE IF NOT EXISTS `ods_liste_droits` (
  `id_liste_droits` int(11) NULL,
  `id_user` int(11) NULL,
  `Y_droit` varchar(30) NULL,
  `valeur_droit` longtext NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_liste_droits`)
);

CREATE TABLE IF NOT EXISTS `ods_succursale_groupe` (
  `id_sg` int(11) NULL,
  `province` varchar(25) NULL,
  `succursale` varchar(25) NULL,
  `code` varchar(2) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_sg`)
);


-- --------------------------------------------------------
--
-- Tablas de explotación th_* y td_*
--
-- Esas tablas contienen datos transformados a partir de las
-- tablas ods_* 
-- Esas tablas están orientadas a las consultas que se quieren
-- realizar sobre los datos del e-gorrion.
-- Las tablas de hechos (th_*) proporcionan las metricas y 
-- datos de tipo actividad. Las tablas de dimensiones (td_*)
-- permiten realizar un analisis por ciertos ejes.
--  
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `td_prestacion` (
`cod_prest` int(11),
`Prestación` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_prest`)
);

CREATE TABLE IF NOT EXISTS `td_tipoprograma` (
`cod_tiprog` int(11),
`Tipo de Programa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_tiprog`)
);

CREATE TABLE IF NOT EXISTS `td_finprograma` (
`cod_finprog` int(11),
`Financiación del Programa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_finprog`)
);

CREATE TABLE IF NOT EXISTS `td_convprograma` (
`cod_convprog` int(11),
`Convocatoria del programa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_convprog`)
);

CREATE TABLE IF NOT EXISTS `td_provincia` (
`cod_prov` int(11),
`Provincia` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_prov`)
);

CREATE TABLE IF NOT EXISTS `td_comunidad` (
`cod_comu` int(11),
`Comunidad` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_comu`)
);

CREATE TABLE IF NOT EXISTS `td_nacionalidad` (
`cod_nacion` int(11),
`Nacionalidad` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_nacion`)
);

CREATE TABLE IF NOT EXISTS `td_pais` (
`cod_pais` int(11),
`Pais de Nacimiento` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_pais`)
);

CREATE TABLE IF NOT EXISTS `td_situadmin` (
`cod_situadmin` int(11),
`Situación administrativa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_situadmin`)
);

CREATE TABLE IF NOT EXISTS `td_nivelestud` (
`cod_nivelstud` int(11),
`Nivel de estudios` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_nivelstud`)
);

CREATE TABLE IF NOT EXISTS `td_genero` (
`cod_genero` int(11),
`Sexo` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_genero`)
);

CREATE TABLE IF NOT EXISTS `td_solprotec` (
`cod_solprotec` int(11),
`Solicitante de protección internacional` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_solprotec`)
);

CREATE TABLE IF NOT EXISTS `td_inmigrante` (
`cod_inmi` int(11),
`Inmigrante` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_inmi`)
);


-- Tabla intermedia para facilitar la carga de th_prestaciones
CREATE TABLE IF NOT EXISTS `th_obs_mod` (
`id_obs_mod` int(11) NULL,
`T_OBSERVATION_ID` int(11),
`T_DESCRIPTEUR_ID` int(11),
`session` int(11),
`T_MODALITE_ID` int(11),
`date_debut` datetime NULL,
`date_fin` datetime NULL,
`id_enq` int(11) NULL,
`Fecha_Modificacion` timestamp NULL,
`CodeObservation` varchar(50) NULL,
`created` datetime NULL,
`id_enqu` int(11) NULL,
`ObservationPublic` varchar(10) NULL,
`ObservationValide` varchar(10) NULL,
`verouiller` binary(1),
`data_date` timestamp NULL,
`load_date` timestamp NULL, 
-- UNIQUE KEY (`T_OBSERVATION_ID`,`T_DESCRIPTEUR_ID`,`session`,`T_MODALITE_ID`)
UNIQUE KEY (`id_obs_mod`),
INDEX th_obs_mod_sesion_modalite (`T_OBSERVATION_ID`,`T_DESCRIPTEUR_ID`,`session`,`T_MODALITE_ID`),
INDEX th_obs_mod_date (`T_DESCRIPTEUR_ID`,`T_MODALITE_ID`,`data_date`),
INDEX th_obs_mod_dd(`data_date`)
);


CREATE TABLE IF NOT EXISTS `th_prestaciones` (
`T_OBSERVATION_ID` int(11),
`CodeObservation` varchar(50) NULL,
`session` int(11) NULL,
`created` datetime NULL,
`id_enqu` int(11) NULL,
`ObservationPublic` varchar(10) NULL,
`ObservationValide` varchar(10) NULL,
`verouiller` binary(1),
`date_debut` datetime NULL,
`date_fin` datetime NULL, 
`cod_prest` int(11) NULL, 
`cod_tiprog` int(11) NULL,
`cod_finprog` int(11) NULL,
`cod_convprog` int(11) NULL,
`cod_prov` int(11) NULL,
`cod_comu` int(11) NULL,
`Nombre Persona` longtext NULL,
`Primer Apellido` longtext NULL,
`Segundo Apellido` longtext NULL,
`cod_nacion` int(11) NULL,
`cod_paisnacim` int(11) NULL,
`cod_situadmin` int(11) NULL,
`cod_nivelstud` int(11) NULL,
`cod_genero` int(11) NULL,
`NIE` varchar(150) NULL,
`DNI` varchar(150) NULL,
`Pasaporte` varchar(150) NULL,
`Numero Asilo` varchar(150) NULL,
`Fecha Nacimiento` varchar(150) NULL,
`cod_solprotec` int(11) NULL,
`cod_inmi` int(11) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,   
UNIQUE KEY (`T_OBSERVATION_ID`,`session`,`cod_prest`),
INDEX th_prestaciones_dd(`data_date`)
);
