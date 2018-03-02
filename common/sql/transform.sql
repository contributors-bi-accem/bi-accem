
SET @ts_format='%Y-%m-%d %H:%i:%S';
SET @date_format='%Y-%m-%d';
SET @load_date=NOW();
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
    A.`data_date`,
    @load_date as `load_date`
    FROM `v_modalite_descripteur` A 
    LEFT JOIN `v_modalite_descripteur` B 
    ON A.`CodeModalitePadre`=B.`CodeModalite`
);


REPLACE INTO `temp_obs_descript`
(
    SELECT 
    `T_OBSERVATION_ID`,
    `T_DESCRIPTEUR_ID`,
    `session`,
    `id_enqu`,
    `Fecha_Modificacion`,
    CASE 
        WHEN `T_DESCRIPTEUR_ID` IN (8578)  THEN upper(if(length(trim(`Valeur`))>147,concat(left(trim(`Valeur`),147),'...'),trim(`Valeur`)))
        -- ,8592,8593,8601,8602,8603,8604,8598
        ELSE if(length(trim(`Valeur`))>147,concat(left(trim(`Valeur`),147),'...'),trim(`Valeur`))
    END as `Valeur`,
    CASE 
        WHEN  `T_DESCRIPTEUR_ID` IN (8613,8591)  THEN str_to_date(trim(`Valeur`),'%d-%m-%Y')
    END as `FechaValor`,
    `data_date`,
    @load_date as `load_date`
    FROM  `ods_obs_descript`
    WHERE length(trim(`Valeur`)) > 0 -- filtra las respuestas vacias
    AND `ods_obs_descript`.`data_date` > (SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `temp_obs_descript`) 
);



-- recarga incremental de la tabla temp_obs_mod
REPLACE INTO `temp_obs_mod`
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
    `ods_obs_mod`.`data_date`,
    @load_date as `load_date`
    FROM  `ods_obs_mod`
    JOIN `jer_modalite_descripteur` -- con ese JOIN conseguimos los campos adicionales y filtramos las respuestas "Sans Objet"
    ON `ods_obs_mod`.`T_MODALITE_ID`=`jer_modalite_descripteur`.`T_MODALITE_ID`     
    
    LEFT JOIN `ods_observation` -- con ese JOIN, conseguimos mas campos de los usuarios
    ON `ods_obs_mod`.`T_OBSERVATION_ID`=`ods_observation`.`T_OBSERVATION_ID` 
    
    WHERE `jer_modalite_descripteur`.`RangModalite` > 0 -- filtra todas las respuestas "Sans Objet" y "RxWO" o similares 
    AND `ods_obs_mod`.`data_date` > (SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `temp_obs_mod`) 
);

/*
REPLACE INTO `temp_hist_situsua`
( SELECT 
    A.`T_OBSERVATION_ID`,
    A.`CodeObservation`,
    A.`session`,
    A.`created`,
    A.`id_enqu`,
    B.`date_debut` as `fecha_nacionalidad`,
    B.`T_MODALITE_ID` as `nacionalidad`,
    C.`date_debut` as `fecha_sitadmin`,
    C.`T_MODALITE_ID` as `sitadmin`,
    D.`date_debut` as `fecha_solprotec`,
    D.`T_MODALITE_ID` as `solprotec`,
    E.`date_debut` as `fecha_inmigrante`,
    E.`T_MODALITE_ID` as `inmigrante`,
    F.`date_debut` as `fecha_estudios`,
    F.`T_MODALITE_ID` as `estudios`,
    G.`valeur` as `com_nacionalidad`,
    H.`valeur` as `com_sitadmin`,
    I.`valeur` as `com_solprotec`,
    J.`valeur` as `com_inmigrante`,
    K.`valeur` as `com_estudios`,
    A.`data_date`
    FROM
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    max(`CodeObservation`) as `CodeObservation`,
    max(`created`) as `created`,
    max(`id_enqu`) as `id_enqu`,
    max(`data_date`) as `data_date`
    FROM 
    `temp_obs_mod`
    WHERE 
    `data_date`>(SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `th_hist_situacion_usuarios`)
    GROUP BY `T_OBSERVATION_ID`,`session`    
    ORDER BY  `T_OBSERVATION_ID` asc,`session` desc) as A
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `date_debut`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8593) AS B -- Nacionalidad
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `date_debut`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8610) AS C -- Situación administrativa
    ON A.`T_OBSERVATION_ID`=C.`T_OBSERVATION_ID`
    AND A.`session`=C.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `date_debut`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8611) AS D -- Solicitante de protección internacional
    ON A.`T_OBSERVATION_ID`=D.`T_OBSERVATION_ID`
    AND A.`session`=D.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `date_debut`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8612) AS E -- Inmigrante
    ON A.`T_OBSERVATION_ID`=E.`T_OBSERVATION_ID`
    AND A.`session`=E.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `date_debut`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8619) AS F -- Estudios finalizados
    ON A.`T_OBSERVATION_ID`=F.`T_OBSERVATION_ID`
    AND A.`session`=F.`session`
    -- y añadimos los eventuales comentarios en cada momento
    LEFT JOIN 
    `ods_obs_descript` AS G
    ON A.`T_OBSERVATION_ID`=G.`T_OBSERVATION_ID`
    AND A.`session`=G.`session`
    AND G.`T_DESCRIPTEUR_ID`=8593
    LEFT JOIN 
    `ods_obs_descript` AS H
    ON A.`T_OBSERVATION_ID`=H.`T_OBSERVATION_ID`
    AND A.`session`=H.`session`
    AND H.`T_DESCRIPTEUR_ID`=8610
    LEFT JOIN 
    `ods_obs_descript` AS I
    ON A.`T_OBSERVATION_ID`=I.`T_OBSERVATION_ID`
    AND A.`session`=I.`session`
    AND I.`T_DESCRIPTEUR_ID`=8611
    LEFT JOIN 
    `ods_obs_descript` AS J
    ON A.`T_OBSERVATION_ID`=J.`T_OBSERVATION_ID`
    AND A.`session`=J.`session`
    AND J.`T_DESCRIPTEUR_ID`=8612
    LEFT JOIN
    `ods_obs_descript` AS K
    ON A.`T_OBSERVATION_ID`=K.`T_OBSERVATION_ID`
    AND A.`session`=K.`session`
    AND K.`T_DESCRIPTEUR_ID`=8619
);
*/


SELECT @fecha_fin:=0;
SELECT @fecha_inicio:=0;
SELECT @id:=0;
REPLACE INTO `th_hist_nacionalidad`
(
    SELECT
    -- si el usuario es el mismo (mismo T_OBSERVATION_ID): si la nacionalidad es nula, coger la anterior.
    @fecha_fin := if(T.`T_OBSERVATION_ID`<>@id,'9999-12-31 23:59:59',@fecha_inicio) as `fecha_fin`,
    @fecha_inicio := T.`date_debut` as `fecha_inicio`,
    T.`T_MODALITE_ID` as `nacionalidad`,
    T.`valeur` as `comentario`,
    @id:=T.`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    T.`session` as `session`,
    T.`data_date` as `data_date`,
    @load_date as `load_date`
    FROM
    (SELECT 
    A.`T_OBSERVATION_ID`,
    A.`session`,
    A.`date_debut`,
    A.`T_MODALITE_ID`,
    A.`data_date`,
    B.`Valeur`
    FROM `temp_obs_mod` A
    LEFT JOIN -- y añadimos los eventuales comentarios en cada momento
    `ods_obs_descript` B
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    AND A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    WHERE A.`T_DESCRIPTEUR_ID`=8593 -- Nacionalidad
    ORDER BY A.`T_OBSERVATION_ID` asc, A.`session` desc -- muy importante por session descendiente
    ) T
);

-- lo mismo para el historico de situación administrativa
SELECT @fecha_fin:=0;
SELECT @fecha_inicio:=0;
SELECT @id:=0;
REPLACE INTO `th_hist_sitadmin`
(
    SELECT
    @fecha_fin := if(T.`T_OBSERVATION_ID`<>@id,'9999-12-31 23:59:59',@fecha_inicio) as `fecha_fin`,
    @fecha_inicio := T.`date_debut` as `fecha_inicio`,
    T.`T_MODALITE_ID` as `sitadmin`,
    T.`valeur` as `comentario`,
    @id:=T.`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    T.`session` as `session`,
    T.`data_date` as `data_date`,
    @load_date as `load_date`
    FROM
    (SELECT 
    A.`T_OBSERVATION_ID`,
    A.`session`,
    A.`date_debut`,
    A.`T_MODALITE_ID`,
    A.`data_date`,
    B.`Valeur`
    FROM `temp_obs_mod` A
    LEFT JOIN -- y añadimos los eventuales comentarios en cada momento
    `ods_obs_descript` B
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    AND A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    WHERE A.`T_DESCRIPTEUR_ID`=8610 -- Situación administrativa
    ORDER BY A.`T_OBSERVATION_ID` asc, A.`session` desc -- muy importante por session descendiente
    ) T
);

-- lo mismo para Solicitante de protección internacional
SELECT @fecha_fin:=0;
SELECT @fecha_inicio:=0;
SELECT @id:=0;
REPLACE INTO `th_hist_solprotec`
(
    SELECT
     @fecha_fin := if(T.`T_OBSERVATION_ID`<>@id,'9999-12-31 23:59:59',@fecha_inicio) as `fecha_fin`,
    @fecha_inicio := T.`date_debut` as `fecha_inicio`,
    T.`T_MODALITE_ID` as `solprotec`,
    T.`valeur` as `comentario`,
    @id:=T.`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    T.`session` as `session`,
    T.`data_date` as `data_date`,
    @load_date as `load_date`
    FROM
    (SELECT 
    A.`T_OBSERVATION_ID`,
    A.`session`,
    A.`date_debut`,
    A.`T_MODALITE_ID`,
    A.`data_date`,
    B.`Valeur`
    FROM `temp_obs_mod` A
    LEFT JOIN
    `ods_obs_descript` B
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    AND A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    WHERE A.`T_DESCRIPTEUR_ID`=8611 -- Solicitante de protección internacional
    ORDER BY A.`T_OBSERVATION_ID` asc, A.`session` desc -- muy importante por session descendiente
    ) T
);


-- lo mismo para inmigrante
SELECT @fecha_fin:=0;
SELECT @fecha_inicio:=0;
SELECT @id:=0;
REPLACE INTO `th_hist_inmigrante`
(
    SELECT
    @fecha_fin := if(T.`T_OBSERVATION_ID`<>@id,'9999-12-31 23:59:59',@fecha_inicio) as `fecha_fin`,
    @fecha_inicio := T.`date_debut` as `fecha_inicio`,
    T.`T_MODALITE_ID` as `inmigrante`,
    T.`valeur` as `comentario`,
    @id:=T.`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    T.`session` as `session`,
    T.`data_date` as `data_date`,
    @load_date as `load_date`
    FROM
    (SELECT 
    A.`T_OBSERVATION_ID`,
    A.`session`,
    A.`date_debut`,
    A.`T_MODALITE_ID`,
    A.`data_date`,
    B.`Valeur`
    FROM `temp_obs_mod` A
    LEFT JOIN
    `ods_obs_descript` B
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    AND A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    WHERE A.`T_DESCRIPTEUR_ID`=8612 -- Inmigrante
    ORDER BY A.`T_OBSERVATION_ID` asc, A.`session` desc -- muy importante por session descendiente
    ) T
);

SELECT @fecha_fin:=0;
SELECT @fecha_inicio:=0;
SELECT @id:=0;
REPLACE INTO `th_hist_estudios`
(
    SELECT
    @fecha_fin := if(T.`T_OBSERVATION_ID`=@id,'9999-12-31',@fecha_inicio) as `fecha_fin`,
    @fecha_inicio := T.`date_debut` as `fecha_inicio`,
    T.`T_MODALITE_ID` as `estudios`,
    T.`valeur` as `comentario`,
    @id:=T.`T_OBSERVATION_ID` as `T_OBSERVATION_ID`,
    T.`session` as `session`,
    T.`data_date` as `data_date`,
    @load_date as `load_date`
    FROM
    (SELECT 
    A.`T_OBSERVATION_ID`,
    A.`session`,
    A.`date_debut`,
    A.`T_MODALITE_ID`,
    A.`data_date`,
    B.`Valeur`
    FROM `temp_obs_mod` A
    LEFT JOIN
    `ods_obs_descript` B
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    AND A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    WHERE A.`T_DESCRIPTEUR_ID`=8619 -- Estudios finalizados
    ORDER BY A.`T_OBSERVATION_ID` asc, A.`session` desc -- muy importante por session descendiente
    ) T
);

/* A revisar:
8962	Programas en Loja:
9067	Nï¿½mero de horas de interpretaciï¿½n: 
9068	Nï¿½mero de hojas traducidas-Traducciï¿½n:
*/

/*
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
    @date_nacionalidad := if(`T_OBSERVATION_ID`=@id, if( (`fecha_nacionalidad` IS NULL) || (`fecha_nacionalidad` > @date_nacionalidad && `nacionalidad` = @nacionalidad), @date_nacionalidad, `fecha_nacionalidad`), `fecha_nacionalidad`) as `fecha_nacionalidad`,
    -- si el usuario es el mismo (mismo T_OBSERVATION_ID): si la nacionalidad es nula, coger la anterior.
    @nacionalidad := if(`T_OBSERVATION_ID`=@id,ifnull(`nacionalidad`,@nacionalidad),`nacionalidad`) as `nacionalidad`,

    -- C.`date_debut` as `fecha_sitadmin_`,
    -- C.`T_MODALITE_ID` as `sitadmin_`,

    @date_sitadmin := if(`T_OBSERVATION_ID`=@id,if(`fecha_sitadmin` IS NULL || (`fecha_sitadmin` > @date_sitadmin && `sitadmin` = @sitadmin), @date_sitadmin, `fecha_sitadmin`), `fecha_sitadmin`) as `fecha_sitadmin`,
    @sitadmin := if(`T_OBSERVATION_ID`=@id,ifnull(`sitadmin`,@sitadmin),`sitadmin`) as `sitadmin`,
    
    -- D.`date_debut` as `fecha_solprotec_`,
    -- D.`T_MODALITE_ID` as `solprotec_`,
 
    @date_solprotec := if(`T_OBSERVATION_ID`=@id,if(`fecha_solprotec` IS NULL || (`fecha_solprotec` > @date_solprotec && `solprotec` = @solprotec), @date_solprotec, `fecha_solprotec`), `fecha_solprotec`) as `fecha_solprotec`,
    @solprotec := if(`T_OBSERVATION_ID`=@id,ifnull(`solprotec`,@solprotec),`solprotec`) as `solprotec`,
    
    -- E.`date_debut` as `fecha_inmigrante_`,
    -- E.`T_MODALITE_ID` as `inmigrante_`,
    
    @date_inmigrante := if(`T_OBSERVATION_ID`=@id,if(`fecha_inmigrante` IS NULL || (`fecha_inmigrante` > @date_inmigrante && `inmigrante` = @inmigrante), @date_inmigrante, `fecha_inmigrante`), `fecha_inmigrante`) as `fecha_inmigrante`,
    @inmigrante := if(`T_OBSERVATION_ID`=@id,ifnull(`inmigrante`,@inmigrante),`inmigrante`) as `inmigrante`,
    
    -- F.`date_debut` as `fecha_estudios_`,
    -- F.`T_MODALITE_ID` as `estudios_`,

    @date_estudios := if(`T_OBSERVATION_ID`=@id,if(`fecha_estudios` IS NULL || (`fecha_estudios` > @date_estudios && `estudios` = @estudios), @date_estudios, `fecha_estudios`), `fecha_estudios`) as `fecha_estudios`,
    @estudios := if(`T_OBSERVATION_ID`=@id,ifnull(`estudios`,@estudios),`estudios`) as `estudios`,
    
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
    FROM temp_hist_situsua
    );
   
*/

/*

Tipo pregunta   descripteur
observación 8578    Entidad
modalidad   8819    Quien le ha derivado a Accem?
observación 8602    Municipio
observación 8603    Distrito
observación 8597    Codigo Postal
observación	8582	Nombre Persona
observación	8583	Primer Apellido
observación	8584	Segundo Apellido    
modalidad	8592	Pais de Nacimiento
modalidad	8590	Genero
observación	8586	NIE
observación	8588	DNI
observación	8587	Pasaporte
observación	8585	Numero Asilo
observation 9115    numero siria
observation 8918    numero solicitud apatridia
observation 8585    bumero de solicitud protección intl
observación	8591	Fecha Nacimiento
observación 8577    Alta usuario
--------
    modalidad	8593	Nacionalidad
    modalidad   8610    Situación administrativa
    modalidad	8611	Solicitante de protección internacional
    modalidad	8612	Inmigrante
    modalidad   8619    Nivel Estudios finalizados    
-------- 

modalidad   8805    situacionlaboral
Asentamiento (alojamiento)  8956

modalidad   9060    Estado civil
poseedoc    8912
tipodoc     8913
modalidad   8782    tarjeta sanitaria

modalidad   8790    Es hispanohablante
modalidad   8810    Busca actividad laboral
modalidad   8958    Con quien convive?

modalidad   8617    ¿Con Quien?

modalidad   8808    experiencia laboral en España      
modalidad   8809    en que sector

modalidad   8835    ¿habla castellano?
modalidad   8836    ¿con que nivel?
convive01   
observación 8613    Fecha entrada en españa

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
    A.`Succursale`,
    A.`date_debut`,
    A.`date_fin`,
    A.`periodicidad`,

    -- depende de la sesión
    B.`T_MODALITE_ID`   as `tipo_prest`,
    A.`T_MODALITE_ID`   as `cod_prest`,
    C.`T_MODALITE_ID`   as `tipo_prog`,
    D.`T_MODALITE_ID`   as `fin_prog`,
    E.`T_MODALITE_ID`   as `conv_prog`,
    F.`T_MODALITE_ID`   as `prog_local`,
    -- --------------------

    AA.`valeur`         as `Nombre Persona`,
    AB.`valeur`         as `Primer Apellido`,
    AC.`valeur`         as `Segundo Apellido`,
    AD.`valeur`         as `NIE`,
    AE.`valeur`         as `DNI`,
    AF.`valeur`         as `Pasaporte`,
    AG.`valeur`         as `Numero Asilo`,
    AH.`valeur`         as `Numero siria`,
    AI.`valeur`         as `Numero solicitud Apatridia`,
    AJ.`FechaValor`     as `Fecha Nacimiento`,
    AK.`FechaValor`     as `Fecha Entrada España`,
    
    L.`T_MODALITE_ID`   as `cod_pais`,
    M.`T_MODALITE_ID`   as `cod_genero`,
    N.`T_MODALITE_ID`   as `estaciv`,
    P.`T_MODALITE_ID`   as `poseedoc`,

    -- depende de la sesión
    BA.`T_MODALITE_ID`  as `nacionalidad`,
    BB.`T_MODALITE_ID`  as `situadmin`,
    BC.`T_MODALITE_ID`  as `solprotec`,
    BD.`T_MODALITE_ID`  as `inmigrante`,
    BE.`T_MODALITE_ID`  as `nivelstud`,
    -- ----------------------

    IF(BL.`vuln_menores`,true,false),
    IF(BM.`vuln_menorsinacop`,true,false),
    IF(BN.`vuln_edad`,true,false),
    IF(BO.`vuln_embarazada`,true,false),
    IF(BP.`vuln_monoparental`,true,false),
    IF(BQ.`vuln_trata`,true,false),
    IF(BR.`vuln_enferma`,true,false),
    IF(BS.`vuln_tratorno`,true,false),
    IF(BT.`vuln_tortura`,true,false),
    IF(BU.`vuln_genero`,true,false),
    IF(BV.`vuln_sinhogar`,true,false),
    IF(BW.`vuln_otro`,true,false),
    
    IF(DA.`doc_nie`,true,false),
    IF(DB.`doc_solprotec`,true,false),
    IF(DC.`doc_dni`,true,false),
    IF(DD.`doc_pasaporte`,true,false),
    IF(DE.`doc_solapatri`,true,false),
    IF(DF.`doc_otro`,true,false),
    IF(DG.`doc_siria`,true,false),
    
    A.`data_date`,
    @load_date as `load_date`
    FROM  
    (SELECT 
    `T_OBSERVATION_ID`,
    `CodeObservation`,
    `session`,
    `created`,
    `id_enqu`,
    `date_debut`,
    CASE 
        WHEN `typeModalite`=`sUnique`   THEN `date_debut`
        WHEN `typeModalite`=`sUnique01` THEN `date_fin`
        ELSE `date_fin`
    END                 as `date_fin`,
    CASE 
        WHEN `typeModalite`=`sUnique`   THEN `Puntual`
        WHEN `typeModalite`=`sUnique01` THEN `Periodica`
        ELSE ``
    END                 as `periodicidad`,
    `T_MODALITE_ID`,
    `data_date`
    FROM 
    `temp_obs_mod`, `v_jer_prestaciones`
    WHERE 
    `data_date`>(SELECT IFNULL(max(`data_date`),'01-01-0001 00:00:00') FROM `th_prestaciones`)
    AND `temp_obs_mod`.`T_DESCRIPTEUR_ID`=`v_jer_prestaciones`.`descripteur_nivel2`) as A -- prestaciones
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`, `v_jer_prestaciones`
    WHERE `temp_obs_mod`.`T_DESCRIPTEUR_ID`=`v_jer_prestaciones`.`descripteur_nivel1`) AS B -- un tipo de prestación
    ON A.`T_OBSERVATION_ID`=B.`T_OBSERVATION_ID`
    AND A.`session`=B.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`, `v_jer_programas`
    WHERE `temp_obs_mod`.`T_DESCRIPTEUR_ID`=`v_jer_programas`.`descripteur_nivel1`) AS C -- nivel 1 programas
    ON A.`T_OBSERVATION_ID`=C.`T_OBSERVATION_ID`
    AND A.`session`=C.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`, `v_jer_programas`
    WHERE `temp_obs_mod`.`T_DESCRIPTEUR_ID`=`v_jer_programas`.`descripteur_nivel2`) AS D -- nivel 2 programas
    ON A.`T_OBSERVATION_ID`=D.`T_OBSERVATION_ID`
    AND A.`session`=D.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`, `v_jer_programas`
    WHERE `temp_obs_mod`.`T_DESCRIPTEUR_ID`=`v_jer_programas`.`descripteur_nivel3`) AS E -- nivel 3 programas
    ON A.`T_OBSERVATION_ID`=E.`T_OBSERVATION_ID`
    AND A.`session`=E.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`, `v_jer_programas`
    WHERE `temp_obs_mod`.`T_DESCRIPTEUR_ID`=`v_jer_programas`.`descripteur_nivel4`) AS F -- nivel 4 programas
    ON A.`T_OBSERVATION_ID`=F.`T_OBSERVATION_ID`
    AND A.`session`=F.`session`

    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8592 -- pais de nacimiento
    AND `session` <= A.`session`
    ORDER BY `session` DESC
    LIMIT 1
    ) AS L 
    ON A.`T_OBSERVATION_ID`=L.`T_OBSERVATION_ID`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8590) AS M -- genero
    ON A.`T_OBSERVATION_ID`=M.`T_OBSERVATION_ID`
    AND A.`session`=M.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=9060) AS N -- estado civil
    ON A.`T_OBSERVATION_ID`=N.`T_OBSERVATION_ID`
    AND A.`session`=N.`session`
    
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8912) AS P -- posee documentación
    ON A.`T_OBSERVATION_ID`=O.`T_OBSERVATION_ID`
    AND A.`session`=O.`session`
    
    -- preguntas sujetas a sesiones: se filtran por fecha. Pueden originar varios registros si por ejemplo
    --    hay varias situaciones administrativas en el periodo de la prestación
    LEFT JOIN 
    (SELECT
    `nacionalidad`,
    `T_OBSERVATION_ID`
    FROM th_hist_nacionalidad
    WHERE `fecha_inicio` < A.`date_fin` 
    AND `fecha_fin` >= A.`date_debut`
    ) AS V
    ON A.`T_OBSERVATION_ID`=V.`T_OBSERVATION_ID`
    LEFT JOIN 
    (SELECT
    `sitadmin`,
    `T_OBSERVATION_ID`
    FROM th_hist_sitadmin
    WHERE `fecha_inicio` < A.`date_fin` 
    AND `fecha_fin` >= A.`date_debut`
    ) AS W
    ON A.`T_OBSERVATION_ID`=W.`T_OBSERVATION_ID`
    LEFT JOIN 
    (SELECT
    `sitadmin`,
    `T_OBSERVATION_ID`
    FROM th_hist_solprotec
    WHERE `fecha_inicio` < A.`date_fin` 
    AND `fecha_fin` >= A.`date_debut`
    ) AS X
    ON A.`T_OBSERVATION_ID`=X.`T_OBSERVATION_ID`
    LEFT JOIN
    (SELECT
    `inmigrante`,
    `T_OBSERVATION_ID`
    FROM th_hist_inmigrante
    WHERE `fecha_inicio` < A.`date_fin` 
    AND `fecha_fin` >= A.`date_debut`
    ) AS Y
    ON A.`T_OBSERVATION_ID`=Y.`T_OBSERVATION_ID`
    LEFT JOIN
    (SELECT
    `estudios`,
    `T_OBSERVATION_ID`
    FROM th_hist_estudios
    WHERE `fecha_inicio` < A.`date_fin` 
    AND `fecha_fin` >= A.`date_debut`
    ) AS Z
    ON A.`T_OBSERVATION_ID`=Z.`T_OBSERVATION_ID`
    -- preguntas de tipo unique -> puede haber varias respuestas a la pregunta.

    -- ¿Se encuentra en grupo vulnerable?
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87275) AS BL -- Menores
    ON A.`T_OBSERVATION_ID`=BL.`T_OBSERVATION_ID`
    AND A.`session`=BL.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87276) AS BM -- Menores no acompañados
    ON A.`T_OBSERVATION_ID`=BM.`T_OBSERVATION_ID`
    AND A.`session`=BM.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87277) AS BN -- edad avanzada
    ON A.`T_OBSERVATION_ID`=BN.`T_OBSERVATION_ID`
    AND A.`session`=BN.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87278) AS BO -- mujer embarazada
    ON A.`T_OBSERVATION_ID`=BO.`T_OBSERVATION_ID`
    AND A.`session`=BO.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87279) AS BP -- familia monoparental con hijos menores
    ON A.`T_OBSERVATION_ID`=BP.`T_OBSERVATION_ID`
    AND A.`session`=BP.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87280) AS BQ -- victima de trata
    ON A.`T_OBSERVATION_ID`=BQ.`T_OBSERVATION_ID`
    AND A.`session`=BQ.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87281) AS BR -- persona con enfermedad grave
    ON A.`T_OBSERVATION_ID`=BR.`T_OBSERVATION_ID`
    AND A.`session`=BR.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87282) AS BS -- persona con trastorno psiciatrico
    ON A.`T_OBSERVATION_ID`=BS.`T_OBSERVATION_ID`
    AND A.`session`=BS.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87283) AS BT -- persona torturada o violada
    ON A.`T_OBSERVATION_ID`=BT.`T_OBSERVATION_ID`
    AND A.`session`=BT.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87284) AS BU -- victima violencia de genero
    ON A.`T_OBSERVATION_ID`=BU.`T_OBSERVATION_ID`
    AND A.`session`=BU.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87285) AS BV -- sin hogar
    ON A.`T_OBSERVATION_ID`=BV.`T_OBSERVATION_ID`
    AND A.`session`=BV.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87286) AS BW -- otro
    ON A.`T_OBSERVATION_ID`=BW.`T_OBSERVATION_ID`
    AND A.`session`=BW.`session`

    

    -- ¿que tipo de documentación?
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84366) AS DA -- NIE
    ON A.`T_OBSERVATION_ID`=DA.`T_OBSERVATION_ID`
    AND A.`session`=DA.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84367) AS DB -- Solicitud prot internacional
    ON A.`T_OBSERVATION_ID`=DB.`T_OBSERVATION_ID`
    AND A.`session`=DB.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84368) AS DC -- DNI
    ON A.`T_OBSERVATION_ID`=DC.`T_OBSERVATION_ID`
    AND A.`session`=DC.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84369) AS DD -- pasaporte
    ON A.`T_OBSERVATION_ID`=DD.`T_OBSERVATION_ID`
    AND A.`session`=DD.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84370) AS DE -- solicitud apatridia
    ON A.`T_OBSERVATION_ID`=DE.`T_OBSERVATION_ID`
    AND A.`session`=DE.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84371) AS DF -- otros 
    ON A.`T_OBSERVATION_ID`=DF.`T_OBSERVATION_ID`
    AND A.`session`=DF.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=87255) AS DG -- numero siria 
    ON A.`T_OBSERVATION_ID`=DG.`T_OBSERVATION_ID`
    AND A.`session`=DG.`session`


    -- observaciones
    LEFT JOIN 
    `ods_obs_descript` AS AA
    ON A.`T_OBSERVATION_ID`=AA.`T_OBSERVATION_ID`
    AND AA.`T_DESCRIPTEUR_ID`=8582  -- nombre persona
    LEFT JOIN 
    `ods_obs_descript` AS AB
    ON A.`T_OBSERVATION_ID`=AB.`T_OBSERVATION_ID`
    AND AB.`T_DESCRIPTEUR_ID`=8583  -- primer apellido
    LEFT JOIN 
    `ods_obs_descript` AS AC
    ON A.`T_OBSERVATION_ID`=AC.`T_OBSERVATION_ID`
    AND AC.`T_DESCRIPTEUR_ID`=8584  -- segundo apellido
    LEFT JOIN 
    `ods_obs_descript` AS AD
    ON A.`T_OBSERVATION_ID`=AD.`T_OBSERVATION_ID`
    AND AD.`T_DESCRIPTEUR_ID`=8586  -- NIE
    LEFT JOIN 
    `ods_obs_descript` AS AE
    ON A.`T_OBSERVATION_ID`=AE.`T_OBSERVATION_ID`
    AND AE.`T_DESCRIPTEUR_ID`=8588  -- DNI 
    LEFT JOIN 
    `ods_obs_descript` AS AF
    ON A.`T_OBSERVATION_ID`=AF.`T_OBSERVATION_ID`
    AND AF.`T_DESCRIPTEUR_ID`=8587  -- Pasaporte
    LEFT JOIN 
    `ods_obs_descript` AS AG
    ON A.`T_OBSERVATION_ID`=AG.`T_OBSERVATION_ID`
    AND AG.`T_DESCRIPTEUR_ID`=8585  -- numero asilo
    LEFT JOIN 
    `ods_obs_descript` AS AH
    ON A.`T_OBSERVATION_ID`=AH.`T_OBSERVATION_ID`
    AND AH.`T_DESCRIPTEUR_ID`=9115  -- numero siria
    LEFT JOIN 
    `ods_obs_descript` AS AI
    ON A.`T_OBSERVATION_ID`=AI.`T_OBSERVATION_ID`
    AND AI.`T_DESCRIPTEUR_ID`=8918  -- numero solicitud apatridia
    LEFT JOIN 
    `ods_obs_descript` AS AJ
    ON A.`T_OBSERVATION_ID`=AJ.`T_OBSERVATION_ID`
    AND AJ.`T_DESCRIPTEUR_ID`=8591  -- Fecha Nacimiento
    LEFT JOIN 
    `ods_obs_descript` AS AK
    ON A.`T_OBSERVATION_ID`=AK.`T_OBSERVATION_ID`
    AND AK.`T_DESCRIPTEUR_ID`=8613  -- Fecha entrada España
);

/*
REPLACE INTO `th_detalle_usuarios`
(
    AA.`valeur`         as `Nombre Persona`,
    AB.`valeur`         as `Primer Apellido`,
    AC.`valeur`         as `Segundo Apellido`,
    AD.`valeur`         as `NIE`,
    AE.`valeur`         as `DNI`,
    AF.`valeur`         as `Pasaporte`,
    AG.`valeur`         as `Numero Asilo`,
    AH.`valeur`         as `Numero siria`,
    AI.`valeur`         as `Numero solicitud Apatridia`,
    AJ.`FechaValor`     as `Fecha Nacimiento`,
    AK.`FechaValor`     as `Fecha Entrada España`,
    
    L.`T_MODALITE_ID`   as `cod_pais`,
    M.`T_MODALITE_ID`   as `cod_genero`,
    N.`T_MODALITE_ID`   as `estaciv`,
    P.`T_MODALITE_ID`   as `poseedoc`,


    G.`T_MODALITE_ID`   as `cod_comu`,
    H.`T_MODALITE_ID`   as `cod_prov`,
    O.`T_MODALITE_ID`  as `asentamiento`,
    Q.`T_MODALITE_ID`  as `empadro`,
    R.`T_MODALITE_ID`  as `tarjetasanitaria`,
    S.`T_MODALITE_ID`  as `hispanohablante`,
    T.`T_MODALITE_ID`  as `hablacastellano`,
    U.`T_MODALITE_ID`  as `buscactlaboral`,
    V.`T_MODALITE_ID`  as `tienehijosacargo`,
    W.`T_MODALITE_ID`  as `cuantoshijosacargo`,
    X.`T_MODALITE_ID`  as `sitlaboral`,
    Y.`T_MODALITE_ID`  as `cuantosrecursos`,
    Z.`T_MODALITE_ID`  as `derivadopor`,

    IF(BL.`vuln_menores`,true,false),
    IF(BM.`vuln_menorsinacop`,true,false),
    IF(BN.`vuln_edad`,true,false),
    IF(BO.`vuln_embarazada`,true,false),
    IF(BP.`vuln_monoparental`,true,false),
    IF(BQ.`vuln_trata`,true,false),
    IF(BR.`vuln_enferma`,true,false),
    IF(BS.`vuln_tratorno`,true,false),
    IF(BT.`vuln_tortura`,true,false),
    IF(BU.`vuln_genero`,true,false),
    IF(BV.`vuln_sinhogar`,true,false),
    IF(BW.`vuln_otro`,true,false),
    
    IF(DA.`doc_nie`,true,false),
    IF(DB.`doc_solprotec`,true,false),
    IF(DC.`doc_dni`,true,false),
    IF(DD.`doc_pasaporte`,true,false),
    IF(DE.`doc_solapatri`,true,false),
    IF(DF.`doc_otro`,true,false),
    IF(DG.`doc_siria`,true,false),


    IF(BA.`convive_pareja`,true,false),
    IF(BB.`convive_hijos`,true,false),
    IF(BC.`convive_padres`,true,false),
    IF(BD.`convive_hermanos`,true,false),
    IF(BE.`convive_compa`,true,false),
    IF(BF.`convive_familiares`,true,false),
    IF(BG.`convive_otronucleo`,true,false),
    IF(BH.`convive_amigos`,true,false),
    IF(BI.`convive_otros`,true,false),
    IF(BJ.`convive_empleador`,true,false),

    IF(CA.`rec_sin`,true,false),
    IF(CB.`rec_ecoacogidatemp`,true,false),
    IF(CC.`rec_entidadsocial`,true,false),
    IF(CD.`rec_familiares`,true,false),
    IF(CE.`rec_rentainser`,true,false),
    IF(CF.`rec_cuentaprop`,true,false),
    IF(CG.`rec_asalconcont`,true,false),
    IF(CH.`rec_asalsincont`,true,false),
    IF(CI.`rec_desempleo`,true,false),
    IF(CJ.`rec_ahorro`,true,false),
    IF(CK.`rec_practicanoreco`,true,false),
    IF(CL.`rec_nodeclarado`,true,false),


    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8600) AS G -- comunidad 
    ON A.`T_OBSERVATION_ID`=C.`T_OBSERVATION_ID`
    AND A.`session`=C.`session`
    LEFT JOIN 
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8601) AS H -- provincia
    ON A.`T_OBSERVATION_ID`=C.`T_OBSERVATION_ID`
    AND A.`session`=C.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8956) AS O -- asentamiento
    ON A.`T_OBSERVATION_ID`=O.`T_OBSERVATION_ID`
    AND A.`session`=O.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8594) AS P -- empadronado
    ON A.`T_OBSERVATION_ID`=O.`T_OBSERVATION_ID`
    AND A.`session`=O.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8782) AS R -- tarjeta sanitaria
    ON A.`T_OBSERVATION_ID`=R.`T_OBSERVATION_ID`
    AND A.`session`=R.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8790) AS S -- hispanohablante
    ON A.`T_OBSERVATION_ID`=S.`T_OBSERVATION_ID`
    AND A.`session`=S.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8835) AS T -- habla castellano
    ON A.`T_OBSERVATION_ID`=T.`T_OBSERVATION_ID`
    AND A.`session`=T.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8810) AS U -- busca actividad laboral
    ON A.`T_OBSERVATION_ID`=U.`T_OBSERVATION_ID`
    AND A.`session`=U.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8785) AS V -- tiene hijos a cargo?
    ON A.`T_OBSERVATION_ID`=V.`T_OBSERVATION_ID`
    AND A.`session`=V.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8786) AS W -- cuantos hijos a cargo?
    ON A.`T_OBSERVATION_ID`=W.`T_OBSERVATION_ID`
    AND A.`session`=W.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8805) AS X -- situación laboral
    ON A.`T_OBSERVATION_ID`=X.`T_OBSERVATION_ID`
    AND A.`session`=X.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8815) AS Y -- cuantos recursos dispone la unidad laboral?
    ON A.`T_OBSERVATION_ID`=Y.`T_OBSERVATION_ID`
    AND A.`session`=Y.`session`
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8819) AS Z -- Quien le ha derivado a Accem?
    ON A.`T_OBSERVATION_ID`=Z.`T_OBSERVATION_ID`
    AND A.`session`=Z.`session`




    -- ¿cual es la naturaleza de sus recursos economicos?
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83496) AS CA -- sin recursos
    ON A.`T_OBSERVATION_ID`=CA.`T_OBSERVATION_ID`
    AND A.`session`=CA.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83497) AS CB -- ayuda eco acogida temporal
    ON A.`T_OBSERVATION_ID`=CB.`T_OBSERVATION_ID`
    AND A.`session`=CB.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83498) AS CC -- ayuda entidades sociales
    ON A.`T_OBSERVATION_ID`=CC.`T_OBSERVATION_ID`
    AND A.`session`=CC.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83499) AS CD -- familiares
    ON A.`T_OBSERVATION_ID`=CD.`T_OBSERVATION_ID`
    AND A.`session`=CD.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83500) AS CE -- renta inserción
    ON A.`T_OBSERVATION_ID`=CE.`T_OBSERVATION_ID`
    AND A.`session`=CE.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83501) AS CF -- trabajador cuenta propia
    ON A.`T_OBSERVATION_ID`=CF.`T_OBSERVATION_ID`
    AND A.`session`=CF.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83502) AS CG -- asalariado con contrato
    ON A.`T_OBSERVATION_ID`=CG.`T_OBSERVATION_ID`
    AND A.`session`=CG.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83503) AS CH -- asalariado sin contrato
    ON A.`T_OBSERVATION_ID`=CH.`T_OBSERVATION_ID`
    AND A.`session`=CH.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83504) AS CI -- prestación por desempleo
    ON A.`T_OBSERVATION_ID`=CI.`T_OBSERVATION_ID`
    AND A.`session`=CI.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83505) AS CJ -- ahorros
    ON A.`T_OBSERVATION_ID`=CJ.`T_OBSERVATION_ID`
    AND A.`session`=CJ.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83506) AS CK -- ingresos por practicas no reconocidas
    ON A.`T_OBSERVATION_ID`=CK.`T_OBSERVATION_ID`
    AND A.`session`=CK.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=83507) AS CL -- trabajo no declarado
    ON A.`T_OBSERVATION_ID`=CL.`T_OBSERVATION_ID`
    AND A.`session`=CL.`session`


    -- ¿con quien convive?
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84951) AS BA -- convive con pareja
    ON A.`T_OBSERVATION_ID`=BA.`T_OBSERVATION_ID`
    AND A.`session`=BA.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84952) AS BB -- convive con hijos
    ON A.`T_OBSERVATION_ID`=BB.`T_OBSERVATION_ID`
    AND A.`session`=BB.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84953) AS BC -- convive con padre/madre
    ON A.`T_OBSERVATION_ID`=BC.`T_OBSERVATION_ID`
    AND A.`session`=BC.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84954) AS BD -- convive con hermanos
    ON A.`T_OBSERVATION_ID`=BD.`T_OBSERVATION_ID`
    AND A.`session`=BD.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84955) AS BE -- convive con compañeros de centro
    ON A.`T_OBSERVATION_ID`=BE.`T_OBSERVATION_ID`
    AND A.`session`=BE.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84956) AS BF -- convive con otros miembros de la familia
    ON A.`T_OBSERVATION_ID`=BF.`T_OBSERVATION_ID`
    AND A.`session`=BF.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84957) AS BG -- convive con otro nucleo familiar
    ON A.`T_OBSERVATION_ID`=BG.`T_OBSERVATION_ID`
    AND A.`session`=BG.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84958) AS BH -- convive con amigos
    ON A.`T_OBSERVATION_ID`=BH.`T_OBSERVATION_ID`
    AND A.`session`=BH.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84960) AS BI -- convive con otras personas
    ON A.`T_OBSERVATION_ID`=BI.`T_OBSERVATION_ID`
    AND A.`session`=BI.`session`
    LEFT JOIN
    (SELECT 
    `T_OBSERVATION_ID`,
    `session`,
    `T_MODALITE_ID`
    FROM `temp_obs_mod`
    WHERE `T_MODALITE_ID`=84961) AS BJ -- convive con empleador
    ON A.`T_OBSERVATION_ID`=BJ.`T_OBSERVATION_ID`
    AND A.`session`=BJ.`session`

*/




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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
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
    `temp_obs_mod`
    WHERE `T_DESCRIPTEUR_ID`=8612
    GROUP BY `T_MODALITE_ID`) as A
    LEFT JOIN 
    `ods_modalite` as B
    ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND A.`cod_inmi`=B.`T_MODALITE_ID`
);



