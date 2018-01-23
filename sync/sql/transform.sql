
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_ts=NOW();
SET sql_mode='';

-- v_modalite_descripteur
-- Esa vista cruza ods_modalite y ods_descripteur para dar una visión completa de las preguntas y
-- modalidades de respuesta para el questionario 453.

-- recarga completa de la jerarquia de modalité -> descripteur -> descripteur padre 
REPLACE INTO `jer_modalite_descripteur`
(
    SELECT 
    A.`T_MODALITE_ID`,
    A.`CodeModalite`,  
    A.`LibelleModalite`, 
    A.`TypeModalite`,
    A.`RangModalite`,
    A.`T_DESCRIPTEUR_ID`, 
    A.`CodeDescripteur`,
    A.`LibelleDescripteur`,  
    A.`SautDescripteur`,
    A.`isSession`,
    B.`T_DESCRIPTEUR_ID` as id_descripteur_padre, 
    B.`CodeDescripteur` as code_descripteur_padre,
    B.`LibelleDescripteur` as libelle_descripteur_padre,
    A.`data_date`
    FROM `v_modalite_descripteur` A 
    LEFT JOIN `v_modalite_descripteur` B 
    ON A.`CodeModalitePadre`=B.`CodeModalite`
);

-- recarga incremental de la tabla th_obs_mod
REPLACE INTO `th_obs_mod`
(
    SELECT 
    `ods_obs_mod`.`id_obs_mod`,
    `ods_obs_mod`.`T_OBSERVATION_ID`,
    `jer_modalite_descripteur`.`T_DESCRIPTEUR_ID`,
    `ods_obs_mod`.`session`,
    `ods_obs_mod`.`T_MODALITE_ID`,
    `ods_obs_mod`.`date_debut`,
    `ods_obs_mod`.`date_fin`,
    `ods_obs_mod`.`id_enq`,
    `ods_obs_mod`.`Fecha_Modificacion`,
    `ods_observation`.`CodeObservation`,
    `ods_observation`.`created`,
    `ods_observation`.`id_enqu`,
    `jer_modalite_descripteur`.`TypeModalite`,
    `jer_modalite_descripteur`.`RangModalite`,
    `jer_modalite_descripteur`.`id_descripteur_padre`,
    `ods_obs_mod`.`data_date`
    FROM  `ods_obs_mod`
    JOIN `jer_modalite_descripteur` -- con ese JOIN conseguimos los campos adicionales y filtramos las respuestas "Sans Objet"
    ON `ods_obs_mod`.`T_MODALITE_ID`=`jer_modalite_descripteur`.`T_MODALITE_ID`     
    
    LEFT JOIN `ods_observation` -- con ese JOIN, conseguimos mas campos de los usuarios
    ON `ods_obs_mod`.`T_OBSERVATION_ID`=`ods_observation`.`T_OBSERVATION_ID` 
    
    WHERE `jer_modalite_descripteur`.RangModalite > 0 -- filtra todas las respuestas "Sans Objet" y "RxWO" o similares 
    AND `ods_obs_mod`.`data_date` > (SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `th_obs_mod`) 
);



/* A revisar:
8962	Programas en Loja:
9067	Nï¿½mero de horas de interpretaciï¿½n: 
9068	Nï¿½mero de hojas traducidas-Traducciï¿½n:
*/


SELECT @nacionalidad:=0;
SELECT @sitadmin:=0;
SELECT @solprotec:=0;
SELECT @inmigrante:=0;
SELECT @date_nacionalidad:=0;
SELECT @date_sitadmin:=0;
SELECT @date_solprotec:=0;
SELECT @date_inmigrante:=0;
SELECT @date_estudios:=0;
SELECT @estudios:=0;
SELECT @id:=0;

REPLACE INTO `th_hist_situacion_usuarios`
(
    SELECT 
    -- B.`date_debut` as `fecha_nacionalidad_`, -- util para validar los resultados
    -- B.`T_MODALITE_ID` as `nacionalidad_`,
    
    -- si la fecha es nula, usar la anterior. Si la fecha es superior a la anterior y misma nacionalidad, usar la anterior, sino usar la nueva fecha
    @date_nacionalidad := if(`T_OBSERVATION_ID`=@id, if( (`date_debut` IS NULL) || (`date_debut` > @date_nacionalidad && `T_MODALITE_ID` = @nacionalidad), @date_nacionalidad, `date_debut`), `date_debut`) as `fecha_nacionalidad`,
    -- si el usuario es el mismo (mismo T_OBSERVATION_ID): si la nacionalidad es nula, coger la anterior.
    @nacionalidad := if(`T_OBSERVATION_ID`=@id,ifnull(`T_MODALITE_ID`,@nacionalidad),`T_MODALITE_ID`) as `nacionalidad`,

    -- C.`date_debut` as `fecha_sitadmin_`,
    -- C.`T_MODALITE_ID` as `sitadmin_`,

    @date_sitadmin := if(`T_OBSERVATION_ID`=@id,if(`date_debut` IS NULL || (`date_debut` > @date_sitadmin && `T_MODALITE_ID` = @sitadmin), @date_sitadmin, `date_debut`), `date_debut`) as `fecha_sitadmin`,
    @sitadmin := if(`T_OBSERVATION_ID`=@id,ifnull(`T_MODALITE_ID`,@sitadmin),`T_MODALITE_ID`) as `sitadmin`,
    
    -- D.`date_debut` as `fecha_solprotec_`,
    -- D.`T_MODALITE_ID` as `solprotec_`,
 
    @date_solprotec := if(`T_OBSERVATION_ID`=@id,if(`date_debut` IS NULL || (`date_debut` > @date_solprotec && `T_MODALITE_ID` = @solprotec), @date_solprotec, `date_debut`), `date_debut`) as `fecha_solprotec`,
    @solprotec := if(`T_OBSERVATION_ID`=@id,ifnull(`T_MODALITE_ID`,@solprotec),`T_MODALITE_ID`) as `solprotec`,
    
    -- E.`date_debut` as `fecha_inmigrante_`,
    -- E.`T_MODALITE_ID` as `inmigrante_`,
    
    @date_inmigrante := if(`T_OBSERVATION_ID`=@id,if(`date_debut` IS NULL || (`date_debut` > @date_inmigrante && `T_MODALITE_ID` = @inmigrante), @date_inmigrante, `date_debut`), `date_debut`) as `fecha_inmigrante`,
    @inmigrante := if(`T_OBSERVATION_ID`=@id,ifnull(`T_MODALITE_ID`,@inmigrante),`T_MODALITE_ID`) as `inmigrante`,
    
    -- F.`date_debut` as `fecha_estudios_`,
    -- F.`T_MODALITE_ID` as `estudios_`,

    @date_estudios := if(`T_OBSERVATION_ID`=@id,if(`date_debut` IS NULL || (`date_debut` > @date_estudios && `T_MODALITE_ID` = @estudios), @date_estudios, `date_debut`), `date_debut`) as `fecha_estudios`,
    @estudios := if(`T_OBSERVATION_ID`=@id,ifnull(`T_MODALITE_ID`,@estudios),`T_MODALITE_ID`) as `estudios`,
    
    -- es importante dejar esa variable aqui para que al siguiente registro contenga el anterior T_OBSERVATION_ID
    @id:=`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    `CodeObservation`,
    `session`,
    `created`,
    `id_enqu`,
    `com_nacionalidad`,
    `com_sitadmin`,
    `com_solprotec`,
    `com_inmigrante`,
    `com_estudios`,
    `data_date`
    FROM v_hist_situsua_ori;
   


/*
Tipo pregunta   descripteur
observación 8603    Distrito
observación 8602    Municipio
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
observación 8577    Alta usuario
sitlegalinm 8612 
sitlegalprotecintl 8611
estudiossn  8322 -> no esta en quest 453
nivelestudios   8421 -> no esta en quest 453
nivelestudiosfinalizados  8619
situacionlaboral    8805
Asentamiento (alojamiento)    8956
paisnac     8592
estciv      9060
poseedoc    8912
tipodoc     8913
tsanitaria  8782
explabEspaña    8808      
seclab      8809 
hablaesp    8835
nivelesp    8836
convive01   
observation   9115 numero siria 

*/

-- recarga incremental de la tabla th_prestaciones
/*
REPLACE INTO `th_prestaciones`
(
    SELECT 
    A.`T_OBSERVATION_ID`,
    A.`CodeObservation`,
    A.`session`,
    A.`created`,
    A.`id_enqu`,
    A.`T_MODALITE_ID` as tipo_prest,
    B.`T_MODALITE_ID` as cod_prest,
    A.`date_debut` as    `date_debut`,
    A.`date_fin` as      `date_fin`,
    C.`T_MODALITE_ID` as tipo_prog,
    D.`T_MODALITE_ID` as fin_prog,
    E.`T_MODALITE_ID` as conv_prog,
    F.`T_MODALITE_ID` as prog_local,
    DA.`valeur` as `Nombre Persona`,
    DB.`valeur` as `Primer Apellido`,
    DC.`valeur` as `Segundo Apellido`,
    G.`T_MODALITE_ID` as cod_nacion,
    H.`T_MODALITE_ID` as cod_pais,
    K.`T_MODALITE_ID` as cod_genero,
    DD.`valeur` as `NIE`,
    DE.`valeur` as `DNI`,
    DF.`valeur` as `Pasaporte`,
    DG.`valeur` as `Numero Asilo`,
    DH.`valeur` as `Fecha Nacimiento`,
    I.`T_MODALITE_ID` as cod_situadmin,
    J.`T_MODALITE_ID` as cod_nivelstud,
    L.`T_MODALITE_ID` as cod_solprotec,
    M.`T_MODALITE_ID` as cod_inmi,
    A.`data_date`
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
    `data_date`>(SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `th_prestaciones`)
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
    AND DA.`T_DESCRIPTEUR_ID`=8582
    LEFT JOIN 
    `ods_obs_descript` AS DB
    ON A.`T_OBSERVATION_ID`=DB.`T_OBSERVATION_ID`
    AND DB.`T_DESCRIPTEUR_ID`=8583
    LEFT JOIN 
    `ods_obs_descript` AS DC
    ON A.`T_OBSERVATION_ID`=DC.`T_OBSERVATION_ID`
    AND DC.`T_DESCRIPTEUR_ID`=8584
    LEFT JOIN 
    `ods_obs_descript` AS DD
    ON A.`T_OBSERVATION_ID`=DD.`T_OBSERVATION_ID`
    AND DD.`T_DESCRIPTEUR_ID`=8586
    LEFT JOIN 
    `ods_obs_descript` AS DE
    ON A.`T_OBSERVATION_ID`=DE.`T_OBSERVATION_ID`
    AND DE.`T_DESCRIPTEUR_ID`=8588
    LEFT JOIN 
    `ods_obs_descript` AS DF
    ON A.`T_OBSERVATION_ID`=DF.`T_OBSERVATION_ID`
    AND DF.`T_DESCRIPTEUR_ID`=8587
    LEFT JOIN 
    `ods_obs_descript` AS DG
    ON A.`T_OBSERVATION_ID`=DG.`T_OBSERVATION_ID`
    AND DG.`T_DESCRIPTEUR_ID`=8585
    LEFT JOIN 
    `ods_obs_descript` AS DH
    ON A.`T_OBSERVATION_ID`=DH.`T_OBSERVATION_ID`
    AND DH.`T_DESCRIPTEUR_ID`=8591
);


-- recarga de las dimensiones

REPLACE INTO `td_prestacion`
(
    SELECT 
    A.`cod_prest`,
    B.`LibelleModalite` as `Prestación`,
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_prest`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_tiprog`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_finprog`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_convprog`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_prov`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_comu`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_nacion`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_pais`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_situadmin`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_nivelstud`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_genero`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_solprotec`,
    MAX(`data_date`) as `data_date`
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
    A.`data_date`
    FROM
    (SELECT 
    `T_DESCRIPTEUR_ID`,
    `T_MODALITE_ID` as `cod_inmi`,
    MAX(`data_date`) as `data_date`
    FROM 
    `th_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8612
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_inmi`=B.`T_MODALITE_ID`
);

*/

