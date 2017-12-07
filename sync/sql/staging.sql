
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_ts=NOW();
SET sql_mode='';


-- recarga de la tabla descripteur
REPLACE INTO `armario.ods_descripteur` 
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
@data_date,
FROM `egorrion.descripteur`
SET
`data_date`=@load_ts;


-- Recarga de la tabla modalite
REPLACE INTO `armario.ods_modalite`
SELECT `T_MODALITE_ID`,
`LibelleModalite`,
`TypeModalite`,
`CodeModalite`,
`RangModalite`,
`T_DESCRIPTEUR_ID`,
`visible`,
@data_date
FROM `stg_modalite`
SET
`data_date`=@load_ts;


-- Recarga de la tabla observation
REPLACE INTO `armario.ods_observation`  
SELECT `T_OBSERVATION_ID`,
`CodeObservation`,
`ObservationPublic`,
`ObservationValide`,
`T_QUESTIONNAIRE_ID`,
`verouiller`,
-- F_CLEANDATE(`created`,@date_format),
`created`,
`id_enqu`,
`suivi`,
`accem`,
`export`,
@data_date
FROM `stg_observation`
SET
`data_date`=@load_ts;

-- Recarga de la tabla obs_descript
SET autocommit=0; -- permite mejorar el rendimiento

REPLACE INTO `armario.ods_obs_descript` 
SELECT `T_DESCRIPTEUR_ID`,
`T_OBSERVATION_ID`,
`Valeur`,
`created`,
`id_enqu`,
`suivi`,
`session`,
`Fecha_Modificacion`,
@data_date 
FROM `stg_obs_descript`
WHERE `Fecha_Modificacion` >= @from_ts 
AND   `Fecha_Modificacion` < @to_ts
SET
`data_date`=@load_ts;
COMMIT;

-- Recarga de la tabla obs_mod
REPLACE INTO `armario.ods_obs_mod`  
SELECT `id_obs_mod`,
`date_debut`,
`date_fin`,
`T_MODALITE_ID`,
`T_OBSERVATION_ID`,
`Reponse`,
`id_enq`,
`session`,
`Fecha_Modificacion`,
@data_date
FROM `stg_obs_mod`
WHERE `Fecha_Modificacion` >= @from_ts 
AND   `Fecha_Modificacion` < @to_ts
ORDER BY `T_OBSERVATION_ID`,`T_MODALITE_ID`,`session`,`date_debut`,`date_fin`,`id_enq`
SET
`data_date`=@load_ts;
COMMIT;

SET autocommit=1;
