
--
-- Base de datos: `ODS EGORRION`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `descripteur`
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
-- Estructura de tabla para la tabla `modalite`
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
-- Estructura de tabla para la tabla `observation`
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
  `export` int(11) NULL ,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_OBSERVATION_ID`)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obs_descript`
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obs_mod`
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
  KEY `TC_T_11101` (`T_MODALITE_ID`),
  KEY `TC_T_11102` (`T_OBSERVATION_ID`),
  KEY `index_obs_mod` (`T_MODALITE_ID`,`T_OBSERVATION_ID`,`session`)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personne`
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
-- Estructura de tabla para la tabla `questionnaire`
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
-- Estructura de tabla para la tabla `compte`
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
-- Estructura de tabla para la tabla `groupe`
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
-- Estructura de tabla para la tabla `lier_groupe`
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
-- Estructura de tabla para la tabla `liste_droits`
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
-- Estructura de tabla para la tabla `QuestionComplexe`
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
-- Estructura de tabla para la tabla `succursale_groupe`
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

