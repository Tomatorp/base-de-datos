--Trigger para TC01 si se opta añadir solo por el nombre del rol y no el ID
CREATE OR REPLACE FUNCTION asignar_id_role()
RETURNS TRIGGER AS $$
BEGIN
    SELECT id_role INTO NEW.id_role
    FROM Rol
    WHERE tipo = NEW.tipo_usuario;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_asignar_id_role
BEFORE INSERT ON Usuario
FOR EACH ROW
EXECUTE FUNCTION asignar_id_role();

