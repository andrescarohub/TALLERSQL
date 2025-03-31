-- Paso 1: Crear función CalcularDescuento
DELIMITER //
CREATE FUNCTION CalcularDescuento(
    p_tipo_id INT,
    p_precio_original DECIMAL(10,2)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_precio_con_descuento DECIMAL(10,2);
    DECLARE v_tipo_nombre VARCHAR(100);
    
    SELECT tipo_nombre INTO v_tipo_nombre
    FROM TiposProductos
    WHERE id = p_tipo_id;
    
    IF v_tipo_nombre = 'Electrónica' THEN
        SET v_precio_con_descuento = p_precio_original * 0.9;
    ELSE
        SET v_precio_con_descuento = p_precio_original;
    END IF;
    
    RETURN v_precio_con_descuento;
END //
DELIMITER ;

-- Paso 2: Consulta con precios originales y con descuento
SELECT 
    p.nombre AS producto,
    p.precio AS precio_original,
    CalcularDescuento(p.tipo_id, p.precio) AS precio_con_descuento,
    tp.tipo_nombre AS categoria
FROM 
    Productos p
JOIN 
    TiposProductos tp ON p.tipo_id = tp.id;

    -- Primero necesitamos agregar fecha_nacimiento a la tabla Clientes
ALTER TABLE Clientes ADD COLUMN fecha_nacimiento DATE;

-- Paso 1: Crear función CalcularEdad
DELIMITER //
CREATE FUNCTION CalcularEdad(p_fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
END //
DELIMITER ;

-- Paso 2: Consultar clientes mayores de 18 años
SELECT 
    id,
    nombre,
    fecha_nacimiento,
    CalcularEdad(fecha_nacimiento) AS edad
FROM 
    Clientes
WHERE 
    CalcularEdad(fecha_nacimiento) >= 18;
    -- Paso 1: Crear función CalcularImpuesto
DELIMITER //
CREATE FUNCTION CalcularImpuesto(p_precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_precio * 1.15;
END //
DELIMITER ;

-- Paso 2: Consulta de productos con precio final
SELECT 
    nombre AS producto,
    precio AS precio_original,
    CalcularImpuesto(precio) AS precio_con_impuesto
FROM 
    Productos;
    -- Paso 1: Crear función TotalPedidosCliente
DELIMITER //
CREATE FUNCTION TotalPedidosCliente(p_cliente_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    
    SELECT SUM(total) INTO v_total
    FROM Pedidos
    WHERE cliente_id = p_cliente_id;
    
    RETURN IFNULL(v_total, 0);
END //
DELIMITER ;

-- Paso 2: Consulta de clientes con total > $1000
SELECT 
    c.id,
    c.nombre,
    TotalPedidosCliente(c.id) AS total_pedidos
FROM 
    Clientes c
WHERE 
    TotalPedidosCliente(c.id) > 1000
ORDER BY 
    total_pedidos DESC;
    -- Paso 1: Crear función SalarioAnual
DELIMITER //
CREATE FUNCTION SalarioAnual(p_salario_mensual DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_salario_mensual * 12;
END //
DELIMITER ;

-- Paso 2: Consulta de empleados con salario anual > $50,000
SELECT 
    id,
    nombre,
    salario,
    SalarioAnual(salario) AS salario_anual
FROM 
    Empleados
WHERE 
    SalarioAnual(salario) > 50000
ORDER BY 
    salario_anual DESC;
    -- Paso 1: Crear función Bonificacion
DELIMITER //
CREATE FUNCTION Bonificacion(p_salario DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_salario * 0.1;
END //
DELIMITER ;

-- Paso 2: Consulta de salarios ajustados
SELECT 
    id,
    nombre,
    salario,
    Bonificacion(salario) AS bonificacion,
    (salario + Bonificacion(salario)) AS salario_ajustado
FROM 
    Empleados;
    -- Paso 1: Crear función DiasDesdeUltimoPedido
DELIMITER //
CREATE FUNCTION DiasDesdeUltimoPedido(p_cliente_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_ultima_fecha DATE;
    
    SELECT MAX(fecha) INTO v_ultima_fecha
    FROM Pedidos
    WHERE cliente_id = p_cliente_id;
    
    RETURN IFNULL(DATEDIFF(CURDATE(), v_ultima_fecha), -1);
END //
DELIMITER ;

-- Paso 2: Consulta de clientes con pedidos en últimos 30 días
SELECT 
    c.id,
    c.nombre,
    MAX(p.fecha) AS ultimo_pedido,
    DiasDesdeUltimoPedido(c.id) AS dias_desde_ultimo_pedido
FROM 
    Clientes c
JOIN 
    Pedidos p ON c.id = p.cliente_id
GROUP BY 
    c.id, c.nombre
HAVING 
    DiasDesdeUltimoPedido(c.id) <= 30
ORDER BY 
    dias_desde_ultimo_pedido;
    -- Primero necesitamos crear la tabla Inventario si no existe
CREATE TABLE IF NOT EXISTS Inventario (
    producto_id INT PRIMARY KEY,
    cantidad INT,
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);

-- Paso 1: Crear función TotalInventarioProducto
DELIMITER //
CREATE FUNCTION TotalInventarioProducto(p_producto_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    
    SELECT (i.cantidad * p.precio) INTO v_total
    FROM Inventario i
    JOIN Productos p ON i.producto_id = p.id
    WHERE i.producto_id = p_producto_id;
    
    RETURN IFNULL(v_total, 0);
END //
DELIMITER ;

-- Paso 2: Consulta de productos con inventario > $500
SELECT 
    p.id,
    p.nombre,
    i.cantidad,
    p.precio,
    TotalInventarioProducto(p.id) AS total_inventario
FROM 
    Productos p
JOIN 
    Inventario i ON p.id = i.producto_id
WHERE 
    TotalInventarioProducto(p.id) > 500
ORDER BY 
    total_inventario DESC;
    -- Paso 1: Crear tabla HistorialPrecios
CREATE TABLE HistorialPrecios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    producto_id INT,
    precio_anterior DECIMAL(10,2),
    precio_nuevo DECIMAL(10,2),
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES Productos(id)
);

-- Paso 2: Crear trigger RegistroCambioPrecio
DELIMITER //
CREATE TRIGGER RegistroCambioPrecio
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF OLD.precio != NEW.precio THEN
        INSERT INTO HistorialPrecios (producto_id, precio_anterior, precio_nuevo)
        VALUES (NEW.id, OLD.precio, NEW.precio);
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE ReporteVentasMensuales(
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    SELECT 
        e.id AS empleado_id,
        e.nombre AS empleado,
        SUM(p.total) AS total_ventas,
        COUNT(p.id) AS cantidad_pedidos
    FROM 
        Empleados e
    JOIN 
        Pedidos p ON e.id = p.empleado_id
    WHERE 
        MONTH(p.fecha) = p_mes AND YEAR(p.fecha) = p_anio
    GROUP BY 
        e.id, e.nombre
    ORDER BY 
        total_ventas DESC;
END //
DELIMITER ;

-- Ejemplo de uso: CALL ReporteVentasMensuales(6, 2023);
SELECT 
    pr.id AS proveedor_id,
    pr.nombre AS proveedor,
    p.nombre AS producto_mas_vendido,
    dp.cantidad_total AS cantidad_vendida
FROM 
    Proveedores pr
JOIN 
    Productos p ON pr.id = p.proveedor_id
JOIN (
    SELECT 
        producto_id,
        SUM(cantidad) AS cantidad_total
    FROM 
        DetallesPedido
    GROUP BY 
        producto_id
) dp ON p.id = dp.producto_id
WHERE 
    (p.proveedor_id, dp.cantidad_total) IN (
        SELECT 
            p2.proveedor_id,
            MAX(dp2.cantidad_total)
        FROM 
            Productos p2
        JOIN (
            SELECT 
                producto_id,
                SUM(cantidad) AS cantidad_total
            FROM 
                DetallesPedido
            GROUP BY 
                producto_id
        ) dp2 ON p2.id = dp2.producto_id
        GROUP BY 
            p2.proveedor_id
    )
ORDER BY 
    pr.nombre;
    DELIMITER //
CREATE FUNCTION EstadoStock(p_cantidad INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    IF p_cantidad > 100 THEN
        RETURN 'Alto';
    ELSEIF p_cantidad > 50 THEN
        RETURN 'Medio';
    ELSE
        RETURN 'Bajo';
    END IF;
END //
DELIMITER ;

-- Consulta con estado de stock
SELECT 
    p.id,
    p.nombre,
    i.cantidad,
    EstadoStock(i.cantidad) AS estado_stock
FROM 
    Productos p
JOIN 
    Inventario i ON p.id = i.producto_id
ORDER BY 
    i.cantidad DESC;
    DELIMITER //
CREATE TRIGGER ActualizarInventario
BEFORE INSERT ON DetallesPedido
FOR EACH ROW
BEGIN
    DECLARE v_stock_actual INT;
    
    SELECT cantidad INTO v_stock_actual
    FROM Inventario
    WHERE producto_id = NEW.producto_id;
    
    IF v_stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para este producto';
    ELSE
        UPDATE Inventario
        SET cantidad = cantidad - NEW.cantidad
        WHERE producto_id = NEW.producto_id;
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE ClientesInactivos()
BEGIN
    SELECT 
        c.id,
        c.nombre,
        MAX(p.fecha) AS ultimo_pedido,
        DATEDIFF(CURDATE(), MAX(p.fecha)) AS dias_inactivo
    FROM 
        Clientes c
    LEFT JOIN 
        Pedidos p ON c.id = p.cliente_id
    GROUP BY 
        c.id, c.nombre
    HAVING 
        ultimo_pedido IS NULL OR dias_inactivo > 180
    ORDER BY 
        dias_inactivo DESC;
END //
DELIMITER ;

-- Ejemplo de uso: CALL ClientesInactivos();