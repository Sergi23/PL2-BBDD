\pset pager off

SET client_encoding = 'UTF8';

BEGIN;
\echo 'creando el esquema para la BBDD de películas'


\echo 'creando un esquema temporal'


SET search_path='nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'



-- Esquema temporal: Tablas con todos los campos como TEXT y sin restricciones
CREATE ESCHEMA IF NOT EXISTS intermedio;

CREATE TABLE IF NO EXISTS intermedio.Usuario (

    contraseña TEXT,
    email TEXT UNIQUE,
    nombre TEXT,
    nombre_usuario TEXT UNIQUE,
)

CREATE TABLE IF NO EXISTS intermedio.Grupo (

    nombre_grupo TEXT UNIQUE,
    URL_web TEXT,
)

CREATE TABLE IF NO EXISTS intermedio.Disco (

    titulo TEXT,
    año_publicacion TEXT,
    URL_portada TEXT,
    nombre_grupo TEXT,
)

CREATE TABLE IF NO EXISTS intermedio.Genero (

    año_publicacion TEXT,
    titulo TEXT,
    genero TEXT,
)

CREATE TABLE IF NO EXISTS intermedio.Canciones (

    titulo TEXT,
    duracion TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT,

)

CREATE TABLE IF NO EXISTS intermedio.Ediciones (

    formato TEXT,
    año_edicion TEXT,
    pais TEXT,
    titulo TEXT,
    año_publicacion TEXT,
    estado TEXT,

)

CREATE TABLE IF NO EXISTS intermedio.Tiene(

    nombre_usuario TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT,
    estado TEXT,
)

CREATE TABLE IF NO EXISTS intermedio.Desea (

    nombre_usuario TEXT,
    titulo_disco TEXT,
    año_publicacion_disco TEXT,
    
)

-- Comandos \COPY para cargar datos desde CSVs en el esquema temporal
\COPY intermedio.Usuario FROM 'PL2-BBDD/DATOS DISCOS/usuarios.csv' DELIMITER ';' CSV HEADER;
\COPY intermedio.Disco FROM 'PL2-BBDD/DATOS DISCOS/discos.csv' DELIMITER ';' CSV HEADER;
\COPY intermedio.Ediciones FROM 'PL2-BBDD/DATOS DISCOS/ediciones.csv' DELIMITER ';' CSV HEADER;
\COPY intermedio.Canciones FROM 'PL2-BBDD/DATOS DISCOS/canciones.csv' DELIMITER ';' CSV HEADER;
\COPY intermedio.Tiene FROM 'PL2-BBDD/DATOS DISCOS/usuario_tiene_edicion.csv' DELIMITER ';' CSV HEADER;
\COPY intermedio.Desea FROM 'PL2-BBDD/DATOS DISCOS/usuario_desea_disco.csv' DELIMITER ';' CSV HEADER;




-- Esquema final: Aquí se definen las tablas con claves primarias y foráneas

CREATE TABLE IF NO EXISTS Usuario (

    contraseña VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(20) NOT NULL,
    nombre_usuario VARCHAR(15) NOT NULL PRIMARY KEY,
)

CREATE TABLE IF NO EXISTS Grupo (

    nombre_grupo VARCHAR(20) NOT NULL PRIMARY KEY,
    URL_web VARCHAR(50) NOT NULL,
)

CREATE TABLE IF NO EXISTS Disco (

    titulo VARCHAR(20) NOT NULL PRIMARY KEY,
    año_publicacion DATE NOT NULL PRIMARY KEY, 
    URL_portada VARCHAR(50) NOT NULL,
    FOREIGN KEY (nombre_grupo) REFERENCES Grupo(nombre_grupo),
)

CREATE TABLE IF NO EXISTS Genero (

    FOREIGN KEY (año_publicacion) REFERENCES Disco(año_publicacion),
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    genero VARCHAR(20) NOT NULL,
)

CREATE TABLE IF NO EXISTS Canciones (

    titulo VARCHAR(20) NOT NULL PRIMARY KEY,
    duracion TIME NOT NULL,
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    FOREIGN KEY ( año_publicacion) REFERENCES Disco( año_publicacion),

)

CREATE TABLE IF NO EXISTS Ediciones (

    formato VARCHAR(20) NOT NULL PRIMARY KEY,
    año_edicion DATE NOT NULL,
    pais VARCHAR(20) NOT NULL,
    PRIMARY KEY (titulo) REFERENCES Disco(titulo),
    PRIMARY KEY ( año_publicacion) REFERENCES Disco( año_publicacion),
    FOREIGN KEY (estado) REFERENCES Tiene(estado),

)

CREATE TABLE IF NO EXISTS Tiene(

    PRIMARY KEY (nombre_usuario,titulo_disco,año_publicacion_disco)
    FOREIGN KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    FOREIGN KEY (año_publicacion) REFERENCES Disco(año_publicacion),
    estado VARCHAR(20) NOT NULL,
)

CREATE TABLE IF NO EXISTS Desea (

    PRIMARY KEY (nombre_usuario,titulo_disco,año_publicacion_disco)
    FOREIGN KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    FOREIGN KEY (titulo) REFERENCES Disco(titulo),
    FOREIGN KEY (año_publicacion) REFERENCES Disco(año_publicacion),
)


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







\echo insertando datos en el esquema final

\echo Consulta 1: texto de la consulta

\echo Consulta n:


ROLLBACK;                       -- importante! permite correr el script multiples veces...p