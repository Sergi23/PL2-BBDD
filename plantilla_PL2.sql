
SET client_encoding = 'UTF-8';

BEGIN;

CREATE SCHEMA IF NOT EXISTS intermedio;
--SET search_path = intermedio ;

\echo 'Cargando datos';


-- Esquema temporal: Tablas con todos los campos como TEXT y sin restricciones


CREATE TABLE IF NOT EXISTS intermedio.Usuario (

    nombre TEXT,
    nombre_usuario TEXT ,
    email TEXT ,
    contraseña TEXT  
    
);



CREATE TABLE IF NOT EXISTS intermedio.Disco (

    id_disco TEXT,
    nombre_disco TEXT,
    año_publicacion TEXT,
    id_grupo TEXT,
    nombre_grupo TEXT,
    URL_grupo   TEXT,
    generos TEXT,
    url_portada TEXT
   
);

CREATE TABLE IF NOT EXISTS intermedio.Canciones (

    id_disco TEXT,
    titulo TEXT,
    duracion TEXT

);

CREATE TABLE IF NOT EXISTS intermedio.Ediciones (

    id_disco TEXT,
    año_edicion TEXT,
    pais TEXT,
    formato TEXT

);

CREATE TABLE IF NOT EXISTS intermedio.Tiene(

    nombre_usuario TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT,
    año_edicion TEXT,
    pais_edicion TEXT,
    formato TEXT,
    estado TEXT

);

CREATE TABLE IF NOT EXISTS intermedio.Desea (

    nombre_usuario TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT
    
);

-- Comandos \COPY para cargar datos desde CSVs en el esquema temporal
\COPY intermedio.Usuario FROM ./DATOS_DISCOS/usuarios.csv WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Disco FROM ./DATOS_DISCOS/discos.csv WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Ediciones FROM ./DATOS_DISCOS/ediciones.csv WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Canciones FROM ./DATOS_DISCOS/canciones.csv WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Tiene FROM ./DATOS_DISCOS/usuario_tiene_edicion.csv WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Desea FROM ./DATOS_DISCOS/usuario_desea_disco.csv WITH (FORMAT csv, HEADER, DELIMITER E';', NULL 'NULL', ENCODING 'UTF-8');



-- Esquema final: Aquí se definen las tablas con claves primarias y foráneas

CREATE TABLE IF NOT EXISTS Usuario (

    contraseña VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL ,
    nombre VARCHAR(20) NOT NULL,
    nombre_usuario VARCHAR(15) NOT NULL PRIMARY KEY
);


CREATE TABLE IF NOT EXISTS Disco (

    id_disco VARCHAR(20) NOT NULL PRIMARY KEY,
    titulo_disco VARCHAR(20) NOT NULL,
    año_publicacion DATE NOT NULL,
    id_grupo VARCHAR(20) NOT NULL,
    nombre_grupo VARCHAR(20) NOT NULL,
    url_grupo VARCHAR(50) NOT NULL,
    generos VARCHAR(50) NOT NULL,   
    url_portada VARCHAR(50) NOT NULL
);


CREATE TABLE IF NOT EXISTS Canciones (

    titulo_cancion VARCHAR(20) NOT NULL,
    duracion TIME NOT NULL,
    id_disco VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_disco, titulo_cancion),
    FOREIGN KEY (id_disco) REFERENCES Disco(id_disco)

);

CREATE TABLE IF NOT EXISTS Ediciones (
    
    id_disco VARCHAR(20) NOT NULL,
    año_edicion DATE NOT NULL,
    pais_edicion VARCHAR(20) NOT NULL,
    formato VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_disco, año_edicion),
    FOREIGN KEY (id_disco) REFERENCES Disco(id_disco),

);

CREATE TABLE IF NOT EXISTS Tiene(

    nombre_usuario VARCHAR(50) NOT NULL,
    titulo_disco VARCHAR(100) NOT NULL,
    año_publicacion_disco DATE NOT NULL,
    año_edicion DATE NOT NULL,
    pais_edicion VARCHAR(50) NOT NULL,
    formato VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    PRIMARY KEY (nombre_usuario, titulo_disco, año_publicacion_disco),
    FOREIGN KEY (nombre_usuario) REFERENCES Usuario(nombre_usuario),
    FOREIGN KEY (titulo_disco) REFERENCES Disco(titulo_disco),
    FOREIGN KEY (año_publicacion_disco) REFERENCES Disco(año_publicacion)

);

CREATE TABLE IF NOT EXISTS Desea (

    nombre_usuario VARCHAR(50) NOT NULL,
    titulo_disco VARCHAR(100) NOT NULL,
    año_publicacion_disco DATE NOT NULL,
    PRIMARY KEY (nombre_usuario,titulo_disco,año_publicacion_disco),
    FOREIGN KEY (nombre_usuario) REFERENCES Usuario(nombre_usuario),
    FOREIGN KEY (titulo_disco, año_publicaion_disco) REFERENCES Disco(nombre_disco, año_publicacion)

);


-- Cambiar al esquema final
-- Cambiar al esquema final
CREATE SCHEMA IF NOT EXISTS esquema_final;

-- 1. Insertar en Usuario (sin dependencias)
INSERT INTO Usuario (nombre_usuario, contraseña, email, nombre)
SELECT nombre_usuario, contraseña, email, nombre
FROM intermedio.Usuario;

-- 2. Insertar en Disco (depende de Grupo)
INSERT INTO Disco (titulo_disco, año_publicacion, url_portada, nombre_grupo)
SELECT nombre_disco, CAST(año_publicacion AS DATE), url_portada, nombre_grupo
FROM intermedio.Disco;


-- 3. Insertar en Canciones (depende de Disco)
INSERT INTO Canciones (titulo_cancion, duracion, id_disco)
SELECT titulo, CAST(duracion AS TIME), id_disco
FROM intermedio.Canciones;

-- 4. Insertar en Ediciones (depende de Disco)
INSERT INTO Ediciones (id_disco, año_edicion, pais_edicion, formato)
SELECT id_disco, CAST(año_edicion AS DATE), pais, formato
FROM intermedio.Ediciones;

-- 5. Insertar en Tiene (depende de Usuario y Disco)
INSERT INTO Tiene (nombre_usuario, titulo_disco, año_publicacion_disco, año_edicion, pais_edicion, formato, estado)
SELECT nombre_usuario, titulo_disco, CAST(año_publicacion_disco AS DATE), CAST(año_edicion AS DATE), pais_edicion, formato, estado
FROM intermedio.Tiene;

-- 6. Insertar en Desea (depende de Usuario y Disco)
INSERT INTO Desea (nombre_usuario, titulo_disco, año_publicacion_disco)
SELECT nombre_usuario, titulo_disco, CAST(año_publicacion_disco AS DATE)
FROM intermedio.Desea;




\echo 'insertando datos en el esquema final'

\echo 'Consulta 1: texto de la consulta'

\echo ' Consulta n:'


ROLLBACK;                       -- importante! permite correr el script multiples veces...p