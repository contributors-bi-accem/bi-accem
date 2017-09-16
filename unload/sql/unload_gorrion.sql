
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

-- Descarga total de la tabla compte_groupe
SET @table = 'compte_groupe';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `id_projet`,
  `T_COMPTE_ID`,
  `cle`,
  `typeCle`,
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


-- Descarga total de la tabla session
SET @table = 'session';
SET @output_file = CONCAT(@unload_dir, @file_prefix, @table,"_",DATE_FORMAT(@to_ts,@file_datefmt),".dat");
SET @query = CONCAT(
  "SELECT `T_SESSION_ID`,
  `titreSession`,
  DATE_FORMAT(`dateSession`,'",@date_format,"'),
  `T_COMPTE_ID`,
  `T_QUESTIONNAIRE_ID`,
  '", @to_ts, "' as `unload_dt`
FROM `",@table,"` 
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;

