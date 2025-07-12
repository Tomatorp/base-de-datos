-- TC01	Registro de usuario	I
-- Insertar usuario con datos válidos y rol 'jefe de tienda'	
-- Nombre='Pedro', Apellido='García', Correo='pedro.garcia@mail.cl' 
-- Rol='jefe de tienda'	Usuario creado correctamente; rol válido según CHECK

INSERT INTO Usuario ( id_usuario, correo, username, clave, pais, tipo_usuario ) VALUES
	(4, 'juana.garcia@mail.cl', 'Juana', 'clave123', 'Chile','Jefe de tienda');

-- TC02
-- Insertar usuario con correo NULL 
-- Resultado: error por restriccion NOT NULL
INSERT INTO Usuario (id_usuario, correo, username, tipo_usuario) VALUES
	(0,NULL,'Zealos123', Cliente);

-- TC03
-- Insertar usuario con rol inexistente
-- Resultado esperado: error por restriccion check sobre roles permitidos
-- En este caso la restriccion pasa por la funcion/trigger inicial
INSERT INTO Usuario (id_usuario, correo, username, tipo_usuario) VALUES
	(0,'Zealos@gmail.com','Zealos123', 'mago');


-- TC04
-- Insertar usuario cliente con datos válidos
-- Resultado esperado: usuario creado correctamente
INSERT INTO Usuario (id_usuario, correo, username, tipo_usuario) VALUES
	(1,'frogsillo@gmail.com','Frogsillo', 'Cliente');

Select *
From Usuario;
