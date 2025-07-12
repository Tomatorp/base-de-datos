--Funcion y Trigger basado en TC01 si se opta insertar un usuario y solo se añade nombre del rol y no el ID

--Descripcion: Toma el nombre de el tipo_usuario y asigna automaticamente el id role en base al nombre (cliente o jefe tienda)
CREATE OR REPLACE FUNCTION asignar_id_role()
RETURNS TRIGGER AS $$
BEGIN
    SELECT id_role INTO NEW.id_role
    FROM Rol
    WHERE tipo = NEW.tipo_usuario;
	--condicion para TC03, no permite roles invalidos
	IF NOT FOUND THEN
		RAISE EXCEPTION 'Error: Rol "%" Inválido en tipo_usuario', NEW.tipo_usuario;
	END IF;
	
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE TRIGGER trg_asignar_id_role
BEFORE INSERT ON Usuario
FOR EACH ROW
EXECUTE FUNCTION asignar_id_role();

