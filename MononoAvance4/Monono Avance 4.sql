-- Tablas Normales

CREATE TABLE Ranking (
	id_ranking INT PRIMARY KEY,
	tipo_ranking VARCHAR(20)
);

CREATE TABLE Categoria(
	tipo_categoria VARCHAR(20) PRIMARY KEY
);

CREATE TABLE Pais(
	pais VARCHAR(48) PRIMARY KEY
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

CREATE TABLE VideojuegoxPais (
	game_id INT,
	pais VARCHAR(48),
	PRIMARY KEY (game_id, pais)
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

ALTER TABLE VideojuegoxPais 
	ADD FOREIGN KEY (game_id) REFERENCES Videojuego (game_id),
	ADD FOREIGN KEY (pais) REFERENCES Pais (pais);

-- Trigger para crear automaticamente Lista y carro de usuario al insertarlo
	CREATE OR REPLACE FUNCTION crear_lista_y_carro()
	RETURNS TRIGGER AS $$
	BEGIN
	    -- Crear lista de deseados
	    INSERT INTO ListaDeseados(id_lista, id_usuario)
	    VALUES (NEW.id_usuario, NEW.id_usuario);
	
	    -- Crear carro de compras con el mismo url_tienda del usuario
	    INSERT INTO CarroCompras(id_carro, id_usuario, total, url_tienda)
	    VALUES (NEW.id_usuario, NEW.id_usuario, 0, NEW.url_tienda);
	
	    RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

	CREATE TRIGGER trg_crear_lista_y_carro
	AFTER INSERT ON Usuario
	FOR EACH ROW
	EXECUTE FUNCTION crear_lista_y_carro();

	


-- TC05 Restriccion stock negativo
	ALTER TABLE Videojuego
	ADD CONSTRAINT chk_stock_non_negative CHECK (stock >= 0);
	
	ALTER TABLE VideojuegoxCarro
	ADD COLUMN cantidad INT DEFAULT 1 CHECK (cantidad > 0);

-- TC08 Actualizar juego si se es jefe
	CREATE OR REPLACE FUNCTION actualizar_videojuego_full(
	    p_usuario_id INT,
	    p_game_id INT,
	    p_game_name VARCHAR DEFAULT NULL,
	    p_game_price INT DEFAULT NULL,
	    p_url_imagen VARCHAR DEFAULT NULL,
	    p_ventas INT DEFAULT NULL,
	    p_stock INT DEFAULT NULL,
	    p_desarrollador VARCHAR DEFAULT NULL
	)
	RETURNS VOID AS $$
	DECLARE
	    v_dueno_id INT;
	BEGIN
	    -- Verificar que el usuario sea dueño de la tienda 'monono.store'
	    SELECT id_usuarioJ INTO v_dueno_id
	    FROM Tienda
	    WHERE url_tienda = 'monono.store';
	
	    IF v_dueno_id IS DISTINCT FROM p_usuario_id THEN
	        RAISE EXCEPTION 'Permiso denegado: El usuario % no es jefe de la tienda monono.store.', p_usuario_id;
	    END IF;
	
	    -- Actualizar solo los campos que no sean NULL
	    UPDATE Videojuego
	    SET
	        game_name = COALESCE(p_game_name, game_name),
	        game_price = COALESCE(p_game_price, game_price),
	        url_imagen = COALESCE(p_url_imagen, url_imagen),
	        ventas = COALESCE(p_ventas, ventas),
	        stock = COALESCE(p_stock, stock),
	        desarrollador = COALESCE(p_desarrollador, desarrollador)
	    WHERE game_id = p_game_id
	      AND url_tienda = 'monono.store';
	
	    RAISE NOTICE 'Videojuego actualizado correctamente.';
	END;
	$$ LANGUAGE plpgsql;

-- TC09 Usuario añade un juego a su lista
	CREATE OR REPLACE FUNCTION agregar_juego_a_lista_deseos( p_username VARCHAR, p_game_name VARCHAR )
	RETURNS VOID AS $$
	DECLARE
	    v_usuario_id INT;
	    v_game_id INT;
	    v_id_lista INT;
	BEGIN
	    -- Recoleccion de ID usuario
	    SELECT id_usuario INTO v_usuario_id
	    FROM Usuario
	    WHERE username = p_username;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'Usuario "%" no encontrado.', p_username;
	    END IF;
	
	    -- Recoleccion de ID juego
	    SELECT game_id INTO v_game_id
	    FROM Videojuego
	    WHERE game_name = p_game_name;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'Videojuego "%" no encontrado.', p_game_name;
	    END IF;
	
	    -- Obtener la lista de deseos 
	    SELECT id_lista INTO v_id_lista
	    FROM ListaDeseados
	    WHERE id_usuario = v_usuario_id;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El usuario "%" no tiene una lista de deseos.', p_username;
	    END IF;
	
	    -- Se inserta el juego en la lista
	    INSERT INTO VideojuegoxLista (game_id, id_lista)
	    VALUES (v_game_id, v_id_lista);
	
	    RAISE NOTICE 'Juego "%" agregado a la lista de deseos del usuario "%".', p_game_name, p_username;
	END;
	$$ LANGUAGE plpgsql;

--TC11 Mostrar lista deseos de usuario
	CREATE OR REPLACE FUNCTION mostrar_lista_deseos(p_username VARCHAR)
	RETURNS TABLE (
	    username VARCHAR,
	    juego VARCHAR
	) AS $$
	BEGIN
	    RETURN QUERY
	    SELECT U.username, V.game_name
	    FROM ((Usuario AS U
	        INNER JOIN ListaDeseados AS L ON U.id_usuario = L.id_usuario)
	        INNER JOIN VideojuegoxLista AS VL ON L.id_lista = VL.id_lista)
	        INNER JOIN Videojuego AS V ON VL.game_id = V.game_id
	    WHERE U.username = p_username;
	END;
	$$ LANGUAGE plpgsql;

--TC12 Función para agregar juegos a un carro de compras de un usuario + TC16 verificacion STOCK
	CREATE OR REPLACE FUNCTION agregar_al_carrito( p_username VARCHAR, p_game_name VARCHAR, p_cantidad INT)
	RETURNS VOID AS $$
	DECLARE
	    v_id_carro INT;
	    v_game_id INT;
	    v_precio_unitario INT;
	    v_stock_disponible INT;
	    v_cantidad_actual INT := 0;
	BEGIN
	    -- Obtener el carrito del usuario
	    SELECT C.id_carro INTO v_id_carro
	    FROM Usuario U
	    JOIN CarroCompras C ON U.id_usuario = C.id_usuario
	    WHERE U.username = p_username;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El usuario "%" no tiene un carrito asignado.', p_username;
	    END IF;
	
	    -- Obtener ID, precio y stock del juego
	    SELECT game_id, game_price, stock INTO v_game_id, v_precio_unitario, v_stock_disponible
	    FROM Videojuego
	    WHERE game_name = p_game_name;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El videojuego "%" no existe.', p_game_name;
	    END IF;
	
	    -- Obtener la cantidad actual en el carrito (si es que hay) 
		SELECT cantidad INTO v_cantidad_actual
		FROM VideojuegoxCarro
		WHERE game_id = v_game_id AND id_carro = v_id_carro;
		
		-- Si no existe, entonces asignamos 0
		-- Esta es una medida de seguridad porque se podia llegar y añadir 5, saltandose el stock
		IF NOT FOUND THEN
		    v_cantidad_actual := 0;
		END IF;
	
	
	    -- Verificar si el total nuevo supera el stock
	    IF v_cantidad_actual + p_cantidad > v_stock_disponible THEN
	        RAISE EXCEPTION 'No se puede agregar %. Stock disponible: %, ya en carrito: %, intentado agregar: %.',
	            p_game_name, v_stock_disponible, v_cantidad_actual, p_cantidad;
	    END IF;
	
	    -- Agregar o actualizar en el carrito
	    IF v_cantidad_actual > 0 THEN
	        UPDATE VideojuegoxCarro
	        SET cantidad = cantidad + p_cantidad
	        WHERE game_id = v_game_id AND id_carro = v_id_carro;
	    ELSE
	        INSERT INTO VideojuegoxCarro (game_id, id_carro, cantidad)
	        VALUES (v_game_id, v_id_carro, p_cantidad);
	    END IF;
	
	    -- Actualizar total del carrito
	    UPDATE CarroCompras
	    SET total = (
	        SELECT SUM(VJ.game_price * VC.cantidad)
	        FROM VideojuegoxCarro VC
	        JOIN Videojuego VJ ON VC.game_id = VJ.game_id
	        WHERE VC.id_carro = v_id_carro
	    )
	    WHERE id_carro = v_id_carro;
	
	    RAISE NOTICE 'Juego "%" agregado correctamente al carrito del usuario "%".', p_game_name, p_username;
	END;
	$$ LANGUAGE plpgsql;

	
--TC13 Funcion que muestra el carrito de compras
	CREATE OR REPLACE FUNCTION mostrar_carrito_usuario(p_username VARCHAR)
	RETURNS TABLE ( username VARCHAR, juego VARCHAR, precio_unitario INT, cantidad INT) 
	AS $$
	BEGIN
	    -- Muestra el username, nombre del juego, precio y cantidad
	    RETURN QUERY
	    SELECT U.username, VJ.game_name, VJ.game_price, VC.cantidad
	    FROM Usuario U
	    JOIN CarroCompras C ON U.id_usuario = C.id_usuario
	    JOIN VideojuegoxCarro VC ON C.id_carro = VC.id_carro
	    JOIN Videojuego VJ ON VC.game_id = VJ.game_id
	    WHERE U.username = p_username;
	END;
	$$ LANGUAGE plpgsql;

--TC14 Funcion que muestra el total de el carrito
	CREATE OR REPLACE FUNCTION total_carrito_usuario(p_username VARCHAR)
	RETURNS INT AS $$
	DECLARE
	    v_total INT;
	BEGIN
	    SELECT C.total INTO v_total -- El total es calculado cuando se añaden productos al carro
	    FROM CarroCompras C
	    JOIN Usuario U ON C.id_usuario = U.id_usuario
	    WHERE U.username = p_username;
	
	    IF v_total IS NULL THEN
	        RETURN 0;
	    END IF;
	
	    RETURN v_total;
	END;
	$$ LANGUAGE plpgsql;

--TC15 Funcion para eliminar un producto (cantidades) de el carrito
	CREATE OR REPLACE FUNCTION eliminar_del_carrito( p_username VARCHAR, p_game_name VARCHAR, p_cantidad INT )
	
	RETURNS VOID AS $$
	DECLARE
	    v_id_carro INT;
	    v_game_id INT;
	    v_cantidad_actual INT;
	BEGIN
	    -- Recoleccion ID del carro en base al username
	    SELECT C.id_carro INTO v_id_carro
	    FROM CarroCompras C
	    JOIN Usuario U ON U.id_usuario = C.id_usuario
	    WHERE U.username = p_username;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El usuario "%" no tiene un carrito.', p_username;
	    END IF;
	
	    -- Recoleccion id juego
	    SELECT game_id INTO v_game_id
	    FROM Videojuego
	    WHERE game_name = p_game_name;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El videojuego "%" no existe.', p_game_name;
	    END IF;
	
	    -- Obtener cantidad copias del juego en el carrito
	    SELECT cantidad INTO v_cantidad_actual
	    FROM VideojuegoxCarro
	    WHERE game_id = v_game_id AND id_carro = v_id_carro;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El juego "%" no está en el carrito del usuario "%".', p_game_name, p_username;
	    END IF;
	
	    -- confirmar si excede el valor a eliminar -> si ocurre elimina todos, sino solo elimina la cantidad seleccionada
	    IF p_cantidad >= v_cantidad_actual THEN
	        DELETE FROM VideojuegoxCarro
	        WHERE game_id = v_game_id AND id_carro = v_id_carro;
	    ELSE
	        UPDATE VideojuegoxCarro
	        SET cantidad = cantidad - p_cantidad
	        WHERE game_id = v_game_id AND id_carro = v_id_carro;
	    END IF;
	
	    -- Actualizar el total del carrito
	    UPDATE CarroCompras
	    SET total = (
	        SELECT COALESCE(SUM(VJ.game_price * VC.cantidad), 0)
	        FROM VideojuegoxCarro VC
	        JOIN Videojuego VJ ON VC.game_id = VJ.game_id
	        WHERE VC.id_carro = v_id_carro
	    )
	    WHERE id_carro = v_id_carro;
	
	    RAISE NOTICE 'Juego "%" eliminado del carrito del usuario "%".', p_game_name, p_username;
	
	END;
	$$ LANGUAGE plpgsql;
--TC18 Funcion que procesa el pago del carrito de un usuario, donde crea boleta, valida stock + descuenta y limpia carrito
	CREATE OR REPLACE FUNCTION procesar_pago_carrito(
	    p_username VARCHAR,
	    p_metodo_pago VARCHAR
	)
	RETURNS VOID AS $$
	DECLARE
	    v_id_usuario INT;
	    v_id_carro INT;
	    v_total INT;
	    v_fecha DATE := CURRENT_DATE;
	    v_id_boleta INT;
	    v_game_id INT;
	    v_cantidad INT;
	    v_stock_actual INT;
	BEGIN
	    -- Obtener ID del usuario
	    SELECT id_usuario INTO v_id_usuario
	    FROM Usuario
	    WHERE username = p_username;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El usuario % no existe.', p_username;
	    END IF;
	
	    -- Obtener ID del carrito y total
	    SELECT id_carro, total INTO v_id_carro, v_total
	    FROM CarroCompras
	    WHERE id_usuario = v_id_usuario;
	
	    IF NOT FOUND THEN
	        RAISE EXCEPTION 'El usuario % no tiene un carrito asignado.', p_username;
	    END IF;

		--verificacion si el carro esta vacio
		IF NOT EXISTS (
		    SELECT 1
		    FROM VideojuegoxCarro
		    WHERE id_carro = v_id_carro
		) THEN
		    RAISE EXCEPTION 'El carrito de compras está vacío. No se puede procesar el pago.';
		END IF;		
	
	    -- Validar que haya stock suficiente para cada producto
	    FOR v_game_id, v_cantidad IN
	        SELECT VC.game_id, VC.cantidad
	        FROM VideojuegoxCarro VC
	        WHERE VC.id_carro = v_id_carro
	    LOOP
	        SELECT stock INTO v_stock_actual
	        FROM Videojuego
	        WHERE game_id = v_game_id;
	
	        IF v_cantidad > v_stock_actual THEN
	            RAISE EXCEPTION 'Stock insuficiente para el juego ID % (stock: %, en carrito: %)',
	                v_game_id, v_stock_actual, v_cantidad;
	        END IF;
	    END LOOP;
	
	    -- Insertar boleta en ProcesoPago
	    INSERT INTO ProcesoPago (id_boleta, metodo_pago, fechaC, id_carro, total)
	    VALUES (
	        DEFAULT, p_metodo_pago, v_fecha, v_id_carro, v_total
	    )
	    RETURNING id_boleta INTO v_id_boleta;
		
		-- Guardar en ReporteVentas ------------------------------------------------------------------ TC32
		FOR v_game_id, v_cantidad IN
		    SELECT VC.game_id, VC.cantidad
		    FROM VideojuegoxCarro VC
		    WHERE VC.id_carro = v_id_carro
		LOOP
		INSERT INTO ReporteVentas (
		    id_usuario, game_id, game_name, cantidad, total_pagado, fecha_compra, metodo_pago, id_boleta
		)
		SELECT 
		    v_id_usuario,
		    VJ.game_id,
		    VJ.game_name,
		    v_cantidad,
		    VJ.game_price * v_cantidad,
		    v_fecha,
		    p_metodo_pago,
		    v_id_boleta
		FROM Videojuego VJ
		WHERE VJ.game_id = v_game_id;
		END LOOP;
		
	
	    -- Descontar stock de los productos comprados y aumentar las ventas
	    FOR v_game_id, v_cantidad IN
	        SELECT VC.game_id, VC.cantidad
	        FROM VideojuegoxCarro VC
	        WHERE VC.id_carro = v_id_carro
	    LOOP
	        UPDATE Videojuego
	        SET 
	            stock = stock - v_cantidad,
	            ventas = ventas + v_cantidad
	        WHERE game_id = v_game_id;
	    END LOOP;
	
	    -- Limpiar carrito del usuario
	    DELETE FROM VideojuegoxCarro
	    WHERE id_carro = v_id_carro;
	
	    -- Reiniciar total
	    UPDATE CarroCompras
	    SET total = 0
	    WHERE id_carro = v_id_carro;
	
	    RAISE NOTICE 'Pago procesado correctamente. ID de boleta: %', v_id_boleta;
	END;
	$$ LANGUAGE plpgsql;

--Generar id_boletas de manera automatica
ALTER TABLE ProcesoPago
ALTER COLUMN id_boleta DROP DEFAULT,
ALTER COLUMN id_boleta ADD GENERATED BY DEFAULT AS IDENTITY;

--Generar id_valoraciones de manera automatica
ALTER TABLE Valoracion
ALTER COLUMN id_valoracion
ADD GENERATED BY DEFAULT AS IDENTITY;


--TC21 Usuario crear valoraciones a videojuegos + TC22 con excepcion de que no se pueda valorar 2 veces el mismo juego
		CREATE OR REPLACE FUNCTION registrar_valoracion( p_username VARCHAR, p_game_name VARCHAR, p_tipo_valoracion BOOLEAN, p_comentario VARCHAR )
		RETURNS VOID AS $$
		DECLARE
		    v_id_usuario INT;
		    v_game_id INT;
		BEGIN
		    -- Obtener ID del usuario
		    SELECT id_usuario INTO v_id_usuario
		    FROM Usuario
		    WHERE username = p_username;
		
		    IF NOT FOUND THEN
		        RAISE EXCEPTION 'Usuario "%" no encontrado.', p_username;
		    END IF;
		
		    -- Obtener ID del juego
		    SELECT game_id INTO v_game_id
		    FROM Videojuego
		    WHERE game_name = p_game_name;
		
		    IF NOT FOUND THEN
		        RAISE EXCEPTION 'Juego "%" no encontrado.', p_game_name;
		    END IF;
		
		    -- Validar si ya existe una valoración del usuario para ese juego
		    IF EXISTS (
		        SELECT 1 FROM Valoracion
		        WHERE id_usuario = v_id_usuario AND game_id = v_game_id
		    ) THEN
		        RAISE EXCEPTION 'El usuario "%" ya ha valorado el juego "%".', p_username, p_game_name;
		    END IF;
		
		    -- Insertar valoración con id_ranking = 0
		    INSERT INTO Valoracion (
		        fechaV, id_ranking, game_id, comentario, tipo_valoracion, id_usuario
		    ) VALUES (
		        CURRENT_DATE, 0, v_game_id, p_comentario, p_tipo_valoracion, v_id_usuario
		    );
		
		    RAISE NOTICE 'Valoración registrada para usuario % y juego %', p_username, p_game_name;
		END;
		$$ LANGUAGE plpgsql;

--TC23 TOP 3 juegos mas vendidos
		CREATE OR REPLACE FUNCTION top_3_videojuegos_mas_vendidos()
		RETURNS TABLE (
		    game_name VARCHAR(35),
		    ventas INT
		) AS $$
		BEGIN
		    RETURN QUERY
		    SELECT Videojuego.game_name, Videojuego.ventas
		    FROM Videojuego
		    ORDER BY ventas DESC
		    LIMIT 3;
		END;
		$$ LANGUAGE plpgsql;

--TC24 Ranking juegos mas deseados 
		CREATE OR REPLACE FUNCTION ranking_videojuegos_deseados()
		RETURNS TABLE ( game_name VARCHAR(35), cantidad_deseos BIGINT ) AS $$
		BEGIN
		    RETURN QUERY
		    SELECT V.game_name, COUNT(*) AS cantidad_deseos
		    FROM VideojuegoxLista VL
		    JOIN Videojuego V ON VL.game_id = V.game_id
		    GROUP BY V.game_name
		    ORDER BY cantidad_deseos DESC;
		END;
		$$ LANGUAGE plpgsql;

--TC25
		CREATE OR REPLACE FUNCTION mostrar_juegos_que_se_venden_en_pais(p_pais VARCHAR)
		RETURNS TABLE ( game_name VARCHAR(35) ) AS $$
		BEGIN
		    RETURN QUERY
		    SELECT V.game_name
		    FROM Videojuego V
		    WHERE V.game_id NOT IN (
		        SELECT Videojuegoxpais.game_id
		        FROM VideojuegoxPais
		        WHERE pais = p_pais
		    );
		END;
		$$ LANGUAGE plpgsql;


-- FUNCIONES PARA ACTUALIZAR RESTRINGIR/HABILITAR PAISES EN VIDEOJUEGOS
		CREATE OR REPLACE FUNCTION restringir_videojuego_en_pais(
		    p_game_name VARCHAR,
		    p_pais VARCHAR
		)
		RETURNS VOID AS $$
		DECLARE
		    v_game_id INT;
		BEGIN
		    -- Obtener ID del juego
		    SELECT game_id INTO v_game_id
		    FROM Videojuego
		    WHERE game_name = p_game_name;
		
		    IF NOT FOUND THEN
		        RAISE EXCEPTION 'Juego "%" no encontrado.', p_game_name;
		    END IF;
		
		    -- Verificar si ya está restringido
		    IF EXISTS (
		        SELECT 1 FROM VideojuegoxPais
		        WHERE game_id = v_game_id AND pais = p_pais
		    ) THEN
		        RAISE NOTICE 'El juego "%" ya está restringido en "%".', p_game_name, p_pais;
		        RETURN;
		    END IF;
		
		    -- Insertar restricción
		    INSERT INTO VideojuegoxPais (game_id, pais)
		    VALUES (v_game_id, p_pais);
		
		    RAISE NOTICE 'Juego "%" ahora está restringido en "%".', p_game_name, p_pais;
		END;
		$$ LANGUAGE plpgsql;

------------------------------
		CREATE OR REPLACE FUNCTION habilitar_videojuego_en_pais(
		    p_game_name VARCHAR,
		    p_pais VARCHAR
		)
		RETURNS VOID AS $$
		DECLARE
		    v_game_id INT;
		BEGIN
		    -- Obtener ID del juego
		    SELECT game_id INTO v_game_id
		    FROM Videojuego
		    WHERE game_name = p_game_name;
		
		    IF NOT FOUND THEN
		        RAISE EXCEPTION 'Juego "%" no encontrado.', p_game_name;
		    END IF;
		
		    -- Verificar si la restricción existe
		    IF NOT EXISTS (
		        SELECT 1 FROM VideojuegoxPais
		        WHERE game_id = v_game_id AND pais = p_pais
		    ) THEN
		        RAISE NOTICE 'El juego "%" ya está habilitado en "%".', p_game_name, p_pais;
		        RETURN;
		    END IF;
		
		    -- Eliminar restricción
		    DELETE FROM VideojuegoxPais
		    WHERE game_id = v_game_id AND pais = p_pais;
		
		    RAISE NOTICE 'Juego "%" ahora está habilitado en "%".', p_game_name, p_pais;
		END;
		$$ LANGUAGE plpgsql;

--TC26 Ranking productos basado en ventas
		CREATE OR REPLACE FUNCTION ranking_videojuegos_por_mas_vendidos()
		RETURNS TABLE (
		    game_name VARCHAR(35),
		    ventas INT
		) AS $$
		BEGIN
		    RETURN QUERY
		    SELECT Videojuego.game_name, Videojuego.ventas
		    FROM Videojuego
		    ORDER BY ventas DESC;
		END;
		$$ LANGUAGE plpgsql;

--TC27 Filtro por ubicacion del cliente
		CREATE OR REPLACE FUNCTION videojuegos_disponibles_para_usuario(
		    p_username VARCHAR
		)
		RETURNS TABLE (
		    game_name VARCHAR(35)
		) AS $$
		BEGIN
		    RETURN QUERY
		    SELECT V.game_name
		    FROM Usuario U
		    JOIN CarroCompras C ON U.id_usuario = C.id_usuario
		    JOIN Videojuego V ON V.url_tienda = C.url_tienda
		    LEFT JOIN VideojuegoxPais VP 
		        ON V.game_id = VP.game_id AND VP.pais = U.pais
		    WHERE U.username = p_username
		      AND VP.pais IS NULL;
		END;
		$$ LANGUAGE plpgsql;

-- TC28 + TC29 Trigger auditoría INSERT/UPDATE
		CREATE TABLE AuditoriaVideojuegos (
		    id_auditoria SERIAL PRIMARY KEY,
		    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		    id_usuario INT,
		    accion VARCHAR(10),               --acciones como 'INSERT' o 'UPDATE'
		    game_id INT,
		    game_name VARCHAR(35),
		    stock_anterior INT,
		    stock_nuevo INT
		);
		-- Funcion registrar auditoria
		CREATE OR REPLACE FUNCTION registrar_auditoria_videojuego()
		RETURNS TRIGGER AS $$
		BEGIN
		    IF TG_OP = 'INSERT' THEN
		        -- Auditoría de INSERT
		        INSERT INTO AuditoriaVideojuegos (
		            id_usuario, accion, game_id, game_name
		        ) VALUES (
		            0, 'INSERT', NEW.game_id, NEW.game_name
		        );
		
		    ELSIF TG_OP = 'UPDATE' THEN
		        -- registro si cambia stock
		        IF OLD.stock IS DISTINCT FROM NEW.stock THEN
		            INSERT INTO AuditoriaVideojuegos (
		                id_usuario, accion, game_id, game_name, stock_anterior, stock_nuevo
		            ) VALUES (
		                0, 'UPDATE', NEW.game_id, NEW.game_name, OLD.stock, NEW.stock
		            );
		        END IF;
		    END IF;
		
		    RETURN NEW;
		END;
		$$ LANGUAGE plpgsql;
		-- Disparador de registrar auditoria en INSERT
		CREATE TRIGGER trigger_auditoria_insert_videojuego
		AFTER INSERT ON Videojuego
		FOR EACH ROW
		EXECUTE FUNCTION registrar_auditoria_videojuego();
		-- Disparador de registrar auditoria en UPDATE stock
		CREATE TRIGGER trigger_auditoria_update_stock
		AFTER UPDATE ON Videojuego
		FOR EACH ROW
		WHEN (OLD.stock IS DISTINCT FROM NEW.stock)
		EXECUTE FUNCTION registrar_auditoria_videojuego();

		-- Comando para insertar videojuego donde se ingresa el id del usuario para verificar y asi no usar insert directamente
		CREATE OR REPLACE FUNCTION agregar_videojuego_full(
		    p_usuario_id INT,
		    p_game_id INT,
		    p_game_name VARCHAR,
		    p_game_price INT,
		    p_url_imagen VARCHAR,
		    p_ventas INT,
		    p_stock INT,
		    p_desarrollador VARCHAR,
		    p_url_tienda VARCHAR
		)
		RETURNS VOID AS $func$
		DECLARE
		    v_rol_usuario VARCHAR(20);
		BEGIN
		    -- Verificar que el usuario sea jefe
		    SELECT rol INTO v_rol_usuario
		    FROM Usuario
		    WHERE id_usuario = p_usuario_id;
		
		    IF v_rol_usuario IS DISTINCT FROM 'Jefe de tienda' THEN
		        RAISE EXCEPTION 'Permiso denegado: Solo un Jefe de tienda puede agregar videojuegos.';
		    END IF;
		
		    -- Insertar nuevo videojuego
		    INSERT INTO Videojuego (
		        game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador, url_tienda
		    ) VALUES (
		        p_game_id, p_game_name, p_game_price, p_url_imagen, p_ventas, p_stock, p_desarrollador, p_url_tienda
		    );
		
		    RAISE NOTICE 'Videojuego "%" agregado correctamente por el usuario ID %.', p_game_name, p_usuario_id;
		END;
		$func$ LANGUAGE plpgsql;

-- TC30 trigger para evitar eliminar un juego que ya ha sido comprado

		CREATE OR REPLACE FUNCTION bloquear_borrado_si_tiene_ventas()
		RETURNS TRIGGER AS $$
		BEGIN
		    IF OLD.ventas > 0 THEN
		        RAISE EXCEPTION 'Operación bloqueada: No se puede eliminar el videojuego "%", ya que tiene ventas registradas (%).',
		        OLD.game_name, OLD.ventas;
		    END IF;
		    RETURN OLD;
		END;
		$$ LANGUAGE plpgsql;

		CREATE TRIGGER trg_bloquear_borrado_si_tiene_ventas
		BEFORE DELETE ON Videojuego
		FOR EACH ROW
		EXECUTE FUNCTION bloquear_borrado_si_tiene_ventas();





-- TC31 procedure actualizar precios juegos en base a categoria
		CREATE OR REPLACE PROCEDURE actualizar_precio_categoria(
		    p_categoria VARCHAR,
		    p_porcentaje INT  -- ejemplo 10 para +10%, -10 para -10%
		)
		LANGUAGE plpgsql
		AS $$
		BEGIN
		    UPDATE Videojuego V
		    SET game_price = ROUND(game_price * (1 + p_porcentaje / 100.0))
		    WHERE V.game_id IN (
		        SELECT VC.game_id
		        FROM VideojuegoxCategoria VC
		        WHERE VC.tipo_categoria = p_categoria
		    );
		
		    RAISE NOTICE 'Precios actualizados en la categoría "%". Cambio aplicado: %%%.', p_categoria, p_porcentaje;
		END;
		$$;
	-- Funcion y Trigger para recalcular totales automaticamente
		CREATE OR REPLACE FUNCTION recalcular_totales_carros()
		RETURNS TRIGGER AS $$
		BEGIN
		    -- Actualiza todos los carros afectados por el videojuego cuyo precio cambió
		    UPDATE CarroCompras
		    SET total = (
		        SELECT COALESCE(SUM(VJ.game_price * VC.cantidad), 0)
		        FROM VideojuegoxCarro VC
		        JOIN Videojuego VJ ON VC.game_id = VJ.game_id
		        WHERE VC.id_carro = CarroCompras.id_carro
		    )
		    WHERE id_carro IN (
		        SELECT id_carro
		        FROM VideojuegoxCarro
		        WHERE game_id = NEW.game_id
		    );
		
		    RETURN NEW;
		END;
		$$ LANGUAGE plpgsql;
	-- TRIGGER
		CREATE TRIGGER trigger_recalcular_total_carros
		AFTER UPDATE OF game_price ON Videojuego
		FOR EACH ROW
		EXECUTE FUNCTION recalcular_totales_carros();
		
--TC32 Reporte ventas usuario

		CREATE TABLE ReporteVentas (
		    id_reporte SERIAL PRIMARY KEY,
		    id_usuario INT,
		    game_id INT,
		    game_name VARCHAR(35),
		    cantidad INT,
		    total_pagado INT,
		    fecha_compra DATE,
		    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
		    FOREIGN KEY (game_id) REFERENCES Videojuego(game_id)
		);
		ALTER TABLE ReporteVentas
		ADD COLUMN metodo_pago VARCHAR(15);
		
		ALTER TABLE ReporteVentas 
		ADD COLUMN id_boleta INT;


			CREATE OR REPLACE FUNCTION obtener_reporte_ventas_usuario(p_username VARCHAR)
			RETURNS TABLE (
			    game_name VARCHAR,
			    cantidad INT,
			    total_pagado INT,
			    fecha_compra DATE,
			    metodo_pago VARCHAR,
			    id_boleta INT
			) AS $$
			DECLARE
			    v_id_usuario INT;
			BEGIN
			    -- Buscar el ID del usuario
			    SELECT id_usuario INTO v_id_usuario
			    FROM Usuario
			    WHERE username = p_username;
			
			    IF NOT FOUND THEN
			        RAISE EXCEPTION 'Usuario "%" no encontrado.', p_username;
			    END IF;
			
			    -- Retornar el historial de ventas del usuario
			    RETURN QUERY
			    SELECT 
			        rv.game_name,
			        rv.cantidad,
			        rv.total_pagado,
			        rv.fecha_compra,
			        rv.metodo_pago,
			        rv.id_boleta
			    FROM ReporteVentas rv
			    WHERE rv.id_usuario = v_id_usuario
			    ORDER BY rv.fecha_compra DESC;
			END;
			$$ LANGUAGE plpgsql;
		