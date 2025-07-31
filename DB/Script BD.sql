
CREATE TABLE Provincias (
    idProvincias NUMBER PRIMARY KEY,
    nombreProvincia VARCHAR2(45)
);


CREATE TABLE Cantones (
    idCantones NUMBER PRIMARY KEY,
    nombreCanton VARCHAR2(45),
    idProvincias NUMBER,
    FOREIGN KEY (idProvincias) REFERENCES Provincias(idProvincias)
);


CREATE TABLE Distritos (
    idDistritos NUMBER PRIMARY KEY,
    nombreDistrito VARCHAR2(45),
    idCantones NUMBER,
    FOREIGN KEY (idCantones) REFERENCES Cantones(idCantones)
);

CREATE TABLE Sucursal (
    idSucursal NUMBER PRIMARY KEY,
    NombreSucursal VARCHAR2(45),
    Distritos_idDistritos NUMBER,
    FOREIGN KEY (Distritos_idDistritos) REFERENCES Distritos(idDistritos)
);


CREATE TABLE Entrega (
    idEntrega NUMBER PRIMARY KEY,
    DescripcionEntrega VARCHAR2(45),
    fechaEntrega DATE
);


CREATE TABLE Categorias (
    idCategorias NUMBER PRIMARY KEY,
    Nombre VARCHAR2(45),
    Descripcion VARCHAR2(45),
    Activo VARCHAR2(45)
);


CREATE TABLE Proveedor (
    idProveedor NUMBER PRIMARY KEY,
    NombreProveedor VARCHAR2(45),
    DescripcionProveedor VARCHAR2(45),
    idDistritos NUMBER,
    FOREIGN KEY (idDistritos) REFERENCES Distritos(idDistritos)
);


CREATE TABLE Producto (
    idProductos NUMBER PRIMARY KEY,
    Nombre VARCHAR2(45),
    Cantidad NUMBER,
    Descripcion VARCHAR2(45),
    Precio NUMBER,
    Activo VARCHAR2(45),
    idCategorias NUMBER,
    idProveedor NUMBER,
    FOREIGN KEY (idCategorias) REFERENCES Categorias(idCategorias),
    FOREIGN KEY (idProveedor) REFERENCES Proveedor(idProveedor)
);
ALTER TABLE Producto
ADD (Imagen_url VARCHAR(200));


CREATE TABLE tipoUsuario (
    idtipoUsuario NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(45)
);


CREATE TABLE Usuario (
    idUsuario NUMBER PRIMARY KEY,
    Nombre VARCHAR2(45),
    Apellido VARCHAR2(45),
    Username VARCHAR2(45),
    Password VARCHAR2(45),
    tipoUsuario_idtipoUsuario NUMBER,
    FOREIGN KEY (tipoUsuario_idtipoUsuario) REFERENCES tipoUsuario(idtipoUsuario)
);


CREATE TABLE Comprador (
    idComprador NUMBER PRIMARY KEY,
    Nombre VARCHAR2(45),
    Apellidos VARCHAR2(45),
    Correo VARCHAR2(45),
    idDistritos NUMBER,
    FOREIGN KEY (idDistritos) REFERENCES Distritos(idDistritos)
);


CREATE TABLE Factura (
    idFactura NUMBER PRIMARY KEY,
    Fecha DATE,
    Total NUMBER,
    Estado NUMBER,
    idComprador NUMBER,
    Usuario_idUsuario NUMBER,
    FOREIGN KEY (idComprador) REFERENCES Comprador(idComprador),
    FOREIGN KEY (Usuario_idUsuario) REFERENCES Usuario(idUsuario)
);


CREATE TABLE Venta (
    idVenta NUMBER PRIMARY KEY,
    Cantidad VARCHAR2(45),
    idProductos NUMBER,
    idFactura NUMBER,
    Entrega_idEntrega NUMBER,
    Sucursal_idSucursal NUMBER,
    FOREIGN KEY (idProductos) REFERENCES Producto(idProductos),
    FOREIGN KEY (idFactura) REFERENCES Factura(idFactura),
    FOREIGN KEY (Entrega_idEntrega) REFERENCES Entrega(idEntrega),
    FOREIGN KEY (Sucursal_idSucursal) REFERENCES Sucursal(idSucursal)
);


CREATE TABLE Telefonos (
    idTelefonos NUMBER PRIMARY KEY,
    NumeroTelefono VARCHAR2(45)
);


CREATE TABLE Telefonos_has_Proveedor (
    idTelefonos NUMBER,
    idProveedor NUMBER,
    PRIMARY KEY (idTelefonos, idProveedor),
    FOREIGN KEY (idTelefonos) REFERENCES Telefonos(idTelefonos),
    FOREIGN KEY (idProveedor) REFERENCES Proveedor(idProveedor)
);


CREATE TABLE Telefonos_has_Comprador (
    idTelefonos NUMBER,
    idComprador NUMBER,
    PRIMARY KEY (idTelefonos, idComprador),
    FOREIGN KEY (idTelefonos) REFERENCES Telefonos(idTelefonos),
    FOREIGN KEY (idComprador) REFERENCES Comprador(idComprador)
);

CREATE TABLE DetalleVenta (
    idDetalleVenta NUMBER PRIMARY KEY,
    idVenta NUMBER,
    idProducto NUMBER,
    Cantidad NUMBER,
    PrecioUnitario NUMBER,
    Subtotal NUMBER,
    FOREIGN KEY (idVenta) REFERENCES Venta(idVenta),
    FOREIGN KEY (idProducto) REFERENCES Producto(idProductos)
);
ALTER TABLE DetalleVenta
ADD Estado VARCHAR2(1) DEFAULT 'A';

CREATE SEQUENCE seq_detalleVenta
START WITH 1
INCREMENT BY 1;


--CRUD Detalle venta
CREATE OR REPLACE PROCEDURE insertar_DetalleVenta(
    p_idVenta        IN NUMBER,
    p_idProducto     IN NUMBER,
    p_Cantidad       IN NUMBER,
    p_PrecioUnitario IN NUMBER,
    p_Subtotal       IN NUMBER
)AS
BEGIN
    INSERT INTO DetalleVenta(
        idDetalleVenta,
        idVenta,
        idProducto,
        Cantidad,
        PrecioUnitario,
        Subtotal
    ) VALUES (
        seq_detalleVenta.NEXTVAL,
        p_idVenta,
        p_idProducto,
        p_Cantidad,
        p_PrecioUnitario,
        p_Subtotal
    );

    DBMS_OUTPUT.PUT_LINE('Detalle de venta insertado exitosamente');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE borrar_detalleVenta (
    p_idDetalleVenta IN DetalleVenta.idDetalleVenta%TYPE
) AS
BEGIN
    UPDATE DetalleVenta
    SET Estado = 'I'
    WHERE idDetalleVenta = p_idDetalleVenta;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el detalle con ID ' || p_idDetalleVenta);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Detalle de venta marcado como inactivo');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE listar_detalleVenta AS
    CURSOR c_detalles IS
        SELECT idDetalleVenta, idVenta, idProducto, Cantidad, PrecioUnitario, Subtotal
        FROM DetalleVenta
        WHERE Estado = 'A'; 

    v_idDetalleVenta  DetalleVenta.idDetalleVenta%TYPE;
    v_idVenta         DetalleVenta.idVenta%TYPE;
    v_idProducto      DetalleVenta.idProducto%TYPE;
    v_Cantidad        DetalleVenta.Cantidad%TYPE;
    v_PrecioUnitario  DetalleVenta.PrecioUnitario%TYPE;
    v_Subtotal        DetalleVenta.Subtotal%TYPE;
BEGIN
    OPEN c_detalles;
    LOOP
        FETCH c_detalles INTO v_idDetalleVenta, v_idVenta, v_idProducto, v_Cantidad, v_PrecioUnitario, v_Subtotal;
        EXIT WHEN c_detalles%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || v_idDetalleVenta ||
            ' | Venta: ' || v_idVenta ||
            ' | Producto: ' || v_idProducto ||
            ' | Cantidad: ' || v_Cantidad ||
            ' | Precio Unitario: ' || v_PrecioUnitario ||
            ' | Subtotal: ' || v_Subtotal
        );
    END LOOP;
    CLOSE c_detalles;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE modificar_detalleVenta (
    p_idDetalleVenta  IN DetalleVenta.idDetalleVenta%TYPE,
    p_idVenta         IN DetalleVenta.idVenta%TYPE,
    p_idProducto      IN DetalleVenta.idProducto%TYPE,
    p_Cantidad        IN DetalleVenta.Cantidad%TYPE,
    p_PrecioUnitario  IN DetalleVenta.PrecioUnitario%TYPE,
    p_Subtotal        IN DetalleVenta.Subtotal%TYPE
) AS
BEGIN
    UPDATE DetalleVenta
    SET
        idVenta        = p_idVenta,
        idProducto     = p_idProducto,
        Cantidad       = p_Cantidad,
        PrecioUnitario = p_PrecioUnitario,
        Subtotal       = p_Subtotal
    WHERE idDetalleVenta = p_idDetalleVenta;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el detalle de venta con ID ' || p_idDetalleVenta);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Detalle de venta modificado exitosamente');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;


-- ========================
-- FUNCIONES
-- ========================

-- Función 1
CREATE OR REPLACE FUNCTION fn_precio_producto(p_idProducto NUMBER)
RETURN NUMBER IS
  v_precio NUMBER;
BEGIN
  SELECT Precio INTO v_precio FROM Producto WHERE idProductos = p_idProducto;
  RETURN v_precio;
END;
/

-- Función 2
CREATE OR REPLACE FUNCTION fn_cantidad_producto(p_idProducto NUMBER)
RETURN NUMBER IS
  v_cantidad NUMBER;
BEGIN
  SELECT Cantidad INTO v_cantidad FROM Producto WHERE idProductos = p_idProducto;
  RETURN v_cantidad;
END;
/

-- Función 3
CREATE OR REPLACE FUNCTION fn_nombre_completo_usuario(p_idUsuario NUMBER)
RETURN VARCHAR2 IS
  v_nombre VARCHAR2(100);
BEGIN
  SELECT Nombre || ' ' || Apellido INTO v_nombre FROM Usuario WHERE idUsuario = p_idUsuario;
  RETURN v_nombre;
END;
/

-- Función 4
CREATE OR REPLACE FUNCTION fn_subtotal(p_precio NUMBER, p_cantidad NUMBER)
RETURN NUMBER IS
BEGIN
  RETURN p_precio * p_cantidad;
END;
/

-- Función 5
CREATE OR REPLACE FUNCTION fn_producto_activo(p_idProducto NUMBER)
RETURN VARCHAR2 IS
  v_activo VARCHAR2(10);
BEGIN
  SELECT Activo INTO v_activo FROM Producto WHERE idProductos = p_idProducto;
  RETURN v_activo;
END;
/

-- Función 6
CREATE OR REPLACE FUNCTION fn_nombre_proveedor(p_idProveedor NUMBER)
RETURN VARCHAR2 IS
  v_nombre VARCHAR2(45);
BEGIN
  SELECT NombreProveedor INTO v_nombre FROM Proveedor WHERE idProveedor = p_idProveedor;
  RETURN v_nombre;
END;
/

-- Función 7
CREATE OR REPLACE FUNCTION fn_contar_productos_categoria(p_idCategoria NUMBER)
RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_total FROM Producto WHERE idCategorias = p_idCategoria;
  RETURN v_total;
END;
/

-- Función 8
CREATE OR REPLACE FUNCTION fn_total_factura(p_idFactura NUMBER)
RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT Total INTO v_total FROM Factura WHERE idFactura = p_idFactura;
  RETURN v_total;
END;
/

-- Función 9
CREATE OR REPLACE FUNCTION fn_estado_pedido(p_idPedido NUMBER)
RETURN VARCHAR2 IS
  v_estado VARCHAR2(50);
BEGIN
  SELECT estado INTO v_estado FROM Pedidos WHERE id_pedido = p_idPedido;
  RETURN v_estado;
END;
/

-- Función 10
CREATE OR REPLACE FUNCTION fn_nombre_distrito(p_idDistrito NUMBER)
RETURN VARCHAR2 IS
  v_nombre VARCHAR2(45);
BEGIN
  SELECT nombreDistrito INTO v_nombre FROM Distritos WHERE idDistritos = p_idDistrito;
  RETURN v_nombre;
END;
/

-- Función 11
CREATE OR REPLACE FUNCTION fn_nombre_canton(p_idCanton NUMBER)
RETURN VARCHAR2 IS
  v_nombre VARCHAR2(45);
BEGIN
  SELECT nombreCanton INTO v_nombre FROM Cantones WHERE idCantones = p_idCanton;
  RETURN v_nombre;
END;
/

-- Función 12
CREATE OR REPLACE FUNCTION fn_nombre_provincia(p_idProvincia NUMBER)
RETURN VARCHAR2 IS
  v_nombre VARCHAR2(45);
BEGIN
  SELECT nombreProvincia INTO v_nombre FROM Provincias WHERE idProvincias = p_idProvincia;
  RETURN v_nombre;
END;
/

-- Función 13
CREATE OR REPLACE FUNCTION fn_desc_entrega(p_idEntrega NUMBER)
RETURN VARCHAR2 IS
  v_desc VARCHAR2(45);
BEGIN
  SELECT DescripcionEntrega INTO v_desc FROM Entrega WHERE idEntrega = p_idEntrega;
  RETURN v_desc;
END;
/

-- Función 14
CREATE OR REPLACE FUNCTION fn_es_admin(p_idUsuario NUMBER)
RETURN BOOLEAN IS
  v_rol VARCHAR2(45);
BEGIN
  SELECT tipoUsuario_idtipoUsuario INTO v_rol FROM Usuario WHERE idUsuario = p_idUsuario;
  RETURN v_rol = 1; -- Asumiendo que 1 es admin
END;
/

-- Función 15
CREATE OR REPLACE FUNCTION fn_ventas_producto(p_idProducto NUMBER)
RETURN NUMBER IS
  v_cantidad NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cantidad FROM Venta WHERE idProductos = p_idProducto;
  RETURN v_cantidad;
END;
/

-- ========================
-- VISTAS
-- ========================
-- Vista 1
CREATE VIEW Vista_Productos_Disponibles AS
SELECT p.id_producto, p.nombre_producto, p.descripcion, p.precio, p.cantidad,
       c.nombre_categoria
FROM Productos p
JOIN Categorias c ON p.id_categoria = c.id_categoria
WHERE p.cantidad > 0;


-- Vista 2
CREATE VIEW Vista_Pedidos_Usuarios AS
SELECT u.nombre AS cliente, p.id_pedido, p.fecha, p.estado
FROM Pedidos p
JOIN Usuarios u ON p.id_usuario = u.id_usuario;


-- Vista 3
CREATE VIEW Vista_Productos_Con_Proveedor AS
    SELECT pr.Nombre AS Proveedor, p.Nombre AS Producto, p.Cantidad, p.Precio
    FROM Producto p
    JOIN Proveedor pr ON p.idProveedor = pr.idProveedor;



-- Vista 4
CREATE VIEW Vista_Ventas_Sucursal AS
    SELECT s.NombreSucursal, COUNT(v.idVenta) AS TotalVentas
    FROM Venta v
    JOIN Sucursal s ON v.Sucursal_idSucursal = s.idSucursal
    GROUP BY s.NombreSucursal;



-- Vista 5

CREATE VIEW Vista_Proveedores_Activos AS
    SELECT pr.NombreProveedor, pr.DescripcionProveedor, d.nombreDistrito
    FROM Proveedor pr
    JOIN Distritos d ON pr.idDistritos = d.idDistritos;



-- Vista 6

CREATE VIEW Vista_Clientes_Direccion AS
    SELECT c.Nombre, c.Apellidos, d.nombreDistrito, cn.nombreCanton, p.nombreProvincia
    FROM Comprador c
    JOIN Distritos d ON c.idDistritos = d.idDistritos
    JOIN Cantones cn ON d.idCantones = cn.idCantones
    JOIN Provincias p ON cn.idProvincias = p.idProvincias;




-- Vista 7
CREATE VIEW Vista_Usuarios_Admin AS
    SELECT u.Nombre, u.Apellido, tu.Descripcion AS TipoUsuario
    FROM Usuario u
    JOIN tipoUsuario tu ON u.tipoUsuario_idtipoUsuario = tu.idtipoUsuario
    WHERE tu.Descripcion = 'admin';



-- Vista 8
CREATE VIEW Vista_Facturas_Completas AS
    SELECT f.idFactura, f.Fecha, f.Total, c.Nombre, c.Apellidos, u.Nombre AS AtendidoPor
    FROM Factura f
    JOIN Comprador c ON f.idComprador = c.idComprador
    JOIN Usuario u ON f.Usuario_idUsuario = u.idUsuario;



-- Vista 9
CREATE VIEW Vista_Telefonos_Proveedores AS
    SELECT pr.NombreProveedor, t.NumeroTelefono
    FROM Telefonos t
    JOIN Telefonos_has_Proveedor thp ON t.idTelefonos = thp.idTelefonos
    JOIN Proveedor pr ON thp.idProveedor = pr.idProveedor;



-- Vista 10
CREATE VIEW Vista_Productos_Categorias AS
    SELECT p.Nombre AS Producto, c.Nombre AS Categoria, p.Precio, p.Cantidad
    FROM Producto p
    JOIN Categorias c ON p.idCategorias = c.idCategorias;



-- ========================
-- TRIGGERS
-- ========================


-- Trigger 1
CREATE OR REPLACE TRIGGER trg_bajar_stock_despues_venta
AFTER INSERT ON Venta
FOR EACH ROW
BEGIN
    UPDATE Producto
    SET Cantidad = Cantidad - TO_NUMBER(:NEW.Cantidad)
    WHERE idProductos = :NEW.idProductos;
END;
/


-- Trigger 2
CREATE OR REPLACE TRIGGER trg_fecha_factura
BEFORE INSERT ON Factura
FOR EACH ROW
BEGIN
    IF :NEW.Fecha IS NULL THEN
        :NEW.Fecha := SYSDATE;
    END IF;
END;
/


-- Trigger 3
CREATE OR REPLACE TRIGGER trg_auditoria_actualizacion_producto
AFTER UPDATE ON Producto
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Producto actualizado: ' || :OLD.Nombre || ' -> ' || :NEW.Nombre);
END;
/

-- Trigger 4

CREATE OR REPLACE TRIGGER trg_prevenir_stock_negativo
BEFORE UPDATE ON Producto
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'La cantidad no puede ser negativa.');
    END IF;
END;
/


-- Trigger 5
CREATE OR REPLACE TRIGGER trg_validar_telefono_unico
BEFORE INSERT ON Telefonos
FOR EACH ROW
DECLARE
    v_existente NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existente
    FROM Telefonos
    WHERE NumeroTelefono = :NEW.NumeroTelefono;

    IF v_existente > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El número de teléfono ya existe.');
    END IF;
END;
/


-- ========================
-- PROCEDIMIENTOS
-- ========================



-- Procedimiento 1
CREATE OR REPLACE PROCEDURE sp_insert_producto(
    p_Nombre IN VARCHAR2,
    p_Cantidad IN NUMBER,
    p_Descripcion IN VARCHAR2,
    p_Precio IN NUMBER,
    p_Activo IN VARCHAR2,
    p_idCategorias IN NUMBER,
    p_idProveedor IN NUMBER
)
AS
BEGIN
    INSERT INTO Producto (Nombre, Cantidad, Descripcion, Precio, Activo, idCategorias, idProveedor)
    VALUES (p_Nombre, p_Cantidad, p_Descripcion, p_Precio, p_Activo, p_idCategorias, p_idProveedor);
END;
/

-- Procedimiento 2
CREATE OR REPLACE PROCEDURE sp_update_producto(
    p_idProductos IN NUMBER,
    p_Nombre IN VARCHAR2,
    p_Cantidad IN NUMBER,
    p_Descripcion IN VARCHAR2,
    p_Precio IN NUMBER,
    p_Activo IN VARCHAR2
)
AS
BEGIN
    UPDATE Producto
    SET Nombre = p_Nombre,
        Cantidad = p_Cantidad,
        Descripcion = p_Descripcion,
        Precio = p_Precio,
        Activo = p_Activo
    WHERE idProductos = p_idProductos;
END;
/


-- Procedimiento 3
CREATE OR REPLACE PROCEDURE sp_delete_producto(
    p_idProductos IN NUMBER
)
AS
BEGIN
    DELETE FROM Producto WHERE idProductos = p_idProductos;
END;
/

-- Procedimiento 4
CREATE OR REPLACE PROCEDURE sp_insert_proveedor(
    p_NombreProveedor IN VARCHAR2,
    p_DescripcionProveedor IN VARCHAR2,
    p_idDistritos IN NUMBER
)
AS
BEGIN
    INSERT INTO Proveedor (NombreProveedor, DescripcionProveedor, idDistritos)
    VALUES (p_NombreProveedor, p_DescripcionProveedor, p_idDistritos);
END;
/

-- Procedimiento 5
CREATE OR REPLACE PROCEDURE ObtenerProductosPorCategoria(
    p_idCategoria IN NUMBER
)
IS
BEGIN
    FOR prod IN (
        SELECT * FROM Producto WHERE idCategorias = p_idCategoria
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Producto: ' || prod.Nombre || ', Precio: ' || prod.Precio);
    END LOOP;
END;
/

-- Procedimiento 6
CREATE OR REPLACE PROCEDURE ListarFacturasComprador(
    p_idComprador IN NUMBER
)
IS
BEGIN
    FOR fact IN (
        SELECT * FROM Factura WHERE idComprador = p_idComprador
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Factura ID: ' || fact.idFactura || ', Total: ' || fact.Total);
    END LOOP;
END;
/


-- Procedimiento 7
CREATE OR REPLACE PROCEDURE CambiarEstadoProducto(
    p_idProducto IN NUMBER,
    p_estado IN VARCHAR2
)
IS
BEGIN
    UPDATE Producto SET Activo = p_estado WHERE idProductos = p_idProducto;
    COMMIT;
END;
/



-- Procedimiento 8
CREATE OR REPLACE PROCEDURE InfoProveedor(
    p_idProveedor IN NUMBER
)
IS
BEGIN
    FOR prov IN (
        SELECT * FROM Proveedor WHERE idProveedor = p_idProveedor
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || prov.NombreProveedor || ' - ' || prov.DescripcionProveedor);
    END LOOP;
END;
/
-- Procedimiento 8
CREATE OR REPLACE PROCEDURE RegistrarVenta(
    p_cantidad IN NUMBER,
    p_idProducto IN NUMBER,
    p_idFactura IN NUMBER,
    p_idEntrega IN NUMBER,
    p_idSucursal IN NUMBER
)
IS
BEGIN
    INSERT INTO Venta (
        Cantidad, idProductos, idFactura, Entrega_idEntrega, Sucursal_idSucursal
    ) VALUES (
        p_cantidad, p_idProducto, p_idFactura, p_idEntrega, p_idSucursal
    );
    COMMIT;
END;
/


-- Procedimiento 9
CREATE OR REPLACE PROCEDURE CambiarPassword(
    p_idUsuario IN NUMBER,
    p_nuevaPassword IN VARCHAR2
)
IS
BEGIN
    UPDATE Usuario SET Password = p_nuevaPassword WHERE idUsuario = p_idUsuario;
    COMMIT;
END;
/


-- Procedimiento 10
CREATE OR REPLACE PROCEDURE VerDetallesFactura(
    p_idFactura IN NUMBER
)
IS
BEGIN
    FOR det IN (
        SELECT * FROM Venta WHERE idFactura = p_idFactura
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Producto ID: ' || det.idProductos || ', Cantidad: ' || det.Cantidad);
    END LOOP;
END;
/


-- Procedimiento 11
CREATE OR REPLACE PROCEDURE RegistrarCategoria(
    p_nombre IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_activo IN VARCHAR2
)
IS
BEGIN
    INSERT INTO Categorias (Nombre, Descripcion, Activo)
    VALUES (p_nombre, p_descripcion, p_activo);
    COMMIT;
END;
/


-- Procedimiento 12
CREATE OR REPLACE PROCEDURE ProductosPorCategoria(
    p_idCategoria IN NUMBER
)
IS
BEGIN
    FOR prod IN (
        SELECT * FROM Producto WHERE idCategorias = p_idCategoria
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Producto: ' || prod.Nombre || ' - Precio: ' || prod.Precio);
    END LOOP;
END;
/


-- Procedimiento 13
CREATE OR REPLACE PROCEDURE RegistrarComprador(
    p_nombre IN VARCHAR2,
    p_apellidos IN VARCHAR2,
    p_correo IN VARCHAR2,
    p_idDistrito IN NUMBER
)
IS
BEGIN
    INSERT INTO Comprador (Nombre, Apellidos, Correo, idDistritos)
    VALUES (p_nombre, p_apellidos, p_correo, p_idDistrito);
    COMMIT;
END;
/



-- Procedimiento 14
CREATE OR REPLACE PROCEDURE HistorialFacturasComprador(
    p_idComprador IN NUMBER
)
IS
BEGIN
    FOR fact IN (
        SELECT * FROM Factura WHERE idComprador = p_idComprador
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Factura: ' || fact.idFactura || ', Total: ' || fact.Total || ', Estado: ' || fact.Estado);
    END LOOP;
END;
/


-- Procedimiento 15
CREATE OR REPLACE PROCEDURE ActualizarEstadoEntrega(
    p_idEntrega IN NUMBER,
    p_nuevaDescripcion IN VARCHAR2,
    p_nuevaFecha IN DATE
)
IS
BEGIN
    UPDATE Entrega
    SET DescripcionEntrega = p_nuevaDescripcion,
        fechaEntrega = p_nuevaFecha
    WHERE idEntrega = p_idEntrega;
    COMMIT;
END;
/


-- Procedimiento 16
CREATE OR REPLACE PROCEDURE CambiarRolUsuario(
    p_idUsuario IN NUMBER,
    p_nuevoRol IN VARCHAR2
)
IS
BEGIN
    UPDATE Usuario
    SET tipoUsuario_idtipoUsuario = p_nuevoRol
    WHERE idUsuario = p_idUsuario;
    COMMIT;
END;
/


-- Procedimiento 17
CREATE OR REPLACE PROCEDURE ObtenerDetallesFactura(
    p_idFactura IN NUMBER
)
IS
BEGIN
    FOR venta IN (
        SELECT * FROM Venta WHERE idFactura = p_idFactura
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Venta ID: ' || venta.idVenta || ' - Producto ID: ' || venta.idProductos || ' - Cantidad: ' || venta.Cantidad);
    END LOOP;
END;
/

-- Procedimiento 18
CREATE OR REPLACE PROCEDURE EliminarProveedor(
    p_idProveedor IN NUMBER
)
IS
BEGIN
    DELETE FROM Proveedor WHERE idProveedor = p_idProveedor;
    COMMIT;
END;
/


-- Procedimiento 19
CREATE OR REPLACE PROCEDURE EliminarProveedor(
    p_idProveedor IN NUMBER
)
IS
BEGIN
    DELETE FROM Proveedor WHERE idProveedor = p_idProveedor;
    COMMIT;
END;
/



-- Procedimiento 20
CREATE OR REPLACE PROCEDURE VentasPorSucursal(
    p_idSucursal IN NUMBER
)
IS
BEGIN
    FOR v IN (
        SELECT v.idVenta, v.Cantidad, v.idFactura
        FROM Venta v
        WHERE v.Sucursal_idSucursal = p_idSucursal
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Venta: ' || v.idVenta || ' - Cantidad: ' || v.Cantidad || ' - Factura: ' || v.idFactura);
    END LOOP;
END;
/



-- Procedimiento 21
CREATE OR REPLACE PROCEDURE AgregarTelefonoProveedor(
    p_idProveedor IN NUMBER,
    p_numeroTelefono IN VARCHAR2
)
IS
    v_idTelefono NUMBER;
BEGIN
    SELECT NVL(MAX(idTelefonos), 0) + 1 INTO v_idTelefono FROM Telefonos;

    INSERT INTO Telefonos (idTelefonos, NumeroTelefono)
    VALUES (v_idTelefono, p_numeroTelefono);

    INSERT INTO Telefonos_has_Proveedor (idTelefonos, idProveedor)
    VALUES (v_idTelefono, p_idProveedor);

    COMMIT;
END;
/
-- ========================
-- CURSORES
-- ========================

-- Cursores 1
DECLARE
    CURSOR cur_listar_productos IS
        SELECT Nombre, Cantidad, Precio
        FROM Producto;
    v_Nombre Producto.Nombre%TYPE;
    v_Cantidad Producto.Cantidad%TYPE;
    v_Precio Producto.Precio%TYPE;
BEGIN
    OPEN cur_listar_productos;
    LOOP
        FETCH cur_listar_productos INTO v_Nombre, v_Cantidad, v_Precio;
        EXIT WHEN cur_listar_productos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_Nombre || ', Cantidad: ' || v_Cantidad || ', Precio: ' || v_Precio);
    END LOOP;
    CLOSE cur_listar_productos;
END;

-- Cursores 2
DECLARE
    CURSOR cur_clientes_distrito IS
        SELECT Nombre, Apellidos, Correo
        FROM Comprador
        WHERE idDistritos = 1;
    v_Nombre Comprador.Nombre%TYPE;
    v_Apellidos Comprador.Apellidos%TYPE;
    v_Correo Comprador.Correo%TYPE;
BEGIN
    OPEN cur_clientes_distrito;
    LOOP
        FETCH cur_clientes_distrito INTO v_Nombre, v_Apellidos, v_Correo;
        EXIT WHEN cur_clientes_distrito%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_Nombre || ' ' || v_Apellidos || ': ' || v_Correo);
    END LOOP;
    CLOSE cur_clientes_distrito;
END;


-- Cursores 3
DECLARE
    CURSOR cur_proveedores_activos IS
        SELECT NombreProveedor, DescripcionProveedor
        FROM Proveedor
        WHERE idDistritos IS NOT NULL;
    v_Nombre Proveedor.NombreProveedor%TYPE;
    v_Descripcion Proveedor.DescripcionProveedor%TYPE;
BEGIN
    OPEN cur_proveedores_activos;
    LOOP
        FETCH cur_proveedores_activos INTO v_Nombre, v_Descripcion;
        EXIT WHEN cur_proveedores_activos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Proveedor: ' || v_Nombre || ' - ' || v_Descripcion);
    END LOOP;
    CLOSE cur_proveedores_activos;
END;


-- Cursores 4
DECLARE
    CURSOR cur_ventas_sucursal IS
        SELECT idSucursal, COUNT(*) AS total_ventas
        FROM Venta
        GROUP BY idSucursal;
    v_idSucursal Venta.idSucursal%TYPE;
    v_total NUMBER;
BEGIN
    OPEN cur_ventas_sucursal;
    LOOP
        FETCH cur_ventas_sucursal INTO v_idSucursal, v_total;
        EXIT WHEN cur_ventas_sucursal%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Sucursal ID: ' || v_idSucursal || ' - Total ventas: ' || v_total);
    END LOOP;
    CLOSE cur_ventas_sucursal;
END;

-- Cursores 5
DECLARE
    CURSOR cur_facturas_pendientes IS
        SELECT idFactura, Fecha, Total
        FROM Factura
        WHERE Estado = 0;
    v_idFactura Factura.idFactura%TYPE;
    v_Fecha Factura.Fecha%TYPE;
    v_Total Factura.Total%TYPE;
BEGIN
    OPEN cur_facturas_pendientes;
    LOOP
        FETCH cur_facturas_pendientes INTO v_idFactura, v_Fecha, v_Total;
        EXIT WHEN cur_facturas_pendientes%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Factura: ' || v_idFactura || ', Fecha: ' || v_Fecha || ', Total: ' || v_Total);
    END LOOP;
    CLOSE cur_facturas_pendientes;
END;


-- Cursores 6
DECLARE
  CURSOR Cursor_Productos_Bajo_Stock IS
    SELECT Nombre, Cantidad FROM Producto WHERE Cantidad <= 10;
BEGIN
  FOR producto IN Cursor_Productos_Bajo_Stock LOOP
    DBMS_OUTPUT.PUT_LINE('Producto: ' || producto.Nombre || ' - Cantidad: ' || producto.Cantidad);
  END LOOP;
END;
/



-- Cursores 7
DECLARE
  CURSOR Cursor_Proveedores_Canton IS
    SELECT p.NombreProveedor, c.nombreCanton
    FROM Proveedor p
    JOIN Distritos d ON p.idDistritos = d.idDistritos
    JOIN Cantones c ON d.idCantones = c.idCantones;
BEGIN
  FOR proveedor IN Cursor_Proveedores_Canton LOOP
    DBMS_OUTPUT.PUT_LINE('Proveedor: ' || proveedor.NombreProveedor || ' - Cantón: ' || proveedor.nombreCanton);
  END LOOP;
END;
/




-- Cursores 8
DECLARE
  CURSOR Cursor_Productos_Mas_Caros IS
    SELECT Nombre, Precio FROM Producto ORDER BY Precio DESC FETCH FIRST 5 ROWS ONLY;
BEGIN
  FOR producto IN Cursor_Productos_Mas_Caros LOOP
    DBMS_OUTPUT.PUT_LINE('Producto: ' || producto.Nombre || ' - Precio: ' || producto.Precio);
  END LOOP;
END;
/

-- Cursores 9

DECLARE
  CURSOR Cursor_Telefonos_Compradores IS
    SELECT c.Nombre, t.NumeroTelefono
    FROM Comprador c
    JOIN Telefonos_has_Comprador thc ON c.idComprador = thc.idComprador
    JOIN Telefonos t ON thc.idTelefonos = t.idTelefonos;
BEGIN
  FOR tel IN Cursor_Telefonos_Compradores LOOP
    DBMS_OUTPUT.PUT_LINE('Comprador: ' || tel.Nombre || ' - Teléfono: ' || tel.NumeroTelefono);
  END LOOP;
END;
/

-- Cursores 10
DECLARE
  CURSOR Cursor_Usuarios_Admin IS
    SELECT Nombre, Username FROM Usuario u
    JOIN tipoUsuario t ON u.tipoUsuario_idtipoUsuario = t.idtipoUsuario
    WHERE t.Descripcion = 'admin';
BEGIN
  FOR user IN Cursor_Usuarios_Admin LOOP
    DBMS_OUTPUT.PUT_LINE('Admin: ' || user.Nombre || ' (' || user.Username || ')');
  END LOOP;
END;
/


-- Cursores 11
DECLARE
  CURSOR Cursor_Telefonos_Compradores IS
    SELECT c.Nombre, t.NumeroTelefono
    FROM Comprador c
    JOIN Telefonos_has_Comprador thc ON c.idComprador = thc.idComprador
    JOIN Telefonos t ON thc.idTelefonos = t.idTelefonos;
BEGIN
  FOR tel IN Cursor_Telefonos_Compradores LOOP
    DBMS_OUTPUT.PUT_LINE('Comprador: ' || tel.Nombre || ' - Teléfono: ' || tel.NumeroTelefono);
  END LOOP;
END;
/


-- Cursores 12
DECLARE
  CURSOR Cursor_Facturas_Pendientes IS
    SELECT idFactura, Total, Estado FROM Factura WHERE Estado = 0;
BEGIN
  FOR f IN Cursor_Facturas_Pendientes LOOP
    DBMS_OUTPUT.PUT_LINE('Factura pendiente - ID: ' || f.idFactura || ', Monto: ' || f.Total);
  END LOOP;
END;
/


-- Cursores 13
DECLARE
  CURSOR Cursor_Detalles_Ventas IS
    SELECT f.idFactura, v.idVenta, v.Cantidad, p.Nombre
    FROM Venta v
    JOIN Producto p ON v.idProductos = p.idProductos
    JOIN Factura f ON v.idFactura = f.idFactura;
BEGIN
  FOR venta IN Cursor_Detalles_Ventas LOOP
    DBMS_OUTPUT.PUT_LINE('Factura ' || venta.idFactura || ' - Venta ' || venta.idVenta || ' - Producto: ' || venta.Nombre || ' - Cantidad: ' || venta.Cantidad);
  END LOOP;
END;
/


-- Cursores 14
DECLARE
  CURSOR Cursor_Productos_Categoria IS
    SELECT c.Nombre AS Categoria, p.Nombre AS Producto
    FROM Producto p
    JOIN Categorias c ON p.idCategorias = c.idCategorias
    ORDER BY c.Nombre;
BEGIN
  FOR prod IN Cursor_Productos_Categoria LOOP
    DBMS_OUTPUT.PUT_LINE('Categoría: ' || prod.Categoria || ' - Producto: ' || prod.Producto);
  END LOOP;
END;
/


-- Cursores 15
DECLARE
  CURSOR Cursor_Pedidos_Usuario IS
    SELECT u.Nombre || ' ' || u.Apellido AS Usuario, COUNT(p.idFactura) AS TotalPedidos
    FROM Usuario u
    JOIN Factura p ON u.idUsuario = p.Usuario_idUsuario
    GROUP BY u.Nombre, u.Apellido;
BEGIN
  FOR ped IN Cursor_Pedidos_Usuario LOOP
    DBMS_OUTPUT.PUT_LINE('Usuario: ' || ped.Usuario || ' - Pedidos: ' || ped.TotalPedidos);
  END LOOP;
END;
/






-- ========================
-- PAQUETESS
-- ========================



-- PAQUETES 1
CREATE OR REPLACE PACKAGE paquete_productos AS
  PROCEDURE agregar_producto(p_nombre VARCHAR2, p_precio NUMBER);
  FUNCTION obtener_precio(p_nombre VARCHAR2) RETURN NUMBER;
END paquete_productos;
/
CREATE OR REPLACE PACKAGE BODY paquete_productos AS
  PROCEDURE agregar_producto(p_nombre VARCHAR2, p_precio NUMBER) IS
  BEGIN
    INSERT INTO Producto (Nombre, Precio) VALUES (p_nombre, p_precio);
  END;

  FUNCTION obtener_precio(p_nombre VARCHAR2) RETURN NUMBER IS
    v_precio NUMBER;
  BEGIN
    SELECT Precio INTO v_precio FROM Producto WHERE Nombre = p_nombre;
    RETURN v_precio;
  END;
END paquete_productos;
/




-- PAQUETES 2

CREATE OR REPLACE PACKAGE paquete_clientes AS
  PROCEDURE agregar_cliente(p_nombre VARCHAR2, p_apellidos VARCHAR2, p_correo VARCHAR2);
  FUNCTION total_clientes RETURN NUMBER;
END paquete_clientes;
/
CREATE OR REPLACE PACKAGE BODY paquete_clientes AS
  PROCEDURE agregar_cliente(p_nombre VARCHAR2, p_apellidos VARCHAR2, p_correo VARCHAR2) IS
  BEGIN
    INSERT INTO Comprador (Nombre, Apellidos, Correo) VALUES (p_nombre, p_apellidos, p_correo);
  END;

  FUNCTION total_clientes RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_total FROM Comprador;
    RETURN v_total;
  END;
END paquete_clientes;
/




-- PAQUETES 3
CREATE OR REPLACE PACKAGE paquete_facturas AS
  FUNCTION calcular_total_factura(p_idFactura NUMBER) RETURN NUMBER;
END paquete_facturas;
/
CREATE OR REPLACE PACKAGE BODY paquete_facturas AS
  FUNCTION calcular_total_factura(p_idFactura NUMBER) RETURN NUMBER IS
    v_total NUMBER;
  BEGIN
    SELECT SUM(Precio * Cantidad) INTO v_total
    FROM Venta v
    JOIN Producto p ON v.idProductos = p.idProductos
    WHERE v.idFactura = p_idFactura;
    RETURN v_total;
  END;
END paquete_facturas;
/




-- PAQUETES 4
CREATE OR REPLACE PACKAGE paquete_ventas AS
  PROCEDURE registrar_venta(p_idProducto NUMBER, p_cantidad NUMBER, p_idFactura NUMBER);
END paquete_ventas;
/
CREATE OR REPLACE PACKAGE BODY paquete_ventas AS
  PROCEDURE registrar_venta(p_idProducto NUMBER, p_cantidad NUMBER, p_idFactura NUMBER) IS
  BEGIN
    INSERT INTO Venta (idProductos, Cantidad, idFactura) VALUES (p_idProducto, p_cantidad, p_idFactura);
  END;
END paquete_ventas;
/



-- PAQUETES 5
CREATE OR REPLACE PACKAGE paquete_usuario AS
  FUNCTION obtener_rol(p_username VARCHAR2) RETURN VARCHAR2;
END paquete_usuario;
/
CREATE OR REPLACE PACKAGE BODY paquete_usuario AS
  FUNCTION obtener_rol(p_username VARCHAR2) RETURN VARCHAR2 IS
    v_rol VARCHAR2(45);
  BEGIN
    SELECT t.Descripcion INTO v_rol
    FROM Usuario u
    JOIN tipoUsuario t ON u.tipoUsuario_idtipoUsuario = t.idtipoUsuario
    WHERE u.Username = p_username;
    RETURN v_rol;
  END;
END paquete_usuario;
/


-- PAQUETES 6


CREATE OR REPLACE PACKAGE pkg_venta AS
  PROCEDURE registrar_venta(
    p_cantidad IN VARCHAR2,
    p_idProducto IN NUMBER,
    p_idFactura IN NUMBER,
    p_idEntrega IN NUMBER,
    p_idSucursal IN NUMBER
  );

  FUNCTION obtener_total_ventas RETURN NUMBER;
END pkg_venta;
/

CREATE OR REPLACE PACKAGE BODY pkg_venta AS
  PROCEDURE registrar_venta(
    p_cantidad IN VARCHAR2,
    p_idProducto IN NUMBER,
    p_idFactura IN NUMBER,
    p_idEntrega IN NUMBER,
    p_idSucursal IN NUMBER
  ) IS
  BEGIN
    INSERT INTO Venta(Cantidad, idProductos, idFactura, Entrega_idEntrega, Sucursal_idSucursal)
    VALUES(p_cantidad, p_idProducto, p_idFactura, p_idEntrega, p_idSucursal);
  END;

  FUNCTION obtener_total_ventas RETURN NUMBER IS
    total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO total FROM Venta;
    RETURN total;
  END;
END pkg_venta;
/



-- PAQUETES 7


CREATE OR REPLACE PACKAGE pkg_direccion AS
  PROCEDURE registrar_distrito(p_nombre IN VARCHAR2, p_idCanton IN NUMBER);
  FUNCTION contar_distritos RETURN NUMBER;
END pkg_direccion;
/

CREATE OR REPLACE PACKAGE BODY pkg_direccion AS
  PROCEDURE registrar_distrito(p_nombre IN VARCHAR2, p_idCanton IN NUMBER) IS
  BEGIN
    INSERT INTO Distritos(nombreDistrito, idCantones) VALUES(p_nombre, p_idCanton);
  END;

  FUNCTION contar_distritos RETURN NUMBER IS
    total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO total FROM Distritos;
    RETURN total;
  END;
END pkg_direccion;
/


-- PAQUETES 8

CREATE OR REPLACE PACKAGE pkg_entrega AS
  PROCEDURE nueva_entrega(p_descripcion IN VARCHAR2, p_fecha IN DATE);
  FUNCTION total_entregas RETURN NUMBER;
END pkg_entrega;
/

CREATE OR REPLACE PACKAGE BODY pkg_entrega AS
  PROCEDURE nueva_entrega(p_descripcion IN VARCHAR2, p_fecha IN DATE) IS
  BEGIN
    INSERT INTO Entrega(DescripcionEntrega, fechaEntrega) VALUES(p_descripcion, p_fecha);
  END;

  FUNCTION total_entregas RETURN NUMBER IS
    total NUMBER;
  BEGIN
    SELECT COUNT(*) INTO total FROM Entrega;
    RETURN total;
  END;
END pkg_entrega;
/




-- PAQUETES 9

CREATE OR REPLACE PACKAGE pkg_factura AS
  PROCEDURE actualizar_estado(p_idFactura IN NUMBER, p_estado IN NUMBER);
  FUNCTION obtener_estado(p_idFactura IN NUMBER) RETURN NUMBER;
END pkg_factura;
/

CREATE OR REPLACE PACKAGE BODY pkg_factura AS
  PROCEDURE actualizar_estado(p_idFactura IN NUMBER, p_estado IN NUMBER) IS
  BEGIN
    UPDATE Factura SET Estado = p_estado WHERE idFactura = p_idFactura;
  END;

  FUNCTION obtener_estado(p_idFactura IN NUMBER) RETURN NUMBER IS
    estado NUMBER;
  BEGIN
    SELECT Estado INTO estado FROM Factura WHERE idFactura = p_idFactura;
    RETURN estado;
  END;
END pkg_factura;
/


-- PAQUETES 10

CREATE OR REPLACE PACKAGE pkg_categorias AS
  PROCEDURE activar_categoria(p_idCategoria IN NUMBER);
  PROCEDURE desactivar_categoria(p_idCategoria IN NUMBER);
END pkg_categorias;
/

CREATE OR REPLACE PACKAGE BODY pkg_categorias AS
  PROCEDURE activar_categoria(p_idCategoria IN NUMBER) IS
  BEGIN
    UPDATE Categorias SET Activo = 'Sí' WHERE idCategorias = p_idCategoria;
  END;

  PROCEDURE desactivar_categoria(p_idCategoria IN NUMBER) IS
  BEGIN
    UPDATE Categorias SET Activo = 'No' WHERE idCategorias = p_idCategoria;
  END;
END pkg_categorias;
/

