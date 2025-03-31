-- 1. Procedimiento para actualizar el precio de todos los productos de un proveedor
DELIMITER //
CREATE PROCEDURE ActualizarPreciosProveedor(
    IN p_proveedor_id INT,
    IN p_porcentaje DECIMAL(5,2),
    IN p_operacion VARCHAR(10) -- 'AUMENTO' o 'DESCUENTO'
)
BEGIN
    IF p_operacion = 'AUMENTO' THEN
        UPDATE Productos 
        SET precio = precio * (1 + p_porcentaje/100)
        WHERE proveedor_id = p_proveedor_id;
    ELSEIF p_operacion = 'DESCUENTO' THEN
        UPDATE Productos 
        SET precio = precio * (1 - p_porcentaje/100)
        WHERE proveedor_id = p_proveedor_id;
    END IF;
    
    SELECT ROW_COUNT() AS productos_actualizados;
END //
DELIMITER ;

-- 2. Procedimiento que devuelve la dirección de un cliente por ID
DELIMITER //
CREATE PROCEDURE ObtenerDireccionCliente(
    IN p_cliente_id INT
)
BEGIN
    SELECT 
        d.direccion,
        d.ciudad,
        d.estado,
        d.codigo_postal,
        d.pais
    FROM 
        Direcciones d
    JOIN 
        ClientesDireccion cd ON d.id = cd.direccion_id
    WHERE 
        cd.cliente_id = p_cliente_id;
END //
DELIMITER ;

-- 3. Procedimiento para registrar un pedido nuevo y sus detalles
DELIMITER //
CREATE PROCEDURE RegistrarNuevoPedido(
    IN p_cliente_id INT,
    IN p_empleado_id INT,
    IN p_productos JSON -- Formato: [{"producto_id": 1, "cantidad": 2}, {...}]
)
BEGIN
    DECLARE v_pedido_id INT;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE v_producto_id INT;
    DECLARE v_cantidad INT;
    DECLARE v_precio DECIMAL(10,2);
    
    -- Crear el pedido
    INSERT INTO Pedidos (cliente_id, fecha, total, empleado_id)
    VALUES (p_cliente_id, CURDATE(), 0, p_empleado_id);
    
    SET v_pedido_id = LAST_INSERT_ID();
    
    -- Procesar cada producto
    WHILE i < JSON_LENGTH(p_productos) DO
        SET v_producto_id = JSON_EXTRACT(p_productos, CONCAT('$[', i, '].producto_id'));
        SET v_cantidad = JSON_EXTRACT(p_productos, CONCAT('$[', i, '].cantidad'));
        
        -- Obtener precio actual del producto
        SELECT precio INTO v_precio FROM Productos WHERE id = v_producto_id;
        
        -- Agregar detalle del pedido
        INSERT INTO DetallesPedido (pedido_id, producto_id, cantidad, precio)
        VALUES (v_pedido_id, v_producto_id, v_cantidad, v_precio);
        
        -- Acumular total
        SET v_total = v_total + (v_cantidad * v_precio);
        SET i = i + 1;
    END WHILE;
    
    -- Actualizar total del pedido
    UPDATE Pedidos SET total = v_total WHERE id = v_pedido_id;
    
    SELECT v_pedido_id AS nuevo_pedido_id, v_total AS total_pedido;
END //
DELIMITER ;

-- 4. Procedimiento para calcular el total de ventas de un cliente
DELIMITER //
CREATE PROCEDURE CalcularTotalVentasCliente(
    IN p_cliente_id INT
)
BEGIN
    SELECT 
        c.id AS cliente_id,
        c.nombre AS cliente,
        SUM(p.total) AS total_ventas,
        COUNT(p.id) AS cantidad_pedidos
    FROM 
        Clientes c
    JOIN 
        Pedidos p ON c.id = p.cliente_id
    WHERE 
        c.id = p_cliente_id
    GROUP BY 
        c.id, c.nombre;
END //
DELIMITER ;

-- 5. Procedimiento para obtener empleados por puesto
DELIMITER //
CREATE PROCEDURE ListarEmpleadosPorPuesto(
    IN p_puesto VARCHAR(50)
)
BEGIN
    SELECT 
        id,
        nombre,
        puesto,
        salario,
        fecha_contratacion
    FROM 
        Empleados
    WHERE 
        puesto = p_puesto
    ORDER BY 
        nombre;
END //
DELIMITER ;

-- 6. Procedimiento para actualizar salario de empleados por puesto
DELIMITER //
CREATE PROCEDURE ActualizarSalariosPorPuesto(
    IN p_puesto VARCHAR(50),
    IN p_porcentaje DECIMAL(5,2),
    IN p_operacion VARCHAR(10) -- 'AUMENTO' o 'DESCUENTO'
)
BEGIN
    IF p_operacion = 'AUMENTO' THEN
        UPDATE Empleados 
        SET salario = salario * (1 + p_porcentaje/100)
        WHERE puesto = p_puesto;
    ELSEIF p_operacion = 'DESCUENTO' THEN
        UPDATE Empleados 
        SET salario = salario * (1 - p_porcentaje/100)
        WHERE puesto = p_puesto;
    END IF;
    
    SELECT ROW_COUNT() AS empleados_actualizados;
END //
DELIMITER ;

-- 7. Procedimiento para listar pedidos entre dos fechas
DELIMITER //
CREATE PROCEDURE ListarPedidosPorFecha(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    SELECT 
        p.id AS pedido_id,
        p.fecha,
        p.total,
        c.nombre AS cliente,
        e.nombre AS empleado
    FROM 
        Pedidos p
    JOIN 
        Clientes c ON p.cliente_id = c.id
    JOIN 
        Empleados e ON p.empleado_id = e.id
    WHERE 
        p.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    ORDER BY 
        p.fecha DESC;
END //
DELIMITER ;

-- 8. Procedimiento para aplicar descuento a productos de una categoría
DELIMITER //
CREATE PROCEDURE AplicarDescuentoPorCategoria(
    IN p_tipo_id INT,
    IN p_porcentaje DECIMAL(5,2)
)
BEGIN
    UPDATE Productos
    SET precio = precio * (1 - p_porcentaje/100)
    WHERE tipo_id = p_tipo_id;
    
    SELECT ROW_COUNT() AS productos_actualizados;
END //
DELIMITER ;

-- 9. Procedimiento para listar proveedores de un tipo de producto
DELIMITER //
CREATE PROCEDURE ListarProveedoresPorTipoProducto(
    IN p_tipo_id INT
)
BEGIN
    SELECT DISTINCT
        p.id AS proveedor_id,
        p.nombre AS proveedor,
        tp.tipo_nombre AS tipo_producto
    FROM 
        Proveedores p
    JOIN 
        Productos pr ON p.id = pr.proveedor_id
    JOIN 
        TiposProductos tp ON pr.tipo_id = tp.id
    WHERE 
        pr.tipo_id = p_tipo_id OR tp.padre_id = p_tipo_id
    ORDER BY 
        p.nombre;
END //
DELIMITER ;

-- 10. Procedimiento que devuelve el pedido de mayor valor
DELIMITER //
CREATE PROCEDURE ObtenerPedidoMayorValor()
BEGIN
    SELECT 
        p.id AS pedido_id,
        p.fecha,
        p.total,
        c.nombre AS cliente,
        e.nombre AS empleado
    FROM 
        Pedidos p
    JOIN 
        Clientes c ON p.cliente_id = c.id
    JOIN 
        Empleados e ON p.empleado_id = e.id
    ORDER BY 
        p.total DESC
    LIMIT 1;
END //
DELIMITER ;