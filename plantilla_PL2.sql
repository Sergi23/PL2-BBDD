\pset pager off

SET client_encoding = 'UTF8';

BEGIN;
\echo 'creando el esquema para la BBDD de películas'


\echo 'creando un esquema temporal'


SET search_path='nombre del esquema o esquemas utilizados';

\echo 'Cargando datos'

CREATE ESCHEMA IF NOT EXISTS intermedio;

CREATE TABLE IF NO EXISTS intermedio.Usuario (

    contraseña TEXT,
    email TEXT,
    nombre TEXT,
    nombre_usuario TEXT,
)

CREATE TABLE IF NO EXISTS intermedio.Grupo (

    nombre_grupo TEXT,
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

CREATE TABLE IF NO EXISTS Usuario (

    contraseña VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL,
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
    FOREING KEY (nombre_grupo) REFERENCES Grupo(nombre_grupo),
)

CREATE TABLE IF NO EXISTS Genero (

    FOREING KEY ( año_publicacion) REFERENCES Disco( año_publicacion),
    FOREING KEY (titulo) REFERENCES Disco(titulo),
    genero VARCHAR(20) NOT NULL,
)

CREATE TABLE IF NO EXISTS Canciones (

    titulo VARCHAR(20) NOT NULL PRIMARY KEY,
    duracion TIME NOT NULL,
    FOREING KEY (titulo) REFERENCES Disco(titulo),
    FOREING KEY ( año_publicacion) REFERENCES Disco( año_publicacion),

)

CREATE TABLE IF NO EXISTS Ediciones (

    formato VARCHAR(20) NOT NULL, PRIMARY KEY,
    año_edicion DATE NOT NULL,
    pais VARCHAR(20) NOT NULL,
    PRIMARY KEY (titulo) REFERENCES Disco(titulo),
    PRIMARY KEY ( año_publicacion) REFERENCES Disco( año_publicacion),
    FOREING KEY (estado) REFERENCES Tiene(estado),

)

CREATE TABLE IF NO EXISTS Tiene(

    PRIMARY FOREING KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    PRIMARY FOREING KEY (titulo) REFERENCES Disco(titulo),
    PRIMARY FOREING KEY ( año_publicacion) REFERENCES Disco( año_publicacion),
    estado VARCHAR(20) NOT NULL,
)

CREATE TABLE IF NO EXISTS Desea (

    PRIMARY FOREING KEY (nombre_usuario) REFERENCES usuario(nombre_usuario),
    PRIMARY FOREING KEY (titulo) REFERENCES Disco(titulo),
    PRIMARY FOREING KEY ( año_publicacion) REFERENCES Disco( año_publicacion),
)
\echo insertando datos en el esquema final

\echo Consulta 1: texto de la consulta

\echo Consulta n:


ROLLBACK;                       -- importante! permite correr el script multiples veces...p