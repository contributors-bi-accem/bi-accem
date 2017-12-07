
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_ts=NOW();
SET sql_mode='';


-- carga completa de la tabla descripteur
LOAD DATA INFILE '{descripteur_file}' REPLACE INTO TABLE `stg_descripteur` 
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}' 
(`T_DESCRIPTEUR_ID`,
`LibelleDescripteur`,
`SautDescripteur`,
`Valeur`,
`CodeDescripteur`,
`RangDescripteur`,
`T_QUESTIONNAIRE_ID`,
`description`,
`isSession`,
`saisissable`,
@data_date,
@load_date)
SET
`data_date`=str_to_date(@data_date,@ts_format),
`load_date`=@load_ts;


-- carga completa de la tabla modalite
LOAD DATA INFILE '{modalite_file}' REPLACE INTO TABLE `stg_modalite`
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`T_MODALITE_ID`,
`LibelleModalite`,
`TypeModalite`,
`CodeModalite`,
`RangModalite`,
`T_DESCRIPTEUR_ID`,
`visible`,
@data_date,
@load_date)
SET 
`data_date`=str_to_date(@data_date,@ts_format),
`load_date`=@load_ts;


-- carga completa de la tabla observation
LOAD DATA INFILE '{observation_file}' REPLACE INTO TABLE `stg_observation`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`T_OBSERVATION_ID`,
`CodeObservation`,
`ObservationPublic`,
`ObservationValide`,
`T_QUESTIONNAIRE_ID`,
`verouiller`,
@created,
`id_enqu`,
`suivi`,
`accem`,
`export`,
@data_date,
@load_date)
SET 
`created`=str_to_date(@created,@date_format),
`data_date`=str_to_date(@data_date,@ts_format),
`load_date`=@load_ts;


-- carga completa de la tabla compte
LOAD DATA INFILE '{compte_file}' REPLACE INTO TABLE `stg_compte`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`T_COMPTE_ID`,
`Login`,
`MotdePasse`, 
@DateConnexion,
`HeureConnexion`,
`repertoire`,
`T_PERSONNE_ID`,
`langue`,
@data_date,
@load_date)
SET 
`DateConnexion`=str_to_date(@DateConnexion,@date_format),
`data_date`=str_to_date(@data_date,@ts_format),
`load_date`=@load_ts;


-- carga completa de la tabla lier_groupe
LOAD DATA INFILE '{lier_groupe_file}' REPLACE INTO TABLE `stg_lier_groupe`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`id_lier_groupe`,
`id_user`,
`id_groupe`,
@data_date,
@load_date)
SET 
`data_date`=str_to_date(@data_date,@ts_format),
`load_date`=@load_ts;


-- carga completa de la tabla groupe
LOAD DATA INFILE '{groupe_file}' REPLACE INTO TABLE `stg_groupe`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`id_groupe`,
`nom_groupe`,
`code_groupe`,
`id_projet`,
@data_date,
@load_date)
SET 
`data_date`=str_to_date(@data_date,@ts_format),
`load_date`=@load_ts;


-- carga completa de la tabla liste_droits
LOAD DATA INFILE '{liste_droits_file}' REPLACE INTO TABLE `stg_liste_droits`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`id_liste_droits`,
`id_user`,
`Y_droit`,
`valeur_droit`,
@data_date,
@load_date)
SET 
`data_date`=str_to_date(@data_date,@ts_format), 
`load_date`=@load_ts;


-- carga completa de la tabla succursale_groupe
LOAD DATA INFILE '{succursale_groupe_file}' REPLACE INTO TABLE `stg_succursale_groupe`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`id_sg`,
`province`,
`succursale`,
`code`,
@data_date,
@load_date)
SET 
`data_date`=str_to_date(@data_date,@ts_format), 
`load_date`=@load_ts;


-- carga completa de la tabla personne
LOAD DATA INFILE '{personne_file}' REPLACE INTO TABLE `stg_personne`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`T_PERSONNE_ID`,
`Nom`,
`Prenom`,
@DateNaissance,
`Telephone`,
`Email`,
`Succursale`,
@data_date,
@load_date) 
SET 
`DateNaissance`=str_to_date(@DateNaissance,@date_format),
`data_date`=str_to_date(@data_date,@ts_format), 
`load_date`=@load_ts;


-- carga completa de la tabla questionnaire
LOAD DATA INFILE '{questionnaire_file}' REPLACE INTO TABLE `stg_questionnaire`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`T_QUESTIONNAIRE_ID`,
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
@data_date, 
@load_date) 
SET 
`data_date`=str_to_date(@data_date,@ts_format), 
`load_date`=@load_ts;


-- Recarga de la tabla obs_descript
LOAD DATA INFILE '{obs_descript_file}' REPLACE INTO TABLE `stg_obs_descript`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`T_DESCRIPTEUR_ID`,
`T_OBSERVATION_ID`,
`Valeur`,
@created,
`id_enqu`,
`suivi`,
`session`,
@Fecha_Modificacion,
@data_date, 
@load_date) 
SET 
`created`=str_to_date(@created,@date_format),
`Fecha_Modificacion`=str_to_date(@Fecha_Modificacion,@date_format),
`data_date`=str_to_date(@data_date,@ts_format), 
`load_date`=@load_ts;


-- Recarga de la tabla obs_mod
LOAD DATA INFILE '{obs_mod_file}' REPLACE INTO TABLE `stg_obs_mod`  
FIELDS TERMINATED BY '{fieldseparator}'
LINES TERMINATED BY '{endofline}'
(`id_obs_mod`,
@date_debut,
@date_fin,
`T_MODALITE_ID`,
`T_OBSERVATION_ID`,
`Reponse`,
`id_enq`,
`session`,
@Fecha_Modificacion,
@data_date, 
@load_date) 
SET 
`date_debut`=str_to_date(@date_debut,@date_format),
`date_fin`=str_to_date(@date_fin,@date_format),
`Fecha_Modificacion`=str_to_date(@Fecha_Modificacion,@date_format),
`data_date`=str_to_date(@data_date,@ts_format), 
`load_date`=@load_ts;
