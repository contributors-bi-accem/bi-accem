
SET @ts_format='%Y-%m-%d_%H:%i:%S';
SET @filets_format='%Y-%m-%d_%H.%i.%S'; -- hay un pb con los ":" en los nombres de fichero
SET @date_format='%Y-%m-%d';
SET @fieldseparator='¬';
SET @endofline='\n';

-- Descarga total de la tabla descripteur
SET @output_file = CONCAT(@unload_dir, @file_prefix, "_descripteur_", DATE_FORMAT(@until_ts,@filets_format), ".dat");
SET @query = CONCAT("SELECT `T_DESCRIPTEUR_ID`,
  `LibelleDescripteur`,
  `SautDescripteur`,
  `Valeur`,
  `CodeDescripteur`,
  `RangDescripteur`,
  `T_QUESTIONNAIRE_ID`,
  `description`,
  `isSession`,
  `saisissable`,
  '", @until_ts, "' as `unload_dt`
FROM `descripteur`
INTO OUTFILE '", @output_file, "'
FIELDS TERMINATED BY '", @fieldseparator, "'
LINES TERMINATED BY '", @endofline, "';");
select @query;
PREPARE query FROM @query;
EXECUTE query;
DEALLOCATE PREPARE query;





