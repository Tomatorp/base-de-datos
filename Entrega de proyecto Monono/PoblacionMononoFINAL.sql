--Poblacion

----------------------------Poblacion Ranking------------------------------------------
INSERT INTO Ranking (id_ranking, tipo_ranking)
VALUES (0,'Mas Valorados'), (1, 'Mas Deseados');

----------------------------Poblacion Tienda------------------------------------------
INSERT INTO Tienda (url_tienda, nombre_tienda, id_usuarioj)
VALUES ('monono.store','Monono',NULL);


----------------------------Poblacion Jefe Tienda------------------------------------------
INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol, id_usuarioJ, url_tienda) 
VALUES (0, 'jefe@mail.cl', 'Chadmissioners', 'clave123', 'Chile', 'Jefe de tienda', 0, 'monono.store');

UPDATE Tienda
SET id_usuarioJ=0 -- usuario jefe
WHERE Tienda.url_tienda='monono.store';


----------------------------Poblacion Categorias------------------------------------------
INSERT INTO Categoria (tipo_categoria) 
VALUES ('terror'),('accion'), ('shooter'), ('aventura'), ('cooperativo');


----------------------------Poblacion Paises------------------------------------------
INSERT INTO Pais (pais)
VALUES ('Chile'), ('China'), ('Estados Unidos'), ('Brasil'), ('Argentina');

----------------------------Poblacion Usuario------------------------------------------
INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol) 
VALUES (1, 'nachosopa282@gmail.com', 'Nachopaltax', 'EnragedSpace', 'Chile', 'Cliente'),
		(4, 'copiadebenzo33@gmail.com', 'Mythikal', 'StarPlatinum333', 'China', 'Cliente'),
		(5, 'iliketouhou@gmail.com', 'Yista77', 'givemec00kies', 'Estados Unidos', 'Cliente');
       

----------------------------Poblacion Videojuego------------------------------------------
INSERT INTO Videojuego ( game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador)
VALUES ( 2, 'Dead by Daylight', 12000, 'imgur/xxxxx', 30, 6, 'Behaviour Interactive Inc.'),
       ( 3, 'ELDEN RING NIGHTREIGN', 32000, 'imgur/xxxxx', 70, 10, 'FromSoftware, Inc.'),
	   ( 5, 'Team Fortress 2', 10000, 'imgur/xxxxx', 10, 10, 'Valve Software'),
	   ( 6, 'Sonic Unleashed', 20000, 'imgur/xxxxx', 20, 23, 'SEGA');

SELECT restringir_videojuego_en_pais('Dead by Daylight', 'Chile');
SELECT restringir_videojuego_en_pais('ELDEN RING NIGHTREIGN', 'China');
SELECT restringir_videojuego_en_pais('Team Fortress 2', 'Estados Unidos');

----------------------------Poblacion Valoraciones------------------------------------------
SELECT registrar_valoracion('Mythikal', 'Team Fortress 2', TRUE, 'R.I.P Rick May');
SELECT registrar_valoracion('Mythikal', 'Sonic Unleashed', TRUE, 'I keep trying to beat my record');
SELECT registrar_valoracion('Yista77', 'Sonic Unleashed', TRUE, 'I HATE sonic but i love the music');

----------------------------Poblacion Categorias PT 2-------------------------------------
INSERT INTO VideojuegoxCategoria (game_id, tipo_categoria)
VALUES (2, 'terror'), (3, 'aventura'), (5, 'shooter'), (6, 'accion');
