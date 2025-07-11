-- consulta numero 18, compra de stock insuficiente
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

