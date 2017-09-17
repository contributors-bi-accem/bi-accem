
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
-- Estructura de tabla para la tabla `regroupement`
--
/* no tiene registros
CREATE TABLE IF NOT EXISTS `ods_regroupement` (
  `T_REGROUPEMENT_ID` int(11) NULL,
  `libelleRegroupement` varchar(255) NULL,
  `modalites` varchar(255) NULL,
  `CodeRegroupement` varchar(4) NULL,
  `TypeRegroupement` varchar(20) NULL,
  `T_SESSION_ID` int(11) NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY `T_REGROUPEMENT_ID` (`T_REGROUPEMENT_ID`)
);
*/

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `appartient`
--
/* 84 registros, solo para vincular usuarios a Accem...
CREATE TABLE IF NOT EXISTS `ods_appartient` (
  `T_APPARTIENT_ID` int(11) NULL,
  `T_ORGANISME_ID` int(11) NULL,
  `T_PERSONNE_ID` int(11) NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_APPARTIENT_ID`)
) COMMENT='liaison entre organisme(Equipe) et personne';
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `associer`
--
/* diferencia entre root y member
CREATE TABLE IF NOT EXISTS `ods_associer` (
  `id_associer` int(11) NULL,
  `T_PERSONNE_ID` int(11) NULL,
  `X_statut` varchar(50) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_associer`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `board`
--
/* 25 registros, no se entiende muy bien
CREATE TABLE IF NOT EXISTS `ods_board` (
  `id_board` int(11) NULL,
  `id_qcm` int(11) NULL,
  `rang` int(11) NULL,
  `code` varchar(4) NULL,
  `restrictif` tinyint(1) NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
   UNIQUE KEY (`id_board`)
);
*/


-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `bool452_pre`
--
/* parece una explotación basica
CREATE TABLE IF NOT EXISTS `ods_bool452_pre` (
  `code_question` varchar(50) NULL,
  `total_rep` int(11) NULL,
  `total_rep_w_nr_wo` int(11) NULL
)  ;
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `classe_droits`
--
/* son permisos de usuarios
CREATE TABLE IF NOT EXISTS `ods_classe_droits` (
  `id_classe_droits` int(11) NULL,
  `X_statut` varchar(100) NULL,
  `Y_droit` varchar(100) NULL,
  `valeur_defaut` varchar(50) NULL,
  `description` varchar(200) NULL,
  `rang` varchar(100) NULL,
  `id_entite` int(11) NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY (`id_classe_droits`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `CodeFiltre`
--
/* tabla vacia
CREATE TABLE IF NOT EXISTS `ods_CodeFiltre` (
  `id_code` int(11) NULL,
  `Code` varchar(255) NULL,
  `id_filtre` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_code`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `codeRef`
--
/* no se entiende muy bien lo que aporta
CREATE TABLE IF NOT EXISTS `ods_codeRef` (
  `id` int(11) NULL,
  `id_one` int(11) NULL,
  `id_two` int(11) NULL,
  `type` varchar(200) NULL,
  `qcm_one` int(11) NULL,
  `qcm_two` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id`)
);
*/
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
-- Estructura de tabla para la tabla `compte_groupe`
--
/* tabla vacia
CREATE TABLE IF NOT EXISTS `ods_compte_groupe` (
  `id_projet` int(11) NULL,
  `T_COMPTE_ID` int(11) NULL,
  `cle` varchar(25) NULL,
  `typeCle` varchar(25) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_projet`,`T_COMPTE_ID`,`typeCle`,`cle`)
);
*/

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entite`
--
/* 4 registros que aportan nada
CREATE TABLE IF NOT EXISTS `ods_entite` (
  `id_entite` int(11) NULL,
  `label_entite` varchar(100) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_entite`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `Filtre`
--
/* 6 registros que aportan nada
CREATE TABLE IF NOT EXISTS `ods_Filtre` (
  `id_filtre` int(11) NULL,
  `NomFiltre` varchar(255) NULL,
  `id_qcm` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_filtre`)
);
*/
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
-- Estructura de tabla para la tabla `langue`
--
/* es para la interfaz web
CREATE TABLE IF NOT EXISTS `ods_langue` (
  `T_PAYS_ID` int(11) NULL,
  `libellePays` varchar(30) NULL,
  `Nonreponse` varchar(50) NULL,
  `Sansobjet` varchar(50) NULL,
  `urlDrapeau` varchar(255) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_PAYS_ID`)
);
*/
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
-- Estructura de tabla para la tabla `m_obligatoire_452`
--
/* 48000 regitros,  parece una explotación
CREATE TABLE IF NOT EXISTS `ods_m_obligatoire_452` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `modalite` int(11) NULL,
  `libre` int(11) NULL,
  `A0` varchar(10) NULL,
  `A1` varchar(10) NULL,
  `SX` varchar(10) NULL,
  `DA` varchar(10) NULL,
  `SP` varchar(10) NULL,
  `AE` varchar(10) NULL,
  `NA` varchar(10) NULL,
  `publi` varchar(10) NULL,
  `vali` varchar(10) NULL,
  `suppr` int(2) NULL,
  `Vrai` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `m_obligatoire_453`
--
/* 39745 registros, parece una explotación
CREATE TABLE IF NOT EXISTS `ods_m_obligatoire_453` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `modalite` int(11) NULL,
  `libre` int(11) NULL,
  `A0` varchar(10) NULL,
  `A1` varchar(10) NULL,
  `Sx` varchar(10) NULL,
  `Da` varchar(10) NULL,
  `Na` varchar(10) NULL,
  `Sp` varchar(10) NULL,
  `DB` varchar(10) NULL,
  `DD` varchar(10) NULL,
  `SA` varchar(10) NULL,
  `SI` varchar(10) NULL,
  `AE` varchar(10) NULL,
  `AA` varchar(10) NULL,
  `DN` varchar(10) NULL,
  `AP` varchar(10) NULL,
  `NG` varchar(10) NULL,
  `OT` varchar(10) NULL,
  `ET` varchar(10) NULL,
  `publi` varchar(10) NULL,
  `vali` varchar(10) NULL,
  `suppr` int(2) NULL,
  `Vrai` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/



-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `organisme`
--
/* no aporta nada
CREATE TABLE IF NOT EXISTS `ods_organisme` (
  `T_ORGANISME_ID` int(11) NULL,
  `AdresseOrganisme` varchar(50) NULL,
  `TelephoneOrganisme` varchar(14) NULL,
  `LibelleOrganisme` varchar(50) NULL,
  `FaxOrganisme` varchar(50) NULL,
  `T_PAYS_ID` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_ORGANISME_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partenariat`
--
/* 1 solo registro: Accem
CREATE TABLE IF NOT EXISTS `ods_partenariat` (
  `id_partenariat` int(11) NULL,
  `nom_partenariat` varchar(50) NULL,
  `desc_partenariat` tinytext NULL,
  `langue_dominante` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_partenariat`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partenariat_grouper`
--
/* vacia
CREATE TABLE IF NOT EXISTS `ods_partenariat_grouper` (
  `id_partenariat_grouper` int(11) NULL,
  `T_ORGANISME_ID` int(11) NULL,
  `id_partenariat` int(11) NULL,
  `qualite_orga` varchar(50) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_partenariat_grouper`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partenariat_lier`
--
/* todos son de Accem...
CREATE TABLE IF NOT EXISTS `ods_partenariat_lier` (
  `id_partenariat_lier` int(11) NULL,
  `id_partenariat` int(11) NULL,
  `T_PERSONNE_ID` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_partenariat_lier`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `partenariat_travailler`
--
/* 3 registros
CREATE TABLE IF NOT EXISTS `ods_partenariat_travailler` (
  `id_partenariat_travailler` int(11) NULL,
  `id_partenariat` int(11) NULL,
  `id_projet` int(11) DEFAULT NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_partenariat_travailler`)
);
*/

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pragma452`
--
/* 7 registros
CREATE TABLE IF NOT EXISTS `ods_pragma452` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pragma453`
--
/* 6 registros
CREATE TABLE IF NOT EXISTS `ods_pragma453` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `projet`
--
/* 2 registros:Accem y test
CREATE TABLE IF NOT EXISTS `ods_projet` (
  `id_projet` int(11) NULL,
  `Nom_projet` varchar(50) NULL,
  `MdP_projet` varchar(100) NULL,
  `LibelleSujet` varchar(255) NULL,
  `T_COMPTE_ID` int(11) ,
  `logo` varchar(255) NULL,
  `urlSite` varchar(255) NULL,
  `CodeGroupe` varchar(50) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_projet`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `publivali452`
--
/* 4400 registros, parece una explotación
CREATE TABLE IF NOT EXISTS `ods_publivali452` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `modalite` int(11) NULL,
  `libre` int(11) NULL,
  `publi` varchar(10) NULL,
  `vali` varchar(10) NULL,
  `suppr` int(2) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `publivali453`
--
/* 10 registros, no esta claro a que sirve
CREATE TABLE IF NOT EXISTS `ods_publivali453` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `modalite` int(11) NULL,
  `libre` int(11) NULL,
  `publi` varchar(10) NULL,
  `vali` varchar(10) NULL,
  `suppr` int(2) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `publivali_nat_452`
--
/* 40.000 registros pero no esta claro lo que aporta, parece una explotación
CREATE TABLE IF NOT EXISTS `ods_publivali_nat_452` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `modalite` int(11) NULL,
  `libre` int(11) NULL,
  `publi` varchar(10) NULL,
  `vali` varchar(10) NULL,
  `suppr` int(2) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `publivali_nat_453`
--
/* 10 registros, parece una explotación
CREATE TABLE IF NOT EXISTS `ods_publivali_nat_453` (
  `T_OBSERVATION_ID` int(11) NULL,
  `individu` varchar(50) NULL,
  `modalite` int(11) NULL,
  `libre` int(11) NULL,
  `publi` varchar(10) NULL,
  `vali` varchar(10) NULL,
  `suppr` int(2) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_OBSERVATION_ID`)
);
*/
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
-- Estructura de tabla para la tabla `requete_bord`
--
/* 0 registros
CREATE TABLE IF NOT EXISTS `ods_requete_bord` (
  `T_TV_ID` int(11) NULL,
  `requete` text NULL,
  `T_TB_ID` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_TV_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `session`
--
/* 2 registros de 2003...
CREATE TABLE IF NOT EXISTS `ods_session` (
  `T_SESSION_ID` int(11) NULL,
  `titreSession` varchar(255) NULL,
  `dateSession` date NULL ,
  `T_COMPTE_ID` int(11) NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,
  UNIQUE KEY `T_SESSION_ID` (`T_SESSION_ID`)
);
*/
-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `src`
--
/* 14 registros en total
CREATE TABLE IF NOT EXISTS `ods_src` (
  `id_src` int(11) NULL,
  `id_qcm` int(11) NULL,
  `type` varchar(100) NULL,
  `value` varchar(100) NULL,
  `label_src` varchar(300) NULL,
  `display` tinyint(1) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`id_src`)
);
*/
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

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tableau_bord`
--
/* 0 registros
CREATE TABLE IF NOT EXISTS `ods_tableau_bord` (
  `T_TB_ID` int(11) NULL,
  `LibelleTB` varchar(255) NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `data_date` timestamp NULL,   
  `load_date` timestamp NULL,   
  UNIQUE KEY (`T_TB_ID`)
);
*/
