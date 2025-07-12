-- Tablas Normales

CREATE TABLE Ranking (
	id_ranking INT PRIMARY KEY,
	tipo_ranking VARCHAR(20)
);

CREATE TABLE Categoria(
	tipo_categoria VARCHAR(20) PRIMARY KEY
);

-- tablas pero sin las foreign (las añado despues) y las que dependen de usuario se añaden despues
CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY,
    correo VARCHAR(80) NOT NULL, -- TC02 restringir el null en correo
    username VARCHAR(30),
    clave VARCHAR(40),
    pais VARCHAR(48),
    rol VARCHAR(20) NOT NULL CHECK (rol IN ('Cliente', 'Jefe de tienda')),
    id_usuarioJ INT,
    url_tienda VARCHAR(25),
    id_lista INT,
    id_carro INT
);

CREATE TABLE Tienda (
    url_tienda VARCHAR(25) PRIMARY KEY,
    nombre_tienda VARCHAR(25),
	id_usuarioJ INT
);

CREATE TABLE ListaDeseados (
    id_lista INT PRIMARY KEY,
	id_usuario INT,
	id_ranking INT
);

CREATE TABLE CarroCompras (
    id_carro INT PRIMARY KEY,
    id_usuario INT,
    url_tienda VARCHAR(25),
    total INT CHECK (total >= 0) --TC20 total de precio
);

CREATE TABLE Videojuego (
	game_id INT PRIMARY KEY,
	game_name VARCHAR(35),
	game_price INT,
	url_imagen VARCHAR(25),
	ventas INT,
	stock INT,
	desarrollador VARCHAR(35),
	url_tienda VARCHAR(25)
);

CREATE TABLE Valoracion(
	id_valoracion INT PRIMARY KEY,
	fechaV DATE,
	id_ranking INT,
	game_id INT,
	comentario VARCHAR(100),
	tipo_valoracion BOOL,
	id_usuario INT
);

CREATE TABLE ProcesoPago (
    id_boleta INT PRIMARY KEY,
    metodo_pago VARCHAR(15),
    fechaC DATE,
    id_carro INT,
    total INT CHECK (total >= 0), --TC20 total de precio
    CONSTRAINT chk_metodo_pago CHECK (metodo_pago IN ('Credito', 'Debito', 'Transferencia'))
);

-- Foreign keys
ALTER TABLE Usuario
	ADD FOREIGN KEY (id_usuarioJ) REFERENCES Usuario(id_usuario),
	ADD FOREIGN KEY (url_tienda) REFERENCES Tienda(url_tienda),
	ADD FOREIGN KEY (id_lista) REFERENCES ListaDeseados(id_lista),
	ADD FOREIGN KEY (id_carro) REFERENCES CarroCompras(id_carro);

ALTER TABLE Tienda
	ADD FOREIGN KEY (id_usuarioJ) REFERENCES Usuario(id_usuario);

ALTER TABLE ListaDeseados
	ADD FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
	ADD FOREIGN KEY (id_ranking) REFERENCES Ranking(id_ranking);

ALTER TABLE CarroCompras
	ADD FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
	ADD FOREIGN KEY (url_tienda) REFERENCES Tienda(url_tienda);

ALTER TABLE Videojuego
	ADD FOREIGN KEY (url_tienda) REFERENCES Tienda(url_tienda);

ALTER TABLE Valoracion
	ADD FOREIGN KEY (id_ranking) REFERENCES Ranking(id_ranking),
	ADD FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario);

ALTER TABLE ProcesoPago
	ADD FOREIGN KEY (id_carro) REFERENCES CarroCompras(id_carro);

-- Tabla Relaciones
CREATE TABLE VideojuegoxCarro (
    game_id INT,
	id_carro INT,
	PRIMARY KEY (game_id, id_carro)
);

CREATE TABLE VideojuegoxLista (
    game_id INT,
	id_lista INT,
	PRIMARY KEY (game_id, id_lista)
);

CREATE TABLE VideojuegoxCategoria (
    game_id INT,
	tipo_categoria VARCHAR(20),
	PRIMARY KEY (game_id, tipo_categoria)
);

CREATE TABLE VideojuegoxRanking (
    game_id INT,
	id_ranking INT,
	PRIMARY KEY (game_id, id_ranking)
);

ALTER TABLE VideojuegoxCarro
	ADD FOREIGN KEY (game_id) REFERENCES Videojuego (game_id),
	ADD FOREIGN KEY (id_carro) REFERENCES CarroCompras (id_carro);

ALTER TABLE VideojuegoxLista
	ADD FOREIGN KEY (game_id) REFERENCES Videojuego (game_id),
	ADD FOREIGN KEY (id_lista) REFERENCES ListaDeseados (id_lista);

ALTER TABLE VideojuegoxCategoria
	ADD FOREIGN KEY (game_id) REFERENCES Videojuego (game_id),
	ADD FOREIGN KEY (tipo_categoria) REFERENCES Categoria (tipo_categoria);

ALTER TABLE VideojuegoxRanking
	ADD FOREIGN KEY (game_id) REFERENCES Videojuego (game_id),
	ADD FOREIGN KEY (id_ranking) REFERENCES Ranking (id_ranking);





	
