
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
