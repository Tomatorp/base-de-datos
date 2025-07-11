-- consulta numero 17, compra de stock insuficiente
SELECT 
    v.game_name,
    v.stock,
    6 AS unidades_solicitadas,
    CASE 
        WHEN 6 > v.stock THEN 'Error: stock insuficiente'
        ELSE 'Compra posible'
    END AS resultado
FROM Videojuego v
WHERE v.game_name = 'Zelda: Breath of the Wild';

-- consulta numero 18, compra de juegos sin stock
SELECT 
    v.game_name,
    v.stock,
    c.id_carro,
    CASE 
        WHEN v.stock <= 0 THEN 'Error: contiene juego sin stock'
        ELSE 'Listo para pago'
    END AS estado_pago
FROM CarroCompras c
JOIN VideojuegoxCarro vc ON c.id_carro = vc.id_carro
JOIN Videojuego v ON vc.game_id = v.game_id
WHERE c.id_carro = 1;

-- consulta numero 19, compra con productos validos del carrito
--parte 1 generar boleta
INSERT INTO ProcesoPago (id_boleta, metodo_pago, fechaC, id_carro, total)
VALUES
    (3, 'Credito', CURRENT_DATE, 1, 25000);
UPDATE Videojuego
SET stock = stock - 1
WHERE game_id IN (
    SELECT game_id
    FROM VideojuegoxCarro
    WHERE id_carro = 1
);
DELETE FROM VideojuegoxCarro
WHERE id_carro = 1;
-- parte 2, verificacion de boleta y carrito ( generar en tool's separados o 1 a la ves)
-- boleta
SELECT * FROM ProcesoPago
WHERE id_boleta = 3;
-- carrito
SELECT * FROM VideojuegoxCarro
WHERE id_carro = 1;

-- consulta numero 20, compra no valida por metodo de pago no valida
DO $$
DECLARE
    metodo_pago_input TEXT := 'moneda de oro';  -- Cambia este valor por cualquier medio de pago
    carrito_id INT := 1;
    total_pago INT := 25000;
    nueva_boleta_id INT := 5;  -- Asegúrate de usar un ID único
BEGIN
    IF metodo_pago_input NOT IN ('Credito', 'Debito', 'Transferencia') THEN
        RAISE NOTICE 'Método de pago "%", no válido. Compra no realizada.', metodo_pago_input;
    ELSE
        INSERT INTO ProcesoPago (id_boleta, metodo_pago, fechaC, id_carro, total)
        VALUES (nueva_boleta_id, metodo_pago_input, CURRENT_DATE, carrito_id, total_pago);

        RAISE NOTICE 'Compra realizada exitosamente "%".', metodo_pago_input;
    END IF;
END $$;

-- consulta numero 21, cliente valora un juego comprado por el
DELETE FROM Valoracion -- Eliminar valoración anterior si existe, de igual manera mas adelante modificar el id en cada run para evitar errores
WHERE id_usuario = 1 AND game_id = 1;

INSERT INTO Valoracion (
    id_valoracion,
    fechaV,
    id_ranking,
    game_id,
    comentario,
    tipo_valoracion,
    id_usuario
)
VALUES (
    5,  -- recordar modificar el id en cada run solo para evitar algun error, no es necesario pero porciacaso
    CURRENT_DATE,
    1,  -- ranking existente
    1,  -- el juego Zelda
    'Muy buen juego',
    TRUE,
    1   -- esta es camila rojas
);

SELECT * FROM Valoracion -- esto es para ver la reseña registrada
WHERE id_usuario = 1 AND game_id = 1;

-- consulta numero 22, valoraciones duplicadas
ALTER TABLE Valoracion
ADD CONSTRAINT unique_valoracion_usuario_juego UNIQUE (id_usuario, game_id);
INSERT INTO Valoracion (
    id_valoracion,
    fechaV,
    id_ranking,
    game_id,
    comentario,
    tipo_valoracion,
    id_usuario
)
VALUES (
    7,  -- ID diferente, modificar en cada run para comprobar que funciona el error 
    CURRENT_DATE,
    1, -- ranking existente
    1, -- el zelda
    'Repetida: lo sigo amando',
    TRUE,
    1  -- camila rojas
);

-- consulta numero 23, los 3 con mas ventas
SELECT game_id, game_name, ventas -- la columna ventas ya estaba echa asi que se evita el count o el group by
FROM Videojuego
ORDER BY ventas DESC
LIMIT 3;

-- consulta numero 24, ranking de juegos deseados
SELECT 
    v.game_id,
    v.game_name,
    COUNT(vxl.id_lista) AS veces_en_listas
FROM 
    Videojuego v
JOIN 
    VideojuegoxLista vxl ON v.game_id = vxl.game_id
GROUP BY 
    v.game_id, v.game_name
ORDER BY 
    veces_en_listas DESC;

-- consulta numero 25, ubicacion geografica
SELECT 
    v.game_id,
    v.game_name,
    v.game_price,
    t.url_tienda,
    u.pais AS ubicacion
FROM 
    Videojuego v
JOIN 
    Tienda t ON v.url_tienda = t.url_tienda
JOIN 
    Usuario u ON t.id_usuarioJ = u.id_usuario
WHERE 
    u.pais = 'Santiago';

-- consulta numero 26, ranking de productos segun ventas
SELECT 
    game_id,
    game_name,
    ventas
FROM 
    Videojuego
ORDER BY 
    ventas DESC;

-- consulta numero 27, filtro de ubicacion geografica
SELECT 
    DISTINCT v.game_id,
    v.game_name,
    v.game_price,
    t.url_tienda,
    jt.pais AS ubicacion_tienda,
    c.username AS cliente
FROM 
    Usuario c
JOIN 
    Videojuego v ON v.url_tienda IN (
        SELECT t.url_tienda
        FROM Tienda t
        JOIN Usuario jt ON jt.id_usuario = t.id_usuarioJ
        WHERE jt.pais = c.pais
    )
JOIN 
    Tienda t ON v.url_tienda = t.url_tienda
JOIN 
    Usuario jt ON t.id_usuarioJ = jt.id_usuario
WHERE 
    c.pais = 'Santiago'
    AND c.rol = 'Cliente';

-- consulta numero 28, triger de auditoria (insert)
CREATE TABLE AuditoriaVideojuego ( -- esta tabla nose si sea redundante pero la cree para facilitar el uso de las autoridades en lugar de valancear el rol, auque igual lo intentar con rol en lugar de la tabla esta
    id_auditoria SERIAL PRIMARY KEY,
    game_id INT,
    accion VARCHAR(10),
    usuario TEXT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- triger para la tabla creada
CREATE OR REPLACE FUNCTION fn_auditoria_videojuego()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO AuditoriaVideojuego (game_id, accion, usuario)
    VALUES (
        NEW.game_id,
        'INSERT',
        current_user  -- o null si no quieren control de sesión, este lo use mas que nada para tener registro de quien ingresa que
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- este triger es para videojuego
CREATE TRIGGER trg_auditar_insert_videojuego
AFTER INSERT ON Videojuego
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_videojuego();
-- esto para probar el triger
INSERT INTO Videojuego (
    game_id, game_name, game_price, url_imagen, ventas, stock, desarrollador, url_tienda
) VALUES (
    10, 'Super Mario Odyssey', 30000, 'mario.jpg', 0, 10, 'Nintendo', 'tienda01'
);
-- este ya para ver la auditoria
SELECT * FROM AuditoriaVideojuego WHERE game_id = 10; -- tienen que poner la misma id que el juego que registraron

-- consulta numero 29, triger de auditoria (update)
CREATE TABLE LogStockVideojuego ( -- la tabla para tener un historial
    id_log SERIAL PRIMARY KEY,
    game_id INT,
    stock_anterior INT,
    stock_nuevo INT,
    usuario TEXT,
    accion TEXT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- este es el triger
CREATE OR REPLACE FUNCTION fn_log_stock_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo registra si el stock si cambia
    IF OLD.stock IS DISTINCT FROM NEW.stock THEN
        INSERT INTO LogStockVideojuego (
            game_id,
            stock_anterior,
            stock_nuevo,
            usuario,
            accion
        ) VALUES (
            OLD.game_id,
            OLD.stock,
            NEW.stock,
            current_user,
            'UPDATE'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- este para poner un triger sobre videojuego
CREATE TRIGGER trg_log_update_stock
AFTER UPDATE ON Videojuego
FOR EACH ROW
EXECUTE FUNCTION fn_log_stock_update();
-- pa probar el triger
UPDATE Videojuego
SET stock = stock - 1
WHERE game_id = 1;
-- para ver el log
SELECT * FROM LogStockVideojuego
WHERE game_id = 1
ORDER BY fecha_hora DESC;

-- consulta numero 30, triger de seguridad (delete)
CREATE OR REPLACE FUNCTION fn_prevent_delete_if_purchased()
RETURNS TRIGGER AS $$
DECLARE
    cantidad_compras INT;
BEGIN
    SELECT COUNT(*) INTO cantidad_compras
    FROM VideojuegoxCarro vc
    JOIN ProcesoPago pp ON vc.id_carro = pp.id_carro
    WHERE vc.game_id = OLD.game_id;

    IF cantidad_compras > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el videojuego con ID=% porque ya ha sido comprado.', OLD.game_id;
    END IF;

    RETURN OLD; -- Cancelamos el DELETE
END;
$$ LANGUAGE plpgsql;
-- crear el triger en juegos
CREATE TRIGGER trg_prevent_delete_purchased
BEFORE DELETE ON Videojuego
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_delete_if_purchased();
-- este para probar la proteccion
DELETE FROM Videojuego WHERE game_id = 1; -- si deja borrarlo es porque no se a vendido

-- consulta numero 31, actualizacion de precios por categoria
CREATE OR REPLACE PROCEDURE actualizar_precio_categoria( -- pa crear el proceso de almacenado
    categoria_input VARCHAR,
    porcentaje_aumento NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Videojuego
    SET game_price = ROUND(game_price * (1 + porcentaje_aumento / 100.0))
    WHERE game_id IN (
        SELECT game_id
        FROM VideojuegoxCategoria
        WHERE tipo_categoria = categoria_input
    );
END;
$$;
-- este llama al proceso
CALL actualizar_precio_categoria('aventura', 10);
-- para ver los resultados
SELECT game_id, game_name, game_price
FROM Videojuego
WHERE game_id IN (
    SELECT game_id
    FROM VideojuegoxCategoria
    WHERE tipo_categoria = 'aventura'
);

-- consulta numero 32, generar reporte de ventas por usuario
CREATE OR REPLACE FUNCTION reporte_ventas_usuario(usuario_id INT)
RETURNS TABLE (
    videojuego TEXT,
    precio INT,
    fecha_compra DATE,
    id_boleta INT
)
LANGUAGE SQL
AS $$
    SELECT 
        v.game_name,
        v.game_price,
        pp.fechaC,
        pp.id_boleta
    FROM 
        ProcesoPago pp
    JOIN CarroCompras cc ON cc.id_carro = pp.id_carro
    JOIN VideojuegoxCarro vxc ON vxc.id_carro = cc.id_carro
    JOIN Videojuego v ON v.game_id = vxc.game_id
    WHERE cc.id_usuario = usuario_id;
$$;
-- este para ver la tabla
SELECT * FROM reporte_ventas_usuario(1); -- nota, puede que las funciones anteriores usasen datos que esta funcion si necesita tener, asi que re poblar la base de datos no es mala idea antes de usar esta funcion

