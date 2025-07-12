-- TC01	Registro de usuario	
-- Insertar usuario con datos válidos y rol 'Jefe de tienda'
   -- COMANDO: INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol, url_tienda) 
   -- NOTA: insertar un id != 0 y id!= 1
	INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol) 
	VALUES (2, 'supmawall@gmail.com','Rufax','cosito123','Chile','Jefe de tienda');

	SELECT *
	FROM Usuario;

-- TC02 Registro de usuario 
-- Insertar usuario con correo NULL (error)
	-- COMANDO: INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol, url_tienda)
	INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol)
	VALUES (3, NULL, 'Zetarro', 'bayonett3331', 'Chile', 'Cliente');

-- TC03 Registro de usuario
-- Insertar usuario con rol inexistente (error)
	-- COMANDO: INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol, url_tienda)
	INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol)
	VALUES (3, 'pedrozeiss@gmail.com', 'Zetarro', 'bayonett3331', 'Chile', 'Dios');

-- TC04 Registro de usuario
-- Insertar usuario cliente con datos validos
	-- COMANDO: INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol, url_tienda)
	INSERT INTO Usuario (id_usuario, correo, username, clave, pais, rol)
	VALUES (3, 'pedrozeiss@gmail.com', 'Zetarro', 'bayonett3331', 'Chile', 'Cliente');

	SELECT *
	FROM Usuario;

-- TC05 Registro de videojuego
-- Insertar videojuego con stock negativo (error)
	-- COMANDO: INSERT INTO Videojuego ( game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador)
	INSERT INTO Videojuego ( game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador)
	VALUES ( 1, 'Grand Theft Auto V Legacy', 40000, 'imgur/xxxxx', 100, -10, 'Rockstar North');

-- TC06 Registro de videojuego
-- Intentar insertar videojuego con categoria inexistente
	-- COMANDO: INSERT INTO VideojuegoxCategoria (game_id, tipo_categoria) (para un juego que exista)
	INSERT INTO VideojuegoxCategoria (game_id, tipo_categoria)
	VALUES (3,'deporte extremo');

-- TC07 Registro de videojuego
-- Insertar videojuego con datos validos
	-- COMANDO: INSERT INTO Videojuego ( game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador)
	INSERT INTO Videojuego ( game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador)
	VALUES ( 1, 'Grand Theft Auto V Legacy', 40000, 'imgur/xxxxx', 100, 10, 'Rockstar North');

	SELECT *
	FROM Videojuego;

-- TC08 Usuario jefe actualiza datos de juego publicado
	--COMANDO: SELECT actualizar_videojuego_full(id_usuario , game_id,game_name,game_price,url_imagen,ventas,stock,desarrollador);
	--NOTA: El id_usuario es del usuario que supuestamente estaria intentando usar el comando
	SELECT actualizar_videojuego_full(0, 1,NULL,46000,NULL,NULL,NULL,NULL);

	SELECT *
	FROM Videojuego;

	SELECT actualizar_videojuego_full(1, 1,NULL,46000,NULL,NULL,NULL,NULL); -- <- caso cuando es cliente y no jefe

-- TC09 Usuario agrega videojuego a su lista de deseados
	--COMANDO: SELECT agregar_juego_a_lista_deseos('username', 'gamename');
	SELECT agregar_juego_a_lista_deseos('Nachopaltax', 'Grand Theft Auto V Legacy');


	SELECT U.username, V.game_name AS ListaDeseos
	FROM	((Usuario as U INNER JOIN ListaDeseados as L ON U.id_usuario=L.id_usuario) 
			INNER JOIN VideojuegoxLista as VL ON L.id_lista=VL.id_lista)
			INNER JOIN Videojuego as V ON VL.game_id=V.game_id;

-- TC10 Usuario agrega videojuego a su lista de deseados
-- Usuario intenta agregar dos veces el mismo juego (error)
	--COMANDO: SELECT agregar_juego_a_lista_deseos('username', 'gamename');
	SELECT agregar_juego_a_lista_deseos('Nachopaltax', 'Grand Theft Auto V Legacy');

-- TC11 Mostrar lista deseos de usuario
	--COMANDO: SELECT *
	--         FROM mostrar_lista_deseos('username');
	SELECT *
	FROM mostrar_lista_deseos('Nachopaltax');

-- TC12 Carro de compras
-- Agregar un producto al carro de compras de un usuario
	--COMANDO: SELECT agregar_al_carrito('username', 'game_name', cantidad)
	SELECT agregar_al_carrito('Nachopaltax', 'Grand Theft Auto V Legacy', 1);

-- TC13 Carro de compras
-- Mostrar carro de compras de un usuario
	--COMANDO: SELECT * FROM mostrar_carrito_usuario('username');
	SELECT * FROM mostrar_carrito_usuario('Nachopaltax');

-- TC14 Carro de compras
-- Mostrar total del carrito de compras de un usuario
	--COMANDO: SELECT total_carrito_usuario('Username');
	SELECT total_carrito_usuario('Nachopaltax');

-- TC15 Carro de compras
-- Eliminar un producto del carro de compras
	--COMANDO: SELECT eliminar_del_carrito('username','gamename',cantidad);
	SELECT eliminar_del_carrito('Nachopaltax','Grand Theft Auto V Legacy',1);

-- TC16 Carro de compras
-- Cliente agrega videojuegos con stock disponible
	--COMANDO: SELECT agregar_al_carrito('username', 'game_name', cantidad)
	SELECT agregar_al_carrito('Nachopaltax', 'Grand Theft Auto V Legacy', 3);

-- TC17 Carro de compras
-- Cliente intenta agregar mas videojuegos al carrito del stock disponible (error)
	--COMANDO: SELECT agregar_al_carrito('username', 'game_name', cantidad)
	SELECT agregar_al_carrito('Nachopaltax', 'Grand Theft Auto V Legacy', 10);

-- TC18 Validacion Stock
-- Usuario intenta pagar cuando no hay stock de un juego 
	--COMANDO: SELECT procesar_pago_carrito('Username', 'Metodo de pago');
	SELECT actualizar_videojuego_full(0, 1,NULL,NULL,NULL,NULL,0,NULL); -- Nachopaltax tiene en su carro GTAV y actualizaremos para que no tenga stock
	SELECT procesar_pago_carrito('Nachopaltax', 'Debito');

-- TC19 Validacion Stock
-- Usuario intenta pagar con stock disponible de un juego
	--COMANDO: SELECT procesar_pago_carrito('Username', 'Metodo de pago');
	SELECT actualizar_videojuego_full(0, 1,NULL,NULL,NULL,NULL,3,NULL); -- Volvemos a ponerle stock para posibilitar el pago
	SELECT procesar_pago_carrito('Nachopaltax', 'Debito');
	-- Se puede ver que se elimino del carrito, se registro en proceso de pago y actualizó stock/venta del juego
	SELECT * FROM mostrar_carrito_usuario('Nachopaltax');
	SELECT * FROM ProcesoPago;
	SELECT * FROM Videojuego;

-- TC20 Validacion pago
-- Usuario intenta pagar con metodo de pago invalido (error) solo se puede con credito, debito o transferencia
	--COMANDO: SELECT procesar_pago_carrito('Username', 'Metodo de pago');
	SELECT actualizar_videojuego_full(0, 1,NULL,NULL,NULL,NULL,3,NULL); -- Volvemos a ponerle stock
	SELECT agregar_al_carrito('Nachopaltax', 'Grand Theft Auto V Legacy', 1);

	SELECT procesar_pago_carrito('Nachopaltax', 'Monedas de oro');

-- TC21 Valoracion
-- Cliente valora videojuego
	--COMANDO: SELECT registrar_valoracion('username', 'gamename', tipo de valoracion (BOOL), 'comentario');
	SELECT registrar_valoracion('Nachopaltax', 'Grand Theft Auto V Legacy', TRUE, 'MUY BUENO BUENAZO');

	SELECT * FROM VALORACION

-- TC22 Valoracion
-- Cliente intenta valorar videojuego 2 veces (error)
	--COMANDO: SELECT registrar_valoracion('username', 'gamename', tipo de valoracion (BOOL), 'comentario');
	SELECT registrar_valoracion('Nachopaltax', 'Grand Theft Auto V Legacy', TRUE, 'OLVIDE DECIR QUE ERA BUENO');

-- TC23 Top 3 videojuegos mas vendidos
	--COMANDO: SELECT top_3_videojuegos_mas_vendidos();
	SELECT top_3_videojuegos_mas_vendidos();

	SELECT * -- si se desea comparar
	FROM Videojuego;

-- TC24 Juegos mas deseados
	--COMANDO: SELECT ranking_videojuegos_deseados();
	SELECT ranking_videojuegos_deseados();

-- TC25 Mostrar juegos por ubicacion
	--COMANDO: SELECT mostrar_juegos_que_se_venden_en_pais('Pais');
	SELECT mostrar_juegos_que_se_venden_en_pais('Chile');
	SELECT mostrar_juegos_que_se_venden_en_pais('China');
	SELECT mostrar_juegos_que_se_venden_en_pais('Estados Unidos');
	
-- TC26 Ranking productos mas vendidos
	--COMANDO: SELECT ranking_videojuegos_por_mas_vendidos();
	SELECT ranking_videojuegos_por_mas_vendidos();

-- TC27 Mostrar juegos por ubicacion de cliente
	--COMANDO: SELECT videojuegos_disponibles_para_usuario('username');
	SELECT videojuegos_disponibles_para_usuario('Nachopaltax');

-- TC28 Registro Auditoria
-- Se genere un trigger de registro de auditoria al INSERTAR un juego
	--COMANDO: Select * FROM AuditoriaVideojuegos
	INSERT INTO Videojuego ( game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador)
	VALUES (4,'Sekiro',30000,'imgur/sekiro.png',0,5,'FromSoftware'); -- Agregamos un juego y luego...

	Select * FROM AuditoriaVideojuegos;

-- TC29 Registro Auditoria
-- Se genere un trigger de registro de auditoria al UPDATEAR un juego, registrando stock anterior y stock nuevo
	--COMANDO: Select * FROM AuditoriaVideojuegos <- fijarse en accion 'UPDATE'
	SELECT actualizar_videojuego_full(0, 4,NULL,NULL,NULL,NULL,3,NULL);

	Select * FROM AuditoriaVideojuegos;

-- TC30 Trigger seguridad
-- Se genere un trigger que impida eliminar (DELETE) un juego que ya ha sido comprado
	--COMANDO: Delete From Videojuego Where game_id=?
	SELECT actualizar_videojuego_full(0, 4,NULL,NULL,NULL,1,3,NULL);

	DELETE
	FROM Videojuego
	WHERE Videojuego.game_id=4;

-- TC31 Procedimiento
-- Procedimiento de almacenado para actualizar precios de los juegos en base a una categoría
	--COMANDO: CALL actualizar_precio_categoria('categoria',aumento/descuento); NOTA: el segundo parametro toma como aumentar/descontar en % del precio
	SELECT *
	FROM Videojuego; -- revisamos los precios antes

	INSERT INTO VideojuegoxCategoria (game_id, tipo_categoria)
	VALUES (4,'aventura');

	CALL actualizar_precio_categoria('aventura',10); -- aplicamos los cambios de precios

	SELECT *
	FROM Videojuego; -- revisamos los precios nuevos

-- TC32 Procedimiento/Funcion
-- Procedimiento/funcion que muestre el reporte de ventas de un usuario
	--COMANDO:  Select * FROM obtener_reporte_ventas_usuario('username');
	Select * FROM obtener_reporte_ventas_usuario('Nachopaltax');

	