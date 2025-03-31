-- 1. Función que recibe una fecha y devuelve los días transcurridos hasta hoy
DELIMITER //
CREATE FUNCTION DiasTranscurridos(p_fecha DATE) 
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN DATEDIFF(CURDATE(), p_fecha);
END //
DELIMITER ;

-- 2. Función para calcular el total con impuesto de un monto
DELIMITER //
CREATE FUNCTION CalcularTotalConImpuesto(
    p_monto DECIMAL(10,2),
    p_porcentaje_impuesto DECIMAL(5,2)
) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_monto * (1 + p_porcentaje_impuesto/100);
END //
DELIMITER ;

-- 3. Función que devuelve el total de pedidos de un cliente específico
DELIMITER //
CREATE FUNCTION TotalPedidosCliente(p_cliente_id INT) 
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(*) INTO v_total
    FROM Pedidos
    WHERE cliente_id = p_cliente_id;
    
    RETURN IFNULL(v_total, 0);
END //
DELIMITER ;

-- 4. Función para aplicar un descuento a un producto
DELIMITER //
CREATE FUNCTION AplicarDescuento(
    p_precio_original DECIMAL(10,2),
    p_porcentaje_descuento DECIMAL(5,2)
) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN p_precio_original * (1 - p_porcentaje_descuento/100);
END //
DELIMITER ;

-- 5. Función que indica si un cliente tiene dirección registrada
DELIMITER //
CREATE FUNCTION ClienteTieneDireccion(p_cliente_id INT) 
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_tiene_direccion BOOLEAN;
    
    SELECT EXISTS(
        SELECT 1 FROM ClientesDireccion 
        WHERE cliente_id = p_cliente_id
    ) INTO v_tiene_direccion;
    
    RETURN v_tiene_direccion;
END //
DELIMITER ;

-- 6. Función que devuelve el salario anual de un empleado
DELIMITER //
CREATE FUNCTION SalarioAnualEmpleado(p_empleado_id INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_salario DECIMAL(10,2);
    
    SELECT salario * 12 INTO v_salario
    FROM Empleados
    WHERE id = p_empleado_id;
    
    RETURN IFNULL(v_salario, 0);
END //
DELIMITER ;

-- 7. Función para calcular el total de ventas de un tipo de producto
DELIMITER //
CREATE FUNCTION VentasPorTipoProducto(p_tipo_id INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total_ventas DECIMAL(10,2);
    
    SELECT SUM(dp.cantidad * dp.precio) INTO v_total_ventas
    FROM DetallesPedido dp
    JOIN Productos p ON dp.producto_id = p.id
    WHERE p.tipo_id = p_tipo_id;
    
    RETURN IFNULL(v_total_ventas, 0);
END //
DELIMITER ;

-- 8. Función para devolver el nombre de un cliente por ID
DELIMITER //
CREATE FUNCTION NombreCliente(p_cliente_id INT) 
RETURNS VARCHAR(100)
READS SQL DATA
BEGIN
    DECLARE v_nombre VARCHAR(100);
    
    SELECT nombre INTO v_nombre
    FROM Clientes
    WHERE id = p_cliente_id;
    
    RETURN IFNULL(v_nombre, 'Cliente no encontrado');
END //
DELIMITER ;

-- 9. Función que recibe el ID de un pedido y devuelve su total
DELIMITER //
CREATE FUNCTION TotalPedido(p_pedido_id INT) 
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    
    SELECT total INTO v_total
    FROM Pedidos
    WHERE id = p_pedido_id;
    
    RETURN IFNULL(v_total, 0);
END //
DELIMITER ;

-- 10. Función que indica si un producto está en inventario
-- (Asumiendo que tenemos una tabla Inventario o usando los pedidos como referencia)
DELIMITER //
CREATE FUNCTION ProductoEnInventario(p_producto_id INT) 
RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_en_inventario BOOLEAN;
    
    -- Esta es una implementación básica, deberías adaptarla a tu modelo real
    SELECT EXISTS(
        SELECT 1 FROM Productos WHERE id = p_producto_id
    ) INTO v_en_inventario;
    
    RETURN v_en_inventario;
END //
DELIMITER ;