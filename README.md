# Proyecto Base de Datos – GrupoMonono

##  Descripción del Proyecto

Este proyecto consiste en el diseño e implementación de una base de datos relacional en **PostgreSQL**, orientada a simular la operación de una tienda virtual de videojuegos. Fue desarrollado como parte del trabajo final del curso de **Bases de Datos – UTEM**, y abarca desde la modelación inicial hasta la implementación funcional mediante funciones, procedimientos y triggers.

El sistema incluye los siguientes componentes clave:

- Gestión de usuarios, carritos de compra y listas de deseos.
- Control de stock y validación de compras, asegurando que no se exceda el inventario disponible.
- Restricción de videojuegos por país, considerando políticas de venta internacionales.
- Ranking de videojuegos más vendidos, para consultas analíticas y comerciales.
- Registro y auditoría de acciones sensibles, como compras y eliminaciones, mediante triggers.

La base de datos fue diseñada por **GrupoMonono**, y el repositorio contiene múltiples versiones de trabajo y consolidaciones progresivas.  
La carpeta `Entrega de proyecto Monono` contiene la versión que se desea presentar para esta evaluación, incluyendo los scripts de creación de estructura, inserción de datos y consultas funcionales.

---

## 📂 Estructura del Repositorio
MononoAvance4/
├── estructura.sql # Creación de tablas, relaciones, triggers y funciones
├── poblado.sql # Inserción de datos de prueba
├── consultas.sql # Consultas y funciones implementadas

---

## ▶️ Instrucciones de Uso

1. Crear una nueva base de datos en PostgreSQL.
2. Ejecutar los archivos en el siguiente orden:
   - `estructura.sql`
   - `poblado.sql`
   - `consultas.sql`
3. Probar las funciones desde un cliente como PgAdmin, DBeaver o consola PostgreSQL.

> Requiere PostgreSQL 13 o superior.

---

## 👨‍💻 Equipo de Desarrollo

- [Tu nombre]
- [Nombre del compañero, si aplica]

---

## 📫 Revisión del Proyecto

Este repositorio debe permanecer **público**.  
Si es privado, se debe enviar una invitación al siguiente correo:

📧 **mdiazb@utem.cl**

---

> Proyecto desarrollado para la asignatura de Bases de Datos – UTEM, 2025.
