
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_ts=NOW();
SET sql_mode='';


-- recarga incremental de la tabla th_obs_mod

REPLACE INTO `th_obs_mod`
(
    SELECT 
    `id_obs_mod`,
    `ods_obs_mod`.`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    `T_DESCRIPTEUR_ID`,
    `session`,
    `ods_obs_mod`.`T_MODALITE_ID` as`T_MODALITE_ID`,
    `date_debut`,
    `date_fin`,
    `id_enq`,
    `ods_obs_mod`.`Fecha_Modificacion` as `Fecha_Modificacion`,
    `CodeObservation`,
    `created`,
    `id_enqu`,
    `ObservationPublic`,
    `ObservationValide`,
    `verouiller`,
    `ods_obs_mod`.`data_date` as `data_date`,
    @load_ts
    FROM  
    `ods_obs_mod`
    LEFT JOIN 
    `ods_modalite` 
    ON `ods_obs_mod`.`T_MODALITE_ID`=`ods_modalite`.`T_MODALITE_ID`
    LEFT JOIN 
    `ods_observation`
    ON `ods_obs_mod`.`T_OBSERVATION_ID`=`ods_observation`.`T_OBSERVATION_ID`
    WHERE 
    `ods_observation`.`T_QUESTIONNAIRE_ID`=453  
    -- AND `ods_observation`.`ObservationValide`='true'
    AND `ods_obs_mod`.`data_date`>(SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `th_obs_mod`)
);

/*
modalidad   9074    Prestación
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

-- recarga incremental de la tabla th_prestaciones

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
    WHERE 
    `ods_obs_mod`.`data_date`>(SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `th_prestaciones`)
    AND `T_DESCRIPTEUR_ID`=9074) as A
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


-- recarga de las dimensiones

REPLACE INTO `td_prestacion`
(
    SELECT 
    A.`cod_prest`,
    B.`LibelleModalite` as `Prestación`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_prest`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=9074
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_prest`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_tipoprograma`
(
    SELECT 
    A.`cod_tiprog`,
    B.`LibelleModalite` as `Tipo de Programa`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_tiprog`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8620
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_tiprog`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_finprograma`
(
    SELECT 
    A.`cod_finprog`,
    B.`LibelleModalite` as `Financiación del Programa`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_finprog`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8621
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_finprog`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_convprograma`
(
    SELECT 
    A.`cod_convprog`,
    B.`LibelleModalite` as `Convocatoria del programa`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_convprog`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=9109
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_convprog`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_provincia`
(
    SELECT 
    A.`cod_prov`,
    B.`LibelleModalite` as `Provincia`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_prov`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8945
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_prov`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_comunidad`
(
    SELECT 
    A.`cod_comu`,
    B.`LibelleModalite` as `Comunidad`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_comu`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8947
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_comu`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_nacionalidad`
(
    SELECT 
    A.`cod_nacion`,
    B.`LibelleModalite` as `Nacionalidad`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_nacion`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8593
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_nacion`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_pais`
(
    SELECT 
    A.`cod_pais`,
    B.`LibelleModalite` as `Pais de Nacimiento`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_pais`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8592
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_pais`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_situadmin`
(
    SELECT 
    A.`cod_situadmin`,
    B.`LibelleModalite` as `Situación administrativa`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_situadmin`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8610
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_situadmin`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_nivelestud`
(
    SELECT 
    A.`cod_nivelstud`,
    B.`LibelleModalite` as `Nivel de estudios`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_nivelstud`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8619
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_nivelstud`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_genero`
(
    SELECT 
    A.`cod_genero`,
    B.`LibelleModalite` as `Sexo`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_genero`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8590
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_genero`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_solprotec`
(
    SELECT 
    A.`cod_solprotec`,
    B.`LibelleModalite` as `Solicitante de protección internacional`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_solprotec`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8611
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_solprotec`=B.`T_MODALITE_ID`
);

REPLACE INTO `td_inmigrante`
(
    SELECT 
    A.`cod_inmi`,
    B.`LibelleModalite` as `Inmigrante`,
    A.`data_date`,
    A.`load_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_inmi`,
    MAX(`data_date`) as `data_date`,
    @load_ts as `load_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8612
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_inmi`=B.`T_MODALITE_ID`
);



