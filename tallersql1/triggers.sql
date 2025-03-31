-- 1. Trigger que registra cambios de salario en HistorialSalarios
DELIMITER //
CREATE TRIGGER trg_registrar_cambio_salario
AFTER UPDATE ON Empleados
FOR EACH ROW
BEGIN
    IF OLD.salario != NEW.salario THEN
        INSERT INTO HistorialSalarios (empleado_id, salario_anterior, salario_nuevo)
        VALUES (NEW.id, OLD.salario, NEW.salario);
    END IF;
END //
DELIMITER ;

-- 2. Trigger que evita borrar productos con pedidos activos
DELIMITER //
CREATE TRIGGER trg_evitar_borrar_producto_con_pedidos
BEFORE DELETE ON Productos
FOR EACH ROW
BEGIN
    DECLARE v_pedidos_relacionados INT;
    
    SELECT COUNT(*) INTO v_pedidos_relacionados
    FROM DetallesPedido
    WHERE producto_id = OLD.id;
    
    IF v_pedidos_relacionados > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar un producto con pedidos asociados';
    END IF;
END //
DELIMITER ;

-- 3. Trigger que registra actualizaciones de pedidos en HistorialPedidos
DELIMITER //
CREATE TRIGGER trg_registrar_actualizacion_pedido
AFTER UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    IF OLD.total != NEW.total THEN
        INSERT INTO HistorialPedidos (pedido_id, cliente_id, cambio)
        VALUES (NEW.id, NEW.cliente_id, CONCAT('Total modificado de ', OLD.total, ' a ', NEW.total));
    END IF;
END //
DELIMITER ;

-- 4. Trigger que actualiza el inventario al registrar un pedido
-- (Asumiendo que existe una tabla Inventario con campo producto_id y cantidad)
DELIMITER //
CREATE TRIGGER trg_actualizar_inventario_pedido
AFTER INSERT ON DetallesPedido
FOR EACH ROW
BEGIN
    UPDATE Inventario
    SET cantidad = cantidad - NEW.cantidad
    WHERE producto_id = NEW.producto_id;
END //
DELIMITER ;

-- 5. Trigger que evita actualizaciones de precio a menos de $1
DELIMITER //
CREATE TRIGGER trg_validar_precio_producto
BEFORE UPDATE ON Productos
FOR EACH ROW
BEGIN
    IF NEW.precio < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio no puede ser menor a $1';
    END IF;
END //
DELIMITER ;

-- 6. Trigger que registra la creación de pedidos en HistorialPedidos
DELIMITER //
CREATE TRIGGER trg_registrar_creacion_pedido
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    INSERT INTO HistorialPedidos (pedido_id, cliente_id, cambio)
    VALUES (NEW.id, NEW.cliente_id, 'Pedido creado');
END //
DELIMITER ;

-- 7. Trigger que mantiene actualizado el total de cada pedido
DELIMITER //
CREATE TRIGGER trg_actualizar_total_pedido
AFTER INSERT ON DetallesPedido
FOR EACH ROW
BEGIN
    DECLARE v_total DECIMAL(10,2);
    
    SELECT SUM(cantidad * precio) INTO v_total
    FROM DetallesPedido
    WHERE pedido_id = NEW.pedido_id;
    
    UPDATE Pedidos
    SET total = v_total
    WHERE id = NEW.pedido_id;
END //
DELIMITER ;

-- 8. Trigger para validar que el cliente tenga ubicación
-- (Asumiendo que UbicacionCliente es un campo en la tabla Clientes)
DELIMITER //
CREATE TRIGGER trg_validar_ubicacion_cliente
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.UbicacionCliente IS NULL OR NEW.UbicacionCliente = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El cliente debe tener una ubicación registrada';
    END IF;
END //
DELIMITER ;

-- 9. Trigger que registra modificaciones en Proveedores
DELIMITER //
CREATE TRIGGER trg_registrar_modificacion_proveedor
AFTER UPDATE ON Proveedores
FOR EACH ROW
BEGIN
    INSERT INTO LogActividades (accion, entidad_id)
    VALUES ('Actualización proveedor', NEW.id);
END //
DELIMITER ;

-- 10. Trigger que registra cambios de puesto en empleados
DELIMITER //
CREATE TRIGGER trg_registrar_cambio_contrato
AFTER UPDATE ON Empleados
FOR EACH ROW
BEGIN
    IF OLD.puesto != NEW.puesto THEN
        INSERT INTO HistorialContratos (empleado_id, puesto_anterior, puesto_nuevo)
        VALUES (NEW.id, OLD.puesto, NEW.puesto);
    END IF;
END //
DELIMITER ;