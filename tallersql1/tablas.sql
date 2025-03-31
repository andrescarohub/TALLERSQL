CREATE DATABASE vtaszfs;
USE vtaszfs;

-- Tabla Clientes
CREATE TABLE Clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    email VARCHAR(100) UNIQUE
);

-- Tabla Proveedores
CREATE TABLE Proveedores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100)
);

-- Tabla Direcciones
CREATE TABLE Direcciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    direccion VARCHAR(255),
    ciudad VARCHAR(100),
    estado VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(50)
);

-- Tabla ProveedoresDireccion
CREATE TABLE ProveedoresDireccion(
    id INT PRIMARY KEY AUTO_INCREMENT,
    proveedor_id INT,
    direccion_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id),
    FOREIGN KEY (direccion_id) REFERENCES Direcciones(id)
);

-- Tabla ClientesDireccion
CREATE TABLE ClientesDireccion(
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    direccion_id INT,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id),
    FOREIGN KEY (direccion_id) REFERENCES Direcciones(id)
);

-- Tabla Empleados
CREATE TABLE Empleados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    puesto VARCHAR(50),
    salario DECIMAL(10, 2),
    fecha_contratacion DATE
);

-- Tabla EmpleadosProveedores
CREATE TABLE EmpleadosProveedores (
	id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT,
    proveedor_id INT,
    FOREIGN KEY (empleado_id) REFERENCES Empleados(id),
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id)
);

-- Tabla ContactoProveedores
CREATE TABLE ContactoProveedores(
	id INT PRIMARY KEY AUTO_INCREMENT,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    direccion VARCHAR(255),
    proveedor_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores (id)
);

-- Tabla TiposProductos
CREATE TABLE TiposProductos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_nombre VARCHAR(100),
    descripcion TEXT,
    padre_id INT NULL,
    FOREIGN KEY (padre_id) REFERENCES TiposProductos (id)
);

-- Tabla Productos
CREATE TABLE Productos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    precio DECIMAL(10, 2),
    proveedor_id INT,
    tipo_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id),
    FOREIGN KEY (tipo_id) REFERENCES TiposProductos(id)
);

-- Tabla Pedidos
CREATE TABLE Pedidos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    fecha DATE,
    total DECIMAL(10, 2),
    empleado_id INT,
    FOREIGN KEY (empleado_id) REFERENCES Empleados(id),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id)
);

-- Tabla DetallesPedido
CREATE TABLE DetallesPedido (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    producto_id INT,
    cantidad INT,
    precio DECIMAL(10, 2),
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);

-- Tabla HistorialPedidos
CREATE TABLE HistorialPedidos(
	id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    cliente_id INT,
    fecha_modificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    cambio VARCHAR(100),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id),
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(id)
);

-- Tabla Puestos
CREATE TABLE Puestos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR (50)
);

-- Tabla DatosEmpleado
CREATE TABLE DatosEmpleado(
	id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    puesto_id INT,
    salario DECIMAL(10, 2),
    fecha_contratacion DATE,
    FOREIGN KEY (puesto_id) REFERENCES Puestos (id)
);

-- Tabla Telefonos
CREATE TABLE Telefonos (
	id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    telefono VARCHAR (20),
    tipo VARCHAR (50),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id) 
);

-- Tabla HistorialSalarios
CREATE TABLE HistorialSalarios(
	id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT,
    salario_anterior DECIMAL (10,2),
    salario_nuevo DECIMAL (10,2),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES DatosEmpleado (id) ON DELETE CASCADE
);

-- Tabla HistorialContratos
CREATE TABLE HistorialContratos (
	id INT PRIMARY KEY AUTO_INCREMENT,
    empleado_id INT,
    puesto_anterior INT,
    puesto_nuevo INT,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empleado_id) REFERENCES DatosEmpleado(id)
);

-- Tabla LogActivivades
CREATE TABLE LogActividades (
	id INT PRIMARY KEY AUTO_INCREMENT,
    accion VARCHAR (50),
    entidad_id INT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);