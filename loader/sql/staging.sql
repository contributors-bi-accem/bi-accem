
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_ts=NOW();
SET sql_mode='';





-- recarga total de la tabla descripteur
REPLACE INTO `ods_descripteur` 
SELECT `T_DESCRIPTEUR_ID`,
`LibelleDescripteur`,
`SautDescripteur`,
`Valeur`,
`CodeDescripteur`,
`RangDescripteur`,
`T_QUESTIONNAIRE_ID`,
`description`,
`isSession`,
`saisissable`,
`data_date`,
`load_date`
FROM `stg_descripteur`;

-- Recarga total de la tabla modalite
REPLACE INTO `ods_modalite`
SELECT `T_MODALITE_ID`,
`LibelleModalite`,
`TypeModalite`,
`CodeModalite`,
`RangModalite`,
`T_DESCRIPTEUR_ID`,
`visible`,
`data_date`,
`load_date`
FROM `stg_modalite`;


-- Recarga total de la tabla observation
REPLACE INTO `ods_observation`  
SELECT `T_OBSERVATION_ID`,
`CodeObservation`,
`ObservationPublic`,
`ObservationValide`,
`T_QUESTIONNAIRE_ID`,
`verouiller`,
F_CLEANDATE(`created`,@date_format),
`id_enqu`,
`suivi`,
`accem`,
`export`,
`data_date`,
`load_date`
FROM `stg_observation`;


-- Recarga total de la tabla compte
REPLACE INTO `ods_compte`  
SELECT `T_COMPTE_ID`,
`Login`,
`MotdePasse`,
F_CLEANDATE(`DateConnexion`,@date_format),
`HeureConnexion`,
`repertoire`,
`T_PERSONNE_ID`,
`langue`,
`data_date`,
`load_date`
FROM `stg_compte`;

-- Recarga total de la tabla lier_groupe
REPLACE INTO `ods_lier_groupe` 
SELECT `id_lier_groupe`,
`id_user`,
`id_groupe`,
`data_date`,
`load_date`
FROM `stg_lier_groupe`;


-- Recarga total de la tabla groupe
REPLACE INTO `ods_groupe` 
SELECT `id_groupe`,
`nom_groupe`,
`code_groupe`,
`id_projet`,
`data_date`,
`load_date`
FROM `stg_groupe`;


-- Recarga total de la tabla liste_droits
REPLACE INTO `ods_liste_droits` 
SELECT `id_liste_droits`,
`id_user`,
`Y_droit`,
`valeur_droit`,
`data_date`,
`load_date`
FROM `stg_liste_droits`;

-- Recarga total de la tabla succursale_groupe
REPLACE INTO `ods_succursale_groupe` 
SELECT `id_sg`,
`province`,
`succursale`,
`code`,
`data_date`,
`load_date`
FROM `stg_succursale_groupe`;



-- Recarga total de la tabla QuestionComplexe
REPLACE INTO `ods_QuestionComplexe`  
SELECT `id_question_complexe`,
`type_filtre`,
`defaut`,
`rang`,
`param`,
`maj_auto`,
`editable`,
`unique_maj`,
`id_question`,
`format`,
`data_date`,
`load_date`
FROM `stg_QuestionComplexe`;



-- Recarga total de la tabla personne
REPLACE INTO `ods_personne` 
SELECT `T_PERSONNE_ID`,
`Nom`,
`Prenom`,
F_CLEANDATE(`DateNaissance`,@date_format),
`Telephone`,
`Email`,
`Succursale`,
`data_date`,
`load_date`
FROM `stg_personne`;


-- Recarga total de la tabla questionnaire
REPLACE INTO `ods_questionnaire` 
SELECT `T_QUESTIONNAIRE_ID`,
`LibelleQuestionnaire`,
`CleModification`,
`CleSaisie`,
`CleSuppression`,
`CleValidation`,
`ClePublique`,
`CleVisualisation`,
`GID`,
`ValiditeReponse`,
`publicationReponse`,
`id_projet`,
`T_PAYS_ID`,
`CleExpert`,
`Suivi`,
`DescrGroupe`,
`DescrGroupe2`,
`DescrRech`,
`saisie`,
`data_date`,
`load_date` 
FROM `stg_questionnaire`;


-- Recarga incremental de la tabla obs_descript
REPLACE INTO `ods_obs_descript` 
SELECT `T_DESCRIPTEUR_ID`,
`T_OBSERVATION_ID`,
`Valeur`,
F_CLEANDATE(`created`,@date_format),
`id_enqu`,
`suivi`,
`session`,
F_CLEANDATE(`Fecha_Modificacion`,@date_format),
`data_date`,
`load_date` 
FROM `stg_obs_descript`;


-- Recarga incremental de la tabla obs_mod
SET autocommit=0;
REPLACE INTO `ods_obs_mod`  
SELECT `id_obs_mod`,
F_CLEANDATE(`date_debut`,@date_format),
F_CLEANDATE(`date_fin`,@date_format),
`T_MODALITE_ID`,
`T_OBSERVATION_ID`,
`Reponse`,
`id_enq`,
`session`,
F_CLEANDATE(`Fecha_Modificacion`,@date_format),
`data_date`,
`load_date`
FROM `stg_obs_mod`;
commit;
-- Una vez recargado las tablas del ODS, podemos truncar las tablas de staging

/*
TRUNCATE `stg_descripteur`;
TRUNCATE `stg_modalite`;
TRUNCATE `stg_observation`;
TRUNCATE `stg_compte`;
TRUNCATE `stg_lier_groupe`;
TRUNCATE `stg_groupe`;
TRUNCATE `stg_liste_droits`;
TRUNCATE `stg_succursale_groupe`;
TRUNCATE `stg_QuestionComplexe`;
TRUNCATE `stg_personne`;
TRUNCATE `stg_questionnaire`;
TRUNCATE `stg_obs_descript`;
TRUNCATE `stg_obs_mod`;
*/