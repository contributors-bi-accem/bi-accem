
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_ts=NOW();
SET sql_mode='';


CREATE TABLE IF NOT EXISTS `th_obs_mod` (
`id_obs_mod` int(11) NULL,
`T_OBSERVATION_ID` int(11),
`T_DESCRIPTEUR_ID` int(11),
`session` int(11),
`T_MODALITE_ID` int(11),
`date_debut` datetime NULL,
`date_fin` datetime NULL,
`id_enq` int(11) NULL,
`Fecha_Modificacion` timestamp NULL,
`CodeObservation` varchar(50) NULL,
`created` datetime NULL,
`id_enqu` int(11) NULL,
`ObservationPublic` varchar(10) NULL,
`ObservationValide` varchar(10) NULL,
`verouiller` binary(1),
`data_date` timestamp NULL,
`load_date` timestamp NULL, 
-- UNIQUE KEY (`T_OBSERVATION_ID`,`T_DESCRIPTEUR_ID`,`session`,`T_MODALITE_ID`)
UNIQUE KEY (`id_obs_mod`),
INDEX (`T_OBSERVATION_ID`,`T_DESCRIPTEUR_ID`,`session`,`T_MODALITE_ID`)
);

-- recarga total de la tabla th_obs_mod
REPLACE INTO `th_obs_mod`
(
    SELECT 
    A.`id_obs_mod`,
    A.`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    `T_DESCRIPTEUR_ID`,
    A.`session` as `session`,
    A.`T_MODALITE_ID` as`T_MODALITE_ID`,
    A.`date_debut` as `date_debut`,
    A.`date_fin` as `date_fin`,
    A.`id_enq` as `id_enq`,
    A.`Fecha_Modificacion` as `Fecha_Modificacion`,
    `CodeObservation`,
    `created`,
    `id_enqu`,
    `ObservationPublic`,
    `ObservationValide`,
    `verouiller`,
    A.`data_date` as `data_date`,
    @load_ts
    FROM  
    `ods_obs_mod` as A
    LEFT JOIN 
    `ods_modalite`
    ON A.`T_MODALITE_ID`=`ods_modalite`.`T_MODALITE_ID`
    LEFT JOIN 
    `ods_observation`
    ON A.`T_OBSERVATION_ID`=`ods_observation`.`T_OBSERVATION_ID`
    WHERE 
    `ods_observation`.`T_QUESTIONNAIRE_ID`=453 
    -- AND `ods_observation`.`ObservationValide`='true'
);



CREATE TABLE IF NOT EXISTS `th_prestaciones` (
`T_OBSERVATION_ID` int(11),
`CodeObservation` varchar(50) NULL,
`session` int(11) NULL,
`created` datetime NULL,
`id_enqu` int(11) NULL,
`ObservationPublic` varchar(10) NULL,
`ObservationValide` varchar(10) NULL,
`verouiller` binary(1),
`date_debut` datetime NULL,
`date_fin` datetime NULL, 
`cod_prest` int(11) NULL, -- WHERE [T_DESCRIPTEUR_ID]='9074'; // esa pregunta corresponde a una prestación
`cod_tiprog` int(11) NULL,
`cod_finprog` int(11) NULL,
`cod_convprog` int(11) NULL,
`cod_prov` int(11) NULL,
`cod_comu` int(11) NULL,
`Nombre Persona` longtext NULL,
`Primer Apellido` longtext NULL,
`Segundo Apellido` longtext NULL,
`cod_nacion` int(11) NULL,
`cod_paisnacim` int(11) NULL,
`cod_situadmin` int(11) NULL,
`cod_nivelstud` int(11) NULL,
`cod_genero` int(11) NULL,
`NIE` varchar(150) NULL,
`DNI` varchar(150) NULL,
`Pasaporte` varchar(150) NULL,
`Numero Asilo` varchar(150) NULL,
`Fecha Nacimiento` varchar(150) NULL,
`cod_solprotec` int(11) NULL,
`cod_inmi` int(11) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,   
UNIQUE KEY (`T_OBSERVATION_ID`,`session`,`cod_prest`)
);


REPLACE INTO `th_prestaciones`
(
    SELECT 
    A.`T_OBSERVATION_ID`,
    A.`CodeObservation`,
    A.`session`,
    A.`created`,
    A.`id_enqu`,
    A.`ObservationPublic`,
    A.`ObservationValide`,
    A.`verouiller`,
    A.`date_debut`,
    A.`date_fin`,
    A.`T_MODALITE_ID` as cod_prest,
    B.`T_MODALITE_ID` as cod_tiprog,
    C.`T_MODALITE_ID` as cod_finprog,
    D.`T_MODALITE_ID` as cod_convprog,
    E.`T_MODALITE_ID` as cod_prov,
    F.`T_MODALITE_ID` as cod_comu,
    DA.`valeur` as `Nombre Persona`,
    DB.`valeur` as `Primer Apellido`,
    DC.`valeur` as `Segundo Apellido`,
    G.`T_MODALITE_ID` as cod_nacion,
    H.`T_MODALITE_ID` as cod_paisnacim,
    I.`T_MODALITE_ID` as cod_situadmin,
    J.`T_MODALITE_ID` as cod_nivelstud,
    K.`T_MODALITE_ID` as cod_genero,
    DD.`valeur` as `NIE`,
    DE.`valeur` as `DNI`,
    DF.`valeur` as `Pasaporte`,
    DG.`valeur` as `Numero Asilo`,
    DH.`valeur` as `Fecha Nacimiento`,
    L.`T_MODALITE_ID` as cod_solprotec,
    M.`T_MODALITE_ID` as cod_inmi,
    A.`data_date`,
    @load_ts
    FROM  
    (SELECT 
    `T_OBSERVATION_ID`,
    `CodeObservation`,
    `session`,
    `created`,
    `id_enqu`,
    `ObservationPublic`,
    `ObservationValide`,
    `verouiller`,
    `date_debut`,
    `date_fin`,
    `T_MODALITE_ID`,
    `data_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=9074) as A
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8620) AS B
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8621) AS C
    ON A.`T_OBSERVATION_ID`=C.`T_OBSERVATION_ID`
    AND A.`session`=C.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=9109) AS D
    ON A.`T_OBSERVATION_ID`=D.`T_OBSERVATION_ID`
    AND A.`session`=D.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8945) AS E
    ON A.`T_OBSERVATION_ID`=E.`T_OBSERVATION_ID`
    AND A.`session`=E.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8947) AS F
    ON A.`T_OBSERVATION_ID`=F.`T_OBSERVATION_ID`
    AND A.`session`=F.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8593) AS G
    ON A.`T_OBSERVATION_ID`=G.`T_OBSERVATION_ID`
    AND A.`session`=G.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8592) AS H
    ON A.`T_OBSERVATION_ID`=H.`T_OBSERVATION_ID`
    AND A.`session`=H.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8610) AS I
    ON A.`T_OBSERVATION_ID`=I.`T_OBSERVATION_ID`
    AND A.`session`=I.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8619) AS J
    ON A.`T_OBSERVATION_ID`=J.`T_OBSERVATION_ID`
    AND A.`session`=J.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8590) AS K
    ON A.`T_OBSERVATION_ID`=K.`T_OBSERVATION_ID`
    AND A.`session`=K.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8611) AS L
    ON A.`T_OBSERVATION_ID`=L.`T_OBSERVATION_ID`
    AND A.`session`=L.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8612) AS M
    ON A.`T_OBSERVATION_ID`=M.`T_OBSERVATION_ID`
    AND A.`session`=M.`session`
    LEFT JOIN 
    `ods_obs_descript` AS DA
    ON A.`T_OBSERVATION_ID`=DA.`T_OBSERVATION_ID`
    AND A.`session`=DA.`session`
    AND DA.`T_DESCRIPTEUR_ID`=8582
    LEFT JOIN 
    `ods_obs_descript` AS DB
    ON A.`T_OBSERVATION_ID`=DB.`T_OBSERVATION_ID`
    AND A.`session`=DB.`session`
    AND DB.`T_DESCRIPTEUR_ID`=8583
    LEFT JOIN 
    `ods_obs_descript` AS DC
    ON A.`T_OBSERVATION_ID`=DC.`T_OBSERVATION_ID`
    AND A.`session`=DC.`session`
    AND DC.`T_DESCRIPTEUR_ID`=8584
    LEFT JOIN 
    `ods_obs_descript` AS DD
    ON A.`T_OBSERVATION_ID`=DD.`T_OBSERVATION_ID`
    AND A.`session`=DD.`session`
    AND DD.`T_DESCRIPTEUR_ID`=8586
    LEFT JOIN 
    `ods_obs_descript` AS DE
    ON A.`T_OBSERVATION_ID`=DE.`T_OBSERVATION_ID`
    AND A.`session`=DE.`session`
    AND DE.`T_DESCRIPTEUR_ID`=8588
    LEFT JOIN 
    `ods_obs_descript` AS DF
    ON A.`T_OBSERVATION_ID`=DF.`T_OBSERVATION_ID`
    AND A.`session`=DF.`session`
    AND DF.`T_DESCRIPTEUR_ID`=8587
    LEFT JOIN 
    `ods_obs_descript` AS DG
    ON A.`T_OBSERVATION_ID`=DG.`T_OBSERVATION_ID`
    AND A.`session`=DG.`session`
    AND DG.`T_DESCRIPTEUR_ID`=8585
    LEFT JOIN 
    `ods_obs_descript` AS DH
    ON A.`T_OBSERVATION_ID`=DH.`T_OBSERVATION_ID`
    AND A.`session`=DH.`session`
    AND DH.`T_DESCRIPTEUR_ID`=8591

);
/*
modalidad 9074  Prestación
modalidad	8620	Tipo de Programa
modalidad	8621	Financiación del Programa
modalidad	9109	Convocatoria del programa
modalidad	8945	Provincia
modalidad	8947	Comunidad
observación	8582	Nombre Persona
observación	8583	Primer Apellido
observación	8584	Segundo Apellido
modalidad	8593	Nacionalidad
modalidad	8592	Pais de Nacimiento
modalidad	8610	Situación administrativa
modalidad	8619	Nivel de estudios
modalidad	8590	Sexo
observación	8586	NIE
observación	8588	DNI
observación	8587	Pasaporte
observación	8585	Numero Asilo
observación	8591	Fecha Nacimiento
modalidad	8611	Solicitante de protección internacional
modalidad	8612	Inmigrante
*/


/*SELECT `T_OBSERVATION_ID`,`session`,`T_MODALITE_ID`,`date_debut`,`date_fin`,
    ANY_VALUE(`CodeObservation`),
    ANY_VALUE(`created`),
    ANY_VALUE(`id_enqu`)
    FROM `ods_obs_mod`
    LEFT JOIN 
    `ods_modalite`
    USING (`T_MODALITE_ID`)
    LEFT JOIN 
    `ods_observation`
    USING (`T_OBSERVATION_ID`)
    WHERE 
    `ods_modalite`.`T_DESCRIPTEUR_ID`=9074
    AND `ods_observation`.`T_QUESTIONNAIRE_ID`=453 
    AND `ods_observation`.`ObservationValide`='true'
    GROUP BY `T_OBSERVATION_ID`,`session`,`T_MODALITE_ID`,`date_debut`,`date_fin`
    LIMIT 100
    






(SELECT distinct(`T_OBSERVATION_ID`,`session`,`cod_prest`,`date_debut`,`date_fin`), `T_MODALITE_ID` as `cod_tiprog`
FROM `ods_obs_mod` WHERE `T_DESCRIPTEUR_ID`=8620)
USING (`T_OBSERVATION_ID`,`session`,`cod_prest`,`date_debut`,`date_fin`);
*/