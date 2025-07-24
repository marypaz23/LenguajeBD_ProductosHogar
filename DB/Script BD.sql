
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