

--
-- Borra las tablas del datamart.
--

DROP TABLE IF EXISTS `ods_descripteur`;
DROP TABLE IF EXISTS `ods_modalite`;
DROP TABLE IF EXISTS `ods_observation`;
DROP TABLE IF EXISTS `ods_obs_descript`;
DROP TABLE IF EXISTS `ods_obs_mod`;
DROP TABLE IF EXISTS `ods_personne`;
DROP TABLE IF EXISTS `ods_succursale_groupe`;

DROP VIEW  IF EXISTS `v_modalite_descripteur`;
DROP TABLE IF EXISTS `jer_modalite_descripteur`;
DROP VIEW  IF EXISTS `v_jer_programas`;
DROP VIEW  IF EXISTS `v_jer_prestaciones`;
DROP TABLE IF EXISTS `temp_obs_mod`;
DROP TABLE IF EXISTS `temp_obs_descript`;

DROP TABLE IF EXISTS `td_prestacion`;
DROP TABLE IF EXISTS `td_tipoprograma`;
DROP TABLE IF EXISTS `td_finprograma`;
DROP TABLE IF EXISTS `td_convprograma`;
DROP TABLE IF EXISTS `td_provincia`;
DROP TABLE IF EXISTS `td_comunidad`;
DROP TABLE IF EXISTS `td_nacionalidad`;
DROP TABLE IF EXISTS `td_pais`;
DROP TABLE IF EXISTS `td_situadmin`;
DROP TABLE IF EXISTS `td_nivelestud`;
DROP TABLE IF EXISTS `td_genero`;
DROP TABLE IF EXISTS `td_solprotec`;
DROP TABLE IF EXISTS `td_inmigrante`;

DROP TABLE IF EXISTS `th_hist_nacionalidad`;
DROP TABLE IF EXISTS `th_hist_sitadmin`;
DROP TABLE IF EXISTS `th_hist_solprotec`;
DROP TABLE IF EXISTS `th_hist_inmigrante`;
DROP TABLE IF EXISTS `th_hist_estudios`;
DROP TABLE IF EXISTS `th_prestaciones`;
