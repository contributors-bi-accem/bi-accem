

--
-- Borra las tablas del datamart.
--

DROP TABLE `stg_descripteur`;
DROP TABLE `stg_modalite`;
DROP TABLE `stg_observation`;
DROP TABLE `stg_obs_descript`;
DROP TABLE `stg_obs_mod`;
DROP TABLE `stg_personne`;
DROP TABLE `stg_questionnaire`;
DROP TABLE `stg_compte`;
DROP TABLE `stg_groupe`;
DROP TABLE `stg_lier_groupe`;
DROP TABLE `stg_liste_droits`;
DROP TABLE `stg_succursale_groupe`;


DROP TABLE `ods_descripteur`;
DROP TABLE `ods_modalite`;
DROP TABLE `ods_observation`;
DROP TABLE `ods_obs_descript`;
DROP TABLE `ods_obs_mod`;
DROP TABLE `ods_personne`;
DROP TABLE `ods_questionnaire`;
DROP TABLE `ods_compte`;
DROP TABLE `ods_groupe`;
DROP TABLE `ods_lier_groupe`;
DROP TABLE `ods_liste_droits`;
DROP TABLE `ods_succursale_groupe`;

DROP VIEW  `v_modalite_descripteur`;
DROP TABLE `td_prestacion`;
DROP TABLE `td_tipoprograma`;
DROP TABLE `td_finprograma`;
DROP TABLE `td_convprograma`;
DROP TABLE `td_provincia`;
DROP TABLE `td_comunidad`;
DROP TABLE `td_nacionalidad`;
DROP TABLE `td_pais`;
DROP TABLE `td_situadmin`;
DROP TABLE `td_nivelestud`;
DROP TABLE `td_genero`;
DROP TABLE `td_solprotec`;
DROP TABLE `td_inmigrante`;
DROP TABLE `th_obs_mod`;
DROP TABLE `th_prestaciones`;
