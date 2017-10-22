

--
-- Base de datos de la replica del `EGORRION`
--
/*
DELIMITER //

CREATE FUNCTION F_CLEANDATE(fecha VARCHAR(20), format VARCHAR(10)) RETURNS DATE
BEGIN

  DECLARE fecha_out DATE DEFAULT DATE('1970-01-01');

  IF YEAR(fecha)!=0 THEN
    IF MONTH(fecha)=0 THEN
      SET fecha_out = MAKEDATE(YEAR(fecha),1);
    ELSE
       SET fecha_out = str_to_date(fecha,format);
    END IF;
  END IF;
  RETURN fecha_out;
END;
//

DROP PROCEDURE IF EXISTS cursor_ROWPERROW;

CREATE PROCEDURE cursor_ROWPERROW()
BEGIN
  DECLARE cursor_ID INT;
  DECLARE cursor_VAL VARCHAR;
  DECLARE done INT DEFAULT FALSE;
  DECLARE cursor_i CURSOR FOR SELECT ID,VAL FROM table_A;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  OPEN cursor_i;
  read_loop: LOOP
    FETCH cursor_i INTO cursor_ID, cursor_VAL;
    IF done THEN
      LEAVE read_loop;
    END IF;
    INSERT INTO table_B(ID, VAL) VALUES(cursor_ID, cursor_VAL);
  END LOOP;
  CLOSE cursor_i;
END;
//

DELIMITER ;

*/





-- --------------------------------------------------------
-- 
-- Tablas de staging
-- 
-- --------------------------------------------------------


--
-- Estructura de la tabla `stg_descripteur`
--

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
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_modalite`
--

CREATE TABLE IF NOT EXISTS `stg_modalite` (
  `T_MODALITE_ID` int(11) NULL,
  `LibelleModalite` varchar(150) NULL,
  `TypeModalite` varchar(25) NULL,
  `CodeModalite` varchar(20) NULL,
  `RangModalite` int(11) NULL,
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `visible` tinyint(1) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_observation`
--

CREATE TABLE IF NOT EXISTS `stg_observation` (
  `T_OBSERVATION_ID` int(11) NULL,
  `CodeObservation` varchar(50) NULL,
  `ObservationPublic` varchar(10) NULL,
  `ObservationValide` varchar(10) NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `verouiller` binary(1),
  -- `created` datetime NULL,
  `created` varchar(10) NULL,
  `id_enqu` int(11) NULL,
  `suivi` mediumtext NULL,
  `accem` int(1) NULL,
  `export` int(11) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_obs_descript`
--

CREATE TABLE IF NOT EXISTS `stg_obs_descript` (
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Valeur` longtext,
  -- `created` datetime NULL,
  `created` varchar(10) NULL,
  `id_enqu` text NULL,
  `suivi` mediumtext NULL,
  `session` int(11) NULL,
  -- `Fecha_Modificacion` timestamp NULL,
  `Fecha_Modificacion` varchar(20) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_obs_mod`
--

CREATE TABLE IF NOT EXISTS `stg_obs_mod` (
  `id_obs_mod` int(11) NULL,
 -- `date_debut` datetime NULL,
  `date_debut` varchar(20) NULL,
 -- `date_fin` datetime NULL,
  `date_fin` varchar(20) NULL,
  `T_MODALITE_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Reponse` tinyint(4) NULL,
  `id_enq` int(4) NULL,
  `session` int(11) NULL,
 -- `Fecha_Modificacion` timestamp NULL,
  `Fecha_Modificacion` varchar(20) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_personne`
--

CREATE TABLE IF NOT EXISTS `stg_personne` (
  `T_PERSONNE_ID` int(11) NULL,
  `Nom` varchar(50) NULL,
  `Prenom` varchar(50) NULL,
  -- `DateNaissance` date NULL, -- pb: el valor por defecto 2000-00-00 no es una fecha valida...
  `DateNaissance` varchar(10) NULL,
  `Telephone` varchar(14) NULL,
  `Email` varchar(50) NULL,
  `Succursale` varchar(100) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_questionnaire`
--

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

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_compte`
--

CREATE TABLE IF NOT EXISTS `stg_compte` (
  `T_COMPTE_ID` int(20) NULL,
  `Login` varchar(50) NULL,
  `MotdePasse` varchar(20) NULL,
 -- `DateConnexion` date NULL, -- pb: el valor por defecto 0000-00-00 no es una fecha valida...
  `DateConnexion` varchar(10) NULL, 
 -- `HeureConnexion` time NULL,
  `HeureConnexion` varchar(8) NULL,
  `repertoire` varchar(255) NULL,
  `T_PERSONNE_ID` int(11) NULL,
  `langue` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_groupe`
--

CREATE TABLE IF NOT EXISTS `stg_groupe` (
  `id_groupe` int(11) NULL,
  `nom_groupe` varchar(50) NULL,
  `code_groupe` char(5) NULL,
  `id_projet` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_lier_groupe`
--

CREATE TABLE IF NOT EXISTS `stg_lier_groupe` (
  `id_lier_groupe` int(11) NULL,
  `id_user` int(11) NULL,
  `id_groupe` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_liste_droits`
--

CREATE TABLE IF NOT EXISTS `stg_liste_droits` (
  `id_liste_droits` int(11) NULL,
  `id_user` int(11) NULL,
  `Y_droit` varchar(30) NULL,
  `valeur_droit` longtext NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
) COMMENT='droits pour 1 utilisateur';

-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_QuestionComplexe`
--

CREATE TABLE IF NOT EXISTS `stg_QuestionComplexe` (
  `id_question_complexe` int(11) NULL,
  `type_filtre` varchar(100) NULL,
  `defaut` text NULL,
  `rang` int(11) NULL ,
  `param` text NULL,
  `maj_auto` tinyint(1) NULL,
  `editable` tinyint(1) NULL,
  `unique_maj` tinyint(1) NULL,
  `id_question` int(11) NULL,
  `format` int(11) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL
) COMMENT='Filtre de questions complexes';


-- --------------------------------------------------------
--
-- Estructura de la tabla `stg_succursale_groupe`
--

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
-- Tablas ods (replica del egorrion)
--
-- --------------------------------------------------------

--
-- Estructura de la tabla `ods_descripteur`
--

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

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_modalite`
--

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

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_observation`
--

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
  INDEX (`T_OBSERVATION_ID`,`ObservationValide`,`T_QUESTIONNAIRE_ID`)
);
CREATE INDEX ind_observation ON ods_observation (`T_OBSERVATION_ID`,`ObservationValide`,`T_QUESTIONNAIRE_ID`);

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_obs_descript`
--

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
  UNIQUE KEY (`T_DESCRIPTEUR_ID`,`T_OBSERVATION_ID`,`session`)
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

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_obs_mod`
--

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
  INDEX (`T_OBSERVATION_ID`,`T_MODALITE_ID`,`session`,`date_debut`,`date_fin`,`id_enq`)

);
CREATE INDEX ind_prestaciones ON ods_obs_mod (`T_OBSERVATION_ID`,`T_MODALITE_ID`,`session`,`date_debut`,`date_fin`,`id_enq`) ;
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

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_personne`
--

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

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_questionnaire`
--

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

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_compte`
--

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

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_groupe`
--

CREATE TABLE IF NOT EXISTS `ods_groupe` (
  `id_groupe` int(11) NULL,
  `nom_groupe` varchar(50) NULL,
  `code_groupe` char(5) NULL,
  `id_projet` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_groupe`)
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_lier_groupe`
--

CREATE TABLE IF NOT EXISTS `ods_lier_groupe` (
  `id_lier_groupe` int(11) NULL,
  `id_user` int(11) NULL,
  `id_groupe` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_lier_groupe`)
);

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_liste_droits`
--

CREATE TABLE IF NOT EXISTS `ods_liste_droits` (
  `id_liste_droits` int(11) NULL,
  `id_user` int(11) NULL,
  `Y_droit` varchar(30) NULL,
  `valeur_droit` longtext NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_liste_droits`)
) COMMENT='droits pour 1 utilisateur';

-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_QuestionComplexe`
--

CREATE TABLE IF NOT EXISTS `ods_QuestionComplexe` (
  `id_question_complexe` int(11) NULL,
  `type_filtre` varchar(100) NULL,
  `defaut` text NULL,
  `rang` int(11) NULL ,
  `param` text NULL,
  `maj_auto` tinyint(1) NULL,
  `editable` tinyint(1) NULL,
  `unique_maj` tinyint(1) NULL,
  `id_question` int(11) NULL,
  `format` int(11) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_question_complexe`)
) COMMENT='Filtre de questions complexes';


-- --------------------------------------------------------
--
-- Estructura de la tabla `ods_succursale_groupe`
--

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
-- Tablas de explotación
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

CREATE TABLE IF NOT EXISTS `th_prestaciones` (
`T_OBSERVATION_ID` int(11),
`NB` varchar(50) NULL,
`session` int(11) NULL,
`cod_prest` int(11) NULL, -- WHERE [T_DESCRIPTEUR_ID]='9074'; // esa pregunta corresponde a una prestación
`date_debut` datetime NULL,
`date_fin` datetime NULL,   
`cod_tiprog` int(11) NULL,
`cod_finprog` int(11),
`cod_convprog` int(11),
`cod_prov` int(11),
`cod_comu` int(11),
`Nombre Persona`,
`Primer Apellido`,
`Segundo Apellido`,
`cod_nacion` int(11),
`cod_paisnacim` int(11),
`cod_situadmin` int(11),
`cod_nivelstud` int(11),
`cod_genero` int(11),
`NIE` varchar(150),
`DNI` varchar(150),
`Pasaporte` varchar(150),
`Numero Asilo` varchar(150),
`Fecha Nacimiento` varchar(150),
`cod_solprotec` int(11),
`cod_inmi` int(11),
`data_date` timestamp NULL,
`load_date` timestamp NULL,   
UNIQUE KEY (`T_OBSERVATION_ID`,`session`,`cod_prest`)
);
