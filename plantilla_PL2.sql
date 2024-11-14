set pager off

SET client_encoding = 'UTF8';

BEGIN;
\echo 'creando el esquema para la BBDD de películas'


\echo 'creando un esquema temporal'


SET search_path = 'nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'



-- Esquema temporal: Tablas con todos los campos como TEXT y sin restricciones
CREATE SCHEMA IF NOT EXISTS intermedio;

CREATE TABLE IF NOT EXISTS intermedio.Usuario (

    contraseña TEXT,
    email TEXT UNIQUE,
    nombre TEXT,
    nombre_usuario TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS intermedio.Grupo (

    nombre_grupo TEXT UNIQUE,
    URL_web TEXT
);

CREATE TABLE IF NOT EXISTS intermedio.Disco (

    titulo TEXT,
    año_publicacion TEXT,
    URL_portada TEXT,
    nombre_grupo TEXT
);

CREATE TABLE IF NOT EXISTS intermedio.Genero (

    año_publicacion TEXT,
    titulo TEXT,
    genero TEXT
);

CREATE TABLE IF NOT EXISTS intermedio.Canciones (

    titulo TEXT,
    duracion TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT

);

CREATE TABLE IF NOT EXISTS intermedio.Ediciones (

    formato TEXT,
    año_edicion TEXT,
    pais TEXT,
    titulo TEXT,
    año_publicacion TEXT,
    estado TEXT

);

CREATE TABLE IF NOT EXISTS intermedio.Tiene(

    nombre_usuario TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT,
    estado TEXT

);

CREATE TABLE IF NOT EXISTS intermedio.Desea (

    nombre_usuario TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT
    
);

-- Comandos \COPY para cargar datos desde CSVs en el esquema temporal
\COPY intermedio.Usuario FROM ./PL2-BBDD/DATOS DISCO/usuario.csv WITH (FORMAT csv, HEADER, DELIMITER ';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Disco FROM ./PL2-BBDD/DATOS DISCO/discos.csv WITH (FORMAT csv, HEADER, DELIMITER ';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Ediciones FROM ./PL2-BBDD/DATOS DISCO/ediciones.csv WITH (FORMAT csv, HEADER, DELIMITER ';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Canciones FROM ./PL2-BBDD/DATOS DISCO/canciones.csv WITH (FORMAT csv, HEADER, DELIMITER ';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Tiene FROM ./PL2-BBDD/DATOS DISCO/usuario_tiene_edicion.csv WITH (FORMAT csv, HEADER, DELIMITER ';', NULL 'NULL', ENCODING 'UTF-8');
\COPY intermedio.Desea FROM ./PL2-BBDD/DATOS DISCO/usuario_desea_disco.csv WITH (FORMAT csv, HEADER, DELIMITER ';', NULL 'NULL', ENCODING 'UTF-8');



-- Esquema final: Aquí se definen las tablas con claves primarias y foráneas

CREATE TABLE IF NOT EXISTS Usuario (

    contraseña VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(20) NOT NULL,
    nombre_usuario VARCHAR(15) NOT NULL PRIMARY KEY,
);

CREATE TABLE IF NOT EXISTS Grupo (

    nombre_grupo VARCHAR(20) NOT NULL PRIMARY KEY,
    URL_web VARCHAR(50) NOT NULL,
);

CREATE TABLE IF NOT EXISTS Disco (

    titulo VARCHAR(20) NOT NULL PRIMARY KEY,
    año_publicacion DATE NOT NULL PRIMARY KEY, 
    URL_portada VARCHAR(50) NOT NULL,
    FOREIGN KEY (nombre_grupo) REFERENCES Grupo(nombre_grupo),
);

CREATE TABLE IF NOT EXISTS Genero (

    FOREIGN KEY (año_publicacion) REFERENCES Disco(año_publicacion),
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    genero VARCHAR(20) NOT NULL,
);

CREATE TABLE IF NOT EXISTS Canciones (

    titulo VARCHAR(20) NOT NULL PRIMARY KEY,
    duracion TIME NOT NULL,
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    FOREIGN KEY ( año_publicacion) REFERENCES Disco( año_publicacion),

);

CREATE TABLE IF NOT EXISTS Ediciones (

    formato VARCHAR(20) NOT NULL PRIMARY KEY,
    año_edicion DATE NOT NULL,
    pais VARCHAR(20) NOT NULL,
    PRIMARY KEY (titulo) REFERENCES Disco(titulo),
    PRIMARY KEY ( año_publicacion) REFERENCES Disco( año_publicacion),
    FOREIGN KEY (estado) REFERENCES Tiene(estado),

);

CREATE TABLE IF NOT EXISTS Tiene(

    PRIMARY KEY (nombre_usuario,titulo_disco,año_publicacion_disco)
    FOREIGN KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    FOREIGN KEY (año_publicacion) REFERENCES Disco(año_publicacion),
    estado VARCHAR(20) NOT NULL,

);

CREATE TABLE IF NOT EXISTS Desea (

    PRIMARY KEY (nombre_usuario,titulo_disco,año_publicacion_disco)
    FOREIGN KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    FOREIGN KEY (año_publicacion) REFERENCES Disco(año_publicacion),

);


-- Cambiar al esquema final
SET search_path TO esquema_final;

-- 1. Insertar en Usuario (sin dependencias)
INSERT INTO Usuario (nombre_usuario, contraseña, email, nombre)
SELECT nombre_usuario, contraseña, email, nombre
FROM intermedio.Usuario;

-- 2. Insertar en Grupo (sin dependencias)
INSERT INTO Grupo (nombre_grupo, URL_web)
SELECT nombre_grupo, URL_web
FROM intermedio.Grupo;

-- 3. Insertar en Disco (depende de Grupo)
INSERT INTO Disco (titulo, año_publicacion, URL_portada, nombre_grupo)
SELECT titulo, CAST(año_publicacion AS DATE), URL_portada, nombre_grupo
FROM Insertar.Disco;

-- 4. Insertar en Genero (depende de Disco)
INSERT INTO Genero (titulo, año_publicacion, genero)
SELECT titulo, CAST(año_publicacion AS DATE), genero
FROM intermedio.Genero;

-- 5. Insertar en Canciones (depende de Disco)
INSERT INTO Canciones (titulo_cancion, duracion, titulo_disco, año_publicacion)
SELECT titulo_cancion, CAST(duracion AS TIME), titulo_disco, CAST(año_publicacion AS DATE)
FROM intermeq.Canciones;

-- 6. Insertar en Ediciones (depende de Disco)
INSERT INTO Ediciones (formato, año_edicion, pais, titulo, año_publicacion)
SELECT formato, CAST(año_edicion AS DATE), pais, titulo, CAST(año_publicacion AS DATE)
FROM intermedio.Ediciones;

-- 7. Insertar en Tiene (depende de Usuario y Disco)
INSERT INTO Tiene (nombre_usuario, titulo, año_publicacion, estado)
SELECT nombre_usuario, titulo, CAST(año_publicacion AS DATE), estado
FROM intermedio.Tiene;

-- 8. Insertar en Desea (depende de Usuario y Disco)
INSERT INTO Desea (nombre_usuario, titulo, año_publicacion)
SELECT nombre_usuario, titulo, CAST(año_publicacion AS DATE)
FROM intermedio.Desea;







\echo 'insertando datos en el esquema final'

\echo 'Consulta 1: texto de la consulta'

\echo ' Consulta n:'


ROLLBACK;                       -- importante! permite correr el script multiples veces...p