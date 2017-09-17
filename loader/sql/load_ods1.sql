
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_ts=NOW();

-- recarga total de la tabla ods_descripteur
  LOAD DATA INFILE '{descripteur_file}' REPLACE INTO TABLE `ods_descripteur` 
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
  @data_date1,
  @load_date)
  SET
  data_date=str_to_date(@data_date1,@ts_format),
  load_date=@load_ts;


/*
-- Descarga total de la tabla modalite
SET @table = 'modalite';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `T_MODALITE_ID`,
  `LibelleModalite`,
  `TypeModalite`,
  `CodeModalite`,
  `RangModalite`,
  `T_DESCRIPTEUR_ID`,
  `visible`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla observation
SET @table = 'observation';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `T_OBSERVATION_ID`,
  `CodeObservation`,
  `ObservationPublic`,
  `ObservationValide`,
  `T_QUESTIONNAIRE_ID`,
  `verouiller`,
  DATE_FORMAT(`created`,'",@date_format,"'),
  `id_enqu`,
  `suivi`,
  `accem`,
  `export`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla compte
SET @table = 'compte';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `T_COMPTE_ID`,
  `Login`,
  `MotdePasse`, 
  DATE_FORMAT(`DateConnexion`,'",@date_format,"'),
  `HeureConnexion`,
  `repertoire`,
  `T_PERSONNE_ID`,
  `langue`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla lier_groupe
SET @table = 'lier_groupe';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `id_lier_groupe`,
  `id_user`,
  `id_groupe`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla groupe
SET @table = 'groupe';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `id_groupe`,
  `nom_groupe`,
  `code_groupe`,
  `id_projet`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla liste_droits
SET @table = 'liste_droits';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `id_liste_droits`,
  `id_user`,
  `Y_droit`,
  `valeur_droit`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;

-- Descarga total de la tabla succursale_groupe
SET @table = 'succursale_groupe';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `id_sg`,
  `province`,
  `succursale`,
  `code`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla QuestionComplexe
SET @table = 'QuestionComplexe';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `id_question_complexe`,
  `type_filtre`,
  `defaut`,
  `rang`,
  `param`,
  `maj_auto`,
  `editable`,
  `unique_maj`,
  `id_question`,
  `format`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla personne
SET @table = 'personne';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `T_PERSONNE_ID`,
  `Nom`,
  `Prenom`,
  DATE_FORMAT(`DateNaissance`,'",@date_format,"'),
  `Telephone`,
  `Email`,
  `Succursale`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla questionnaire
SET @table = 'questionnaire';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `T_QUESTIONNAIRE_ID`,
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
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga incremental de la tabla obs_descript
SET @table = 'obs_descript';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `T_DESCRIPTEUR_ID`,
  `T_OBSERVATION_ID`,
  `Valeur`,
  DATE_FORMAT(`created`,'",@date_format,"'),
  `id_enqu`,
  `suivi`,
  `session`,
  DATE_FORMAT(`Fecha_Modificacion`,'",@date_format,"'),
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"`
WHERE `Fecha_Modificacion` >= '", @from_ts,"' 
AND   `Fecha_Modificacion` < '", @to_ts,"'
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga incremental de la tabla obs_mod
SET @table = 'obs_mod';
SET @input_file = CONCAT(@datafile_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "LOAD DATA INFILE '", @input_file, "' REPLACE INTO TABLE '", @table, "'  `id_obs_mod`,
  DATE_FORMAT(`date_debut`,'",@date_format,"'),
  DATE_FORMAT(`date_fin`,'",@date_format,"'),
  `T_MODALITE_ID`,
  `T_OBSERVATION_ID`,
  `Reponse`,
  `id_enq`,
  `session`,
  DATE_FORMAT(`Fecha_Modificacion`,'",@date_format,"'),
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"`
WHERE `Fecha_Modificacion` >= '", @from_ts,"' 
AND   `Fecha_Modificacion` < '", @to_ts,"'
INTO OUTFILE '", @input_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;
