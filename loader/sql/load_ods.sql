
SET @ts_format='%Y-%m-%d_%H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @fieldseparator='¬';
SET @endofline='\n';

-- Descarga total de la tabla descripteur
SET @table = 'descripteur';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_DESCRIPTEUR_ID`,
  `LibelleDescripteur`,
  `SautDescripteur`,
  `Valeur`,
  `CodeDescripteur`,
  `RangDescripteur`,
  `T_QUESTIONNAIRE_ID`,
  `description`,
  `isSession`,
  `saisissable`,
  '",@to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla modalite
SET @table = 'modalite';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_MODALITE_ID`,
  `LibelleModalite`,
  `TypeModalite`,
  `CodeModalite`,
  `RangModalite`,
  `T_DESCRIPTEUR_ID`,
  `visible`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla observation
SET @table = 'observation';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_OBSERVATION_ID`,
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
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla compte
SET @table = 'compte';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_COMPTE_ID`,
  `Login`,
  `MotdePasse`, 
  DATE_FORMAT(`DateConnexion`,'",@date_format,"'),
  `HeureConnexion`,
  `repertoire`,
  `T_PERSONNE_ID`,
  `langue`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla lier_groupe
SET @table = 'lier_groupe';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `id_lier_groupe`,
  `id_user`,
  `id_groupe`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla groupe
SET @table = 'groupe';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `id_groupe`,
  `nom_groupe`,
  `code_groupe`,
  `id_projet`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla liste_droits
SET @table = 'liste_droits';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `id_liste_droits`,
  `id_user`,
  `Y_droit`,
  `valeur_droit`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;

-- Descarga total de la tabla succursale_groupe
SET @table = 'succursale_groupe';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `id_sg`,
  `province`,
  `succursale`,
  `code`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla QuestionComplexe
SET @table = 'QuestionComplexe';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `id_question_complexe`,
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
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla personne
SET @table = 'personne';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_PERSONNE_ID`,
  `Nom`,
  `Prenom`,
  DATE_FORMAT(`DateNaissance`,'",@date_format,"'),
  `Telephone`,
  `Email`,
  `Succursale`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga total de la tabla questionnaire
SET @table = 'questionnaire';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_QUESTIONNAIRE_ID`,
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
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga incremental de la tabla obs_descript
SET @table = 'obs_descript';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_DESCRIPTEUR_ID`,
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
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;


-- Descarga incremental de la tabla obs_mod
SET @table = 'obs_mod';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `id_obs_mod`,
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
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;
