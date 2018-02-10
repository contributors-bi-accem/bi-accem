

--
-- Modelo de datos para el datamart de prestaciones
--



-- --------------------------------------------------------
--
-- Tablas Operational Data Store ods_*
--
-- Esas tablas son un espejo del sistema e-gorrion.
-- Permiten validar que no se han perdido datos entre el 
-- sistema original y el espejo.
--
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ods_descripteur` (
  `T_DESCRIPTEUR_ID` int(6) NULL,
  `LibelleDescripteur` varchar(255) NULL,
  `SautDescripteur` varchar(255) NULL,
  `Valeur` varchar(25) NULL,
  `CodeDescripteur` varchar(50) NULL,
  `RangDescripteur` float NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `description` text NULL,
  `isSession` tinyint(1) NULL,
  `saisissable` tinyint(1) NULL ,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_DESCRIPTEUR_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_modalite` (
  `T_MODALITE_ID` int(11) NULL,
  `LibelleModalite` varchar(150) NULL,
  `TypeModalite` varchar(25) NULL,
  `CodeModalite` varchar(20) NULL,
  `RangModalite` int(11) NULL,
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `visible` tinyint(1) NULL ,
  `data_date` timestamp NULL, 
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_MODALITE_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_observation` (
  `T_OBSERVATION_ID` int(11) NULL,
  `CodeObservation` varchar(50) NULL,
  `ObservationPublic` varchar(10) NULL,
  `ObservationValide` varchar(10) NULL,
  `T_QUESTIONNAIRE_ID` int(11) NULL,
  `verouiller` binary(1),
  `created` datetime NULL,
  `id_enqu` int(11) NULL,
  `suivi` mediumtext NULL,
  `accem` int(1) NULL,
  `export` int(11) NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_OBSERVATION_ID`),
  INDEX observation_quest (`T_OBSERVATION_ID`,`T_QUESTIONNAIRE_ID`),
  INDEX observation_dd(`data_date`)
);
-- CREATE INDEX ind_observation ON ods_observation (`T_OBSERVATION_ID`,`ObservationValide`,`T_QUESTIONNAIRE_ID`);

CREATE TABLE IF NOT EXISTS `ods_obs_descript` (
  `T_DESCRIPTEUR_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Valeur` longtext,
  `created` datetime NULL,
  `id_enqu` text NULL,
  `suivi` mediumtext NULL,
  `session` int(11) NULL,
  `Fecha_Modificacion` timestamp NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_DESCRIPTEUR_ID`,`T_OBSERVATION_ID`,`session`),
  INDEX obs_descript_dd (`data_date`)
);

CREATE TABLE IF NOT EXISTS `ods_obs_mod` (
  `id_obs_mod` int(11) NULL,
  `date_debut` datetime NULL,
  `date_fin` datetime NULL,
  `T_MODALITE_ID` int(11) NULL,
  `T_OBSERVATION_ID` int(11) NULL,
  `Reponse` tinyint(4) NULL,
  `id_enq` int(4) NULL,
  `session` int(11) NULL,
  `Fecha_Modificacion` timestamp NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY (`id_obs_mod`),
  INDEX obs_mod_key (`T_OBSERVATION_ID`,`T_MODALITE_ID`,`session`,`date_debut`,`date_fin`,`id_enq`),
  INDEX obs_mod_observation (`T_OBSERVATION_ID`),
  INDEX obs_mod_modalite (`T_MODALITE_ID`),
  INDEX obs_mod_dd (`data_date`)
);

CREATE TABLE IF NOT EXISTS `ods_personne` (
  `T_PERSONNE_ID` int(11) NULL,
  `Nom` varchar(50) NULL,
  `Prenom` varchar(50) NULL,
  `DateNaissance` date NULL,
  `Telephone` varchar(14) NULL,
  `Email` varchar(50) NULL,
  `Succursale` varchar(100) NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY (`T_PERSONNE_ID`)
);

CREATE TABLE IF NOT EXISTS `ods_succursale_groupe` (
  `id_sg` int(11) NULL,
  `province` varchar(25) NULL,
  `succursale` varchar(25) NULL,
  `code` varchar(2) NULL,
  `data_date` timestamp NULL,
  `load_date` timestamp NULL,
  UNIQUE KEY (`id_sg`)
);

-- --------------------------------------------------------
--
-- Tablas de explotación th_* y td_*
--
-- Esas tablas contienen datos transformados a partir de las
-- tablas ods_* 
-- Esas tablas están orientadas a las consultas que se quieren
-- realizar sobre los datos del e-gorrion.
-- Las tablas de hechos (th_*) proporcionan las metricas y 
-- datos de tipo actividad. Las tablas de dimensiones (td_*)
-- permiten realizar un analisis por ciertos ejes.
--  
-- --------------------------------------------------------

-- vista intermedia para unir las modalite y los descripteur
-- del questionario 453
CREATE VIEW `v_modalite_descripteur` AS 
    SELECT A.`T_MODALITE_ID`,
    trim(A.`CodeModalite`) as `CodeModalite`,
    trim(A.`LibelleModalite`) as `LibelleModalite`, 
    trim(A.`TypeModalite`) as `TypeModalite`,
    A.`RangModalite`,
    A.`T_DESCRIPTEUR_ID`, 
    trim(B.`CodeDescripteur`) as `CodeDescripteur`,
    trim(B.`LibelleDescripteur`) as `LibelleDescripteur`,  
    trim(B.`SautDescripteur`) as `SautDescripteur`,
    replace(replace(replace(trim(B.`SautDescripteur`),'!',''),'(',''),')','') as `CodeModalitePadre`,
    B.`isSession`,
    A.`data_date`
    FROM `ods_modalite` A 
    JOIN `ods_descripteur` B ON A.`T_DESCRIPTEUR_ID`=B.`T_DESCRIPTEUR_ID`
    AND B.`T_QUESTIONNAIRE_ID`=453;

-- Esa tabla almacena la jerarquia modalite -> descripteur -> descripteur padre
CREATE TABLE IF NOT EXISTS `jer_modalite_descripteur` (
`T_MODALITE_ID`             int(11),
`CodeModalite`              varchar(20) NULL,
`LibelleModalite`           varchar(150) NULL,
`TypeModalite`              varchar(25) NULL,
`RangModalite`              int(11) NULL,
`T_DESCRIPTEUR_ID`          int(11),
`CodeDescripteur`           varchar(50) NULL,
`LibelleDescripteur`        varchar(255) NULL,
`SautDescripteur`           varchar(255) NULL,
`isSession`                 tinyint(1) NULL,
`id_descripteur_padre`      int(11),
`code_descripteur_padre`    varchar(50) NULL,
`libelle_descripteur_padre` varchar(255) NULL,
`data_date`                 timestamp NULL,
`load_date`                 timestamp NULL,
UNIQUE KEY (`T_MODALITE_ID`),
INDEX jermodesc_descripteur (`T_DESCRIPTEUR_ID`),
INDEX jermodesc_desc_padre (`id_descripteur_padre`),
INDEX jermodesc_modrang (`T_MODALITE_ID`,`RangModalite`)
);

/*
jerarquia financiación y programas: los "descripteur" que permiten deducir el tipo de financiación
son 4 preguntas anidadas que conforman una jerarquia:

1.  Tipo de Programa
    8620 Tipo de Programa

2.  Financiación del Programa
    8621 Financiación del Programa
    8945 Provincia
    8947 Comunidad
    9095 Financiación del programa internacional

3.  Convocatoria del programa
    8625    Programa estatal Real Decreto
    8627    Programa estatal Retorno Voluntario:
    8968    Localidades provincia Sevilla
    etc..

4.  Programas Locales 
    8949    Programas de Arcos de la Frontera
    8950    Programas de Cadiz
    etc...
*/

CREATE VIEW v_jer_programas AS
    SELECT A.`T_DESCRIPTEUR_ID` as `descripteur_nivel1`,
    B.`T_DESCRIPTEUR_ID` as `descripteur_nivel2`,
    C.`T_DESCRIPTEUR_ID` as `descripteur_nivel3`,
    D.`T_DESCRIPTEUR_ID` as `descripteur_nivel4` 
    FROM jer_modalite_descripteur A
    LEFT JOIN jer_modalite_descripteur B ON A.`T_DESCRIPTEUR_ID`=B.`id_descripteur_padre`
    LEFT JOIN jer_modalite_descripteur C ON B.`T_DESCRIPTEUR_ID`=C.`id_descripteur_padre`
    LEFT JOIN jer_modalite_descripteur D ON C.`T_DESCRIPTEUR_ID`=D.`id_descripteur_padre`
    WHERE A.`T_DESCRIPTEUR_ID`=8620 -- raiz
    GROUP BY `descripteur_nivel1`,`descripteur_nivel2`,`descripteur_nivel3`,`descripteur_nivel4`;

/*

1. Tipo de prestación
    9074    Tipo de Prestación
2. Prestación
    8633    Traducción
    etc...
    Todas las prestaciones tienen fecha de inicio date_debut
    Hay prestaciones periodicas que tienen fecha de fin en date_fin: son de tipo sUnique01
*/

CREATE VIEW v_jer_prestaciones AS
    SELECT A.`T_DESCRIPTEUR_ID` as `descripteur_nivel1`,
    B.`T_DESCRIPTEUR_ID` as `descripteur_nivel2`
    FROM jer_modalite_descripteur A
    LEFT JOIN jer_modalite_descripteur B ON A.`T_DESCRIPTEUR_ID`=B.`id_descripteur_padre`
    WHERE A.`T_DESCRIPTEUR_ID`=9074 -- raiz
    GROUP BY `descripteur_nivel1`,`descripteur_nivel2`;

/*
Historico situación usuario (sujeta a sesión)
T_DESCRIPTEUR_ID	LibelleDescripteur
8593	Nacionalidad
8610	Situación administrativa
8611	Solicitante de protección internacional
8612	Inmigrante
8619	Estudios finalizados
*/
/*
CREATE TABLE IF NOT EXISTS `temp_hist_situsua`
(
    `T_OBSERVATION_ID`          int(11) NULL,
    `CodeObservation`           varchar(50) NULL,
    `session`                   int(11) NULL,
    `created`                   datetime NULL,
    `id_enqu`                   int(11) NULL,
    `fecha_nacionalidad`        datetime NULL,
    `nacionalidad`              int(11) NULL,
    `fecha_sitadmin`            datetime NULL,
    `sitadmin`                  int(11) NULL,
    `fecha_solprotec`           datetime NULL,
    `solprotec`                 int(11) NULL,
    `fecha_inmigrante`          datetime NULL,
    `inmigrante`                int(11) NULL,
    `fecha_estudios`            datetime NULL,
    `estudios`                  int(11) NULL,
    `com_nacionalidad`          longtext,
    `com_sitadmin`              longtext,
    `com_solprotec`             longtext,
    `com_inmigrante`            longtext,
    `com_estudios`              longtext,
    `data_date`                 timestamp NULL,
    `load_date`                 timestamp NULL,
    UNIQUE KEY (`T_OBSERVATION_ID`,`session`)
);

-- tabla con la situación historica de los usuarios
CREATE TABLE IF NOT EXISTS `th_hist_situacion_usuarios`
(
    `T_OBSERVATION_ID`          int(11) NULL,
    `CodeObservation`           varchar(50) NULL,
    `session`                   int(11) NULL,
    `created`                   datetime NULL,
    `id_enqu`                   int(11) NULL,
    `fecha_nacionalidad`        datetime NULL,
    `nacionalidad`              int(11) NULL,
    `fecha_sitadmin`            datetime NULL,
    `sitadmin`                  int(11) NULL,
    `fecha_solprotec`           datetime NULL,
    `solprotec`                 int(11) NULL,
    `fecha_inmigrante`          datetime NULL,
    `inmigrante`                int(11) NULL,
    `fecha_estudios`            datetime NULL,
    `estudios`                  int(11) NULL,
    `com_nacionalidad`          longtext,
    `com_sitadmin`              longtext,
    `com_solprotec`             longtext,
    `com_inmigrante`            longtext,
    `com_estudios`              longtext,
    `data_date`                 timestamp NULL,
    `load_date`                 timestamp NULL,
    UNIQUE KEY (`T_OBSERVATION_ID`,`session`)
);
*/

-- tabla con la situación historica de los usuarios
CREATE TABLE IF NOT EXISTS `th_hist_nacionalidad`
(
    `T_OBSERVATION_ID`          int(11) NULL,
    `session`                   int(11) NULL,
    `fecha_inicio`              datetime NULL,
    `fecha_fin`                 datetime NULL,
    `nacionalidad`              int(11) NULL,
    `comentario`                longtext,
    `data_date`                 timestamp NULL,
    `load_date`                 timestamp NULL,
    UNIQUE KEY (`T_OBSERVATION_ID`,`session`)
);

-- tabla con la situación historica de los usuarios
CREATE TABLE IF NOT EXISTS `th_hist_sitadmin`
(
    `T_OBSERVATION_ID`          int(11) NULL,
    `session`                   int(11) NULL,
    `fecha_inicio`              datetime NULL,
    `fecha_fin`                 datetime NULL,
    `sitadmin`                  int(11) NULL,
    `comentario`                longtext,
    `data_date`                 timestamp NULL,
    `load_date`                 timestamp NULL,
    UNIQUE KEY (`T_OBSERVATION_ID`,`session`)
);

-- tabla con la situación historica de los usuarios
CREATE TABLE IF NOT EXISTS `th_hist_solprotec`
(
    `T_OBSERVATION_ID`          int(11) NULL,
    `session`                   int(11) NULL,
    `fecha_inicio`              datetime NULL,
    `fecha_fin`                 datetime NULL,
    `solprotec`                 int(11) NULL,
    `comentario`                longtext,
    `data_date`                 timestamp NULL,
    `load_date`                 timestamp NULL,
    UNIQUE KEY (`T_OBSERVATION_ID`,`session`)
);

-- tabla con la situación historica de los usuarios
CREATE TABLE IF NOT EXISTS `th_hist_inmigrante`
(
    `T_OBSERVATION_ID`          int(11) NULL,
    `session`                   int(11) NULL,
    `fecha_inicio`              datetime NULL,
    `fecha_fin`                 datetime NULL,
    `inmigrante`                int(11) NULL,
    `comentario`                longtext,
    `data_date`                 timestamp NULL,
    `load_date`                 timestamp NULL,
    UNIQUE KEY (`T_OBSERVATION_ID`,`session`)
);

-- tabla con la situación historica de los usuarios
CREATE TABLE IF NOT EXISTS `th_hist_estudios`
(
    `T_OBSERVATION_ID`          int(11) NULL,
    `session`                   int(11) NULL,
    `fecha_inicio`              datetime NULL,
    `fecha_fin`                 datetime NULL,
    `estudios`                  int(11) NULL,
    `comentario`                longtext,
    `data_date`                 timestamp NULL,
    `load_date`                 timestamp NULL,
    UNIQUE KEY (`T_OBSERVATION_ID`,`session`)
);


-- Tabla intermedia para limpiar algunas descripciones
CREATE TABLE IF NOT EXISTS `temp_obs_descript` (
`T_OBSERVATION_ID`      int(11),
`T_DESCRIPTEUR_ID`      int(11),
`session`               int(11),
`id_enqu`               int(11) NULL,
`Fecha_Modificacion`    timestamp NULL,
`Valeur`                varchar(150),
`FechaValor`            datetime NULL,
`data_date`             timestamp NULL,
`load_date`             timestamp NULL,
UNIQUE KEY (`T_OBSERVATION_ID`,`T_DESCRIPTEUR_ID`,`session`),
INDEX temp_obs_desc_dd(`data_date`)
);

-- Tabla intermedia para facilitar la carga de th_prestaciones
CREATE TABLE IF NOT EXISTS `temp_obs_mod` (
`id_obs_mod`            int(11) NULL,
`T_OBSERVATION_ID`      int(11),
`T_DESCRIPTEUR_ID`      int(11),
`session`               int(11),
`T_MODALITE_ID`         int(11),
`date_debut`            datetime NULL,
`date_fin`              datetime NULL,
`id_enq`                int(11) NULL,
`Fecha_Modificacion`    timestamp NULL,
`CodeObservation`       varchar(50) NULL,
`created`               datetime NULL,
`id_enqu`               int(11) NULL,
`ObservationPublic`     varchar(10) NULL,
`ObservationValide`     varchar(10) NULL,
`verouiller`            binary(1),
`data_date`             timestamp NULL,
`load_date`             timestamp NULL,
UNIQUE KEY (`id_obs_mod`),
INDEX temp_obs_mod_sesion_modalite (`T_OBSERVATION_ID`,`T_DESCRIPTEUR_ID`,`session`,`T_MODALITE_ID`),
INDEX temp_obs_mod_date (`T_DESCRIPTEUR_ID`,`T_MODALITE_ID`,`data_date`),
INDEX temp_obs_mod_dd(`data_date`)
);

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
modalidad   8785    ¿tiene hijos a cargo?
modalidad   8805    Situación laboral

---
modalidad   9107    Ha entrado a traves prog reasentamiento?
modalidad   8606    es usted el referente familiar
observación 8609    sino: NB del referente
modalidad   9063    parentesco

modalidad   8633    idioma traducción
observacion 9067    numero de horas de interpretación
observación 9068    numero de hojas traducidas


---
modalidad   8958    Con quien convive?    
            84951   pareja
            84952   hijos
            84953   padre/madre
            84954   hermanos
            84955   compañeros de centro
            84956   otros miembros de la familia
            84957   otro nucleo familiar
            84958   amigos
            84960   otras personas
            84961   alojado con empleadores   

modalidad   8913    tipo de documentación?
            84366   NIE
            84367   Sol. protec intl
            84368   DNI
            84369   pasaporte
            84370   sol apatridia
            84371   otros
            87255   numero siria

*/

-- tabla de hechos de prestaciones
CREATE TABLE IF NOT EXISTS `th_prestaciones` (
`T_OBSERVATION_ID`      int(11),
`CodeObservation`       varchar(50) NULL,
`session`               int(11) NULL,
`created`               datetime NULL,
`id_enqu`               int(11) NULL,
`Succursale`            varchar(100) NULL,
`date_debut`            datetime NULL,
`date_fin`              datetime NULL, 
`periodicidad`          varchar(50),

`tipo_prest`            int(11) NULL, 
`cod_prest`             int(11) NULL,
`tipo_prog`             int(11) NULL,
`fin_prog`              int(11) NULL,
`conv_prog`             int(11) NULL,
`prog_local`            int(11) NULL,

`Nombre Persona`        varchar(150) NULL,
`Primer Apellido`       varchar(150) NULL,
`Segundo Apellido`      varchar(150) NULL,
`NIE`                   varchar(150) NULL,
`DNI`                   varchar(150) NULL,
`Pasaporte`             varchar(150) NULL,
`Numero Asilo`          varchar(150) NULL,
`Numero siria`          varchar(150) NULL,
`Numero solicitud Apatridia`                varchar(150) NULL,
`Fecha Nacimiento`      datetime NULL,
`Fecha Entrada España`  datetime NULL,

`cod_pais`              int(11) NULL,
`cod_genero`            int(11) NULL,
`estaciv`               int(11) NULL,
`poseedoc`              int(11) NULL,

`nacionalidad`          int(11) NULL,
`situadmin`             int(11) NULL,
`solprotec`             int(11) NULL,
`inmigrante`            int(11) NULL,
`nivelstud`             int(11) NULL,

`vuln_menores`          boolean NULL,
`vuln_menorsinacop`     boolean NULL,
`vuln_edad`             boolean NULL,
`vuln_embarazada`       boolean NULL,
`vuln_monoparental`     boolean NULL,
`vuln_trata`            boolean NULL,
`vuln_enferma`          boolean NULL,
`vuln_tratorno`         boolean NULL,
`vuln_tortura`          boolean NULL,
`vuln_genero`           boolean NULL,
`vuln_sinhogar`         boolean NULL,
`vuln_otro`             boolean NULL,
`doc_nie`               boolean NULL,
`doc_solprotec`         boolean NULL,
`doc_dni`               boolean NULL,
`doc_pasaporte`         boolean NULL,
`doc_solapatri`         boolean NULL,
`doc_otro`              boolean NULL,
`doc_siria`             boolean NULL,

`data_date`             timestamp NULL, 
`load_date`             timestamp NULL,
UNIQUE KEY (`T_OBSERVATION_ID`,`session`,`cod_prest`,`date_debut`,`date_fin`),
INDEX th_prestaciones_dd(`data_date`)
);


-- tabla de detalle de los usuarios
CREATE TABLE IF NOT EXISTS `th_detalle_usuarios` (
`T_OBSERVATION_ID`      int(11),
`CodeObservation`       varchar(50) NULL,
`created`               datetime NULL,
`id_enqu`               int(11) NULL,

`sitlaboral`            int(11) NULL,
`asentamiento`          int(11) NULL,
`tiempadro`             int(11) NULL,
`tarjetasanitaria`      int(11) NULL,
`hispanohablante`       int(11) NULL,
`hablacastellano`       int(11) NULL,
`buscactlaboral`        int(11) NULL,
`tienehijosacargo`      int(11) NULL,
`cuantoshijosacargo`    int(11) NULL,
`sitlaboral`            int(11) NULL,
`cuantosrecursos`       int(11) NULL,
`derivadopor`           int(11) NULL,


`convive_pareja`        boolean NULL,
`convive_hijos`         boolean NULL,
`convive_padres`        boolean NULL,
`convive_hermanos`      boolean NULL,
`convive_compa`         boolean NULL,
`convive_familiares`    boolean NULL,
`convive_otronucleo`    boolean NULL,
`convive_amigos`        boolean NULL,
`convive_otros`         boolean NULL,
`convive_empleador`     boolean NULL,
`vuln_menores`          boolean NULL,
`vuln_menorsinacop`     boolean NULL,
`vuln_edad`             boolean NULL,
`vuln_embarazada`       boolean NULL,
`vuln_monoparental`     boolean NULL,
`vuln_trata`            boolean NULL,
`vuln_enferma`          boolean NULL,
`vuln_tratorno`         boolean NULL,
`vuln_tortura`          boolean NULL,
`vuln_genero`           boolean NULL,
`vuln_sinhogar`         boolean NULL,
`vuln_otro`             boolean NULL,
`rec_sin`               boolean NULL,
`rec_ecoacogidatemp`    boolean NULL,
`rec_entidadsocial`     boolean NULL,
`rec_familiares`        boolean NULL,
`rec_rentainser`        boolean NULL,
`rec_cuentaprop`        boolean NULL,
`rec_asalconcont`       boolean NULL,
`rec_asalsincont`       boolean NULL,
`rec_desempleo`         boolean NULL,
`rec_ahorro`            boolean NULL,
`rec_practicanoreco`    boolean NULL,
`rec_nodeclarado`       boolean NULL,
`doc_nie`               boolean NULL,
`doc_solprotec`         boolean NULL,
`doc_dni`               boolean NULL,
`doc_pasaporte`         boolean NULL,
`doc_solapatri`         boolean NULL,
`doc_otro`              boolean NULL,
`doc_siria`             boolean NULL,
`data_date`             timestamp NULL, 
`load_date`             timestamp NULL,

UNIQUE KEY (`T_OBSERVATION_ID`)
);


-- dimensiones

CREATE TABLE IF NOT EXISTS `td_prestacion` (
`cod_prest` int(11),
`Prestación` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_prest`)
);

CREATE TABLE IF NOT EXISTS `td_tipoprograma` (
`cod_tiprog` int(11),
`Tipo de Programa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_tiprog`)
);

CREATE TABLE IF NOT EXISTS `td_finprograma` (
`cod_finprog` int(11),
`Financiación del Programa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_finprog`)
);

CREATE TABLE IF NOT EXISTS `td_convprograma` (
`cod_convprog` int(11),
`Convocatoria del programa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_convprog`)
);

CREATE TABLE IF NOT EXISTS `td_provincia` (
`cod_prov` int(11),
`Provincia` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_prov`)
);

CREATE TABLE IF NOT EXISTS `td_comunidad` (
`cod_comu` int(11),
`Comunidad` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_comu`)
);

CREATE TABLE IF NOT EXISTS `td_nacionalidad` (
`cod_nacion` int(11),
`Nacionalidad` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_nacion`)
);

CREATE TABLE IF NOT EXISTS `td_pais` (
`cod_pais` int(11),
`Pais de Nacimiento` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_pais`)
);

CREATE TABLE IF NOT EXISTS `td_situadmin` (
`cod_situadmin` int(11),
`Situación administrativa` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_situadmin`)
);

CREATE TABLE IF NOT EXISTS `td_nivelestud` (
`cod_nivelstud` int(11),
`Nivel de estudios` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_nivelstud`)
);

CREATE TABLE IF NOT EXISTS `td_genero` (
`cod_genero` int(11),
`Sexo` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_genero`)
);

CREATE TABLE IF NOT EXISTS `td_solprotec` (
`cod_solprotec` int(11),
`Solicitante de protección internacional` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_solprotec`)
);

CREATE TABLE IF NOT EXISTS `td_inmigrante` (
`cod_inmi` int(11),
`Inmigrante` varchar(150) NULL,
`data_date` timestamp NULL,
`load_date` timestamp NULL,
UNIQUE KEY (`cod_inmi`)
);
