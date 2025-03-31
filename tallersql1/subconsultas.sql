-- =============================================
-- 5. Subconsultas
-- =============================================

-- 1. Consultar el producto más caro en cada categoría.
SELECT 
    tipo_id,
    (SELECT tipo_nombre FROM TiposProductos WHERE id = p.tipo_id) AS categoria,
    nombre,
    precio
FROM Productos p
WHERE precio = (
    SELECT MAX(precio) 
    FROM Productos 
    WHERE tipo_id = p.tipo_id
);

-- 2. Encontrar el cliente con mayor total en pedidos.
SELECT 
    c.id,
    c.nombre,
    (SELECT SUM(total) FROM Pedidos WHERE cliente_id = c.id) AS total_pedidos
FROM Clientes c
WHERE (SELECT SUM(total) FROM Pedidos WHERE cliente_id = c.id) = (
    SELECT MAX(total_por_cliente)
    FROM (
        SELECT cliente_id, SUM(total) AS total_por_cliente
        FROM Pedidos
        GROUP BY cliente_id
    ) AS totales
);

-- 3. Listar empleados que ganan más que el salario promedio.
SELECT 
    id,
    nombre,
    puesto,
    salario
FROM Empleados
WHERE salario > (
    SELECT AVG(salario)
    FROM Empleados
);

-- 4. Consultar productos que han sido pedidos más de 5 veces.
SELECT 
    p.id,
    p.nombre,
    p.precio,
    (SELECT COUNT(*) FROM DetallesPedido WHERE producto_id = p.id) AS veces_pedido
FROM Productos p
WHERE (
    SELECT COUNT(*)
    FROM DetallesPedido
    WHERE producto_id = p.id
) > 5;

-- 5. Listar pedidos cuyo total es mayor al promedio de todos los pedidos.
SELECT 
    id,
    cliente_id,
    fecha,
    total
FROM Pedidos
WHERE total > (
    SELECT AVG(total)
    FROM Pedidos
);

-- 6. Seleccionar los 3 proveedores con más productos.
SELECT 
    prov.id,
    prov.nombre,
    (SELECT COUNT(*) FROM Productos WHERE proveedor_id = prov.id) AS total_productos
FROM Proveedores prov
ORDER BY (
    SELECT COUNT(*)
    FROM Productos
    WHERE proveedor_id = prov.id
) DESC
LIMIT 3;

-- 7. Consultar productos con precio superior al promedio en su tipo.
SELECT 
    p.id,
    p.nombre,
    p.precio,
    p.tipo_id,
    (SELECT tipo_nombre FROM TiposProductos WHERE id = p.tipo_id) AS categoria
FROM Productos p
WHERE p.precio > (
    SELECT AVG(precio)
    FROM Productos
    WHERE tipo_id = p.tipo_id
);

-- 8. Mostrar clientes que han realizado más pedidos que la media.
SELECT 
    c.id,
    c.nombre,
    (SELECT COUNT(*) FROM Pedidos WHERE cliente_id = c.id) AS total_pedidos
FROM Clientes c
WHERE (
    SELECT COUNT(*)
    FROM Pedidos
    WHERE cliente_id = c.id
) > (
    SELECT AVG(pedidos_por_cliente)
    FROM (
        SELECT cliente_id, COUNT(*) AS pedidos_por_cliente
        FROM Pedidos
        GROUP BY cliente_id
    ) AS conteo
);

-- 9. Encontrar productos cuyo precio es mayor que el promedio de todos los productos.
SELECT 
    id,
    nombre,
    precio
FROM Productos
WHERE precio > (
    SELECT AVG(precio)
    FROM Productos
);

-- 10. Mostrar empleados cuyo salario es menor al promedio del departamento.
-- Nota: Como no hay campo de departamento explícito, asumiré que el puesto es equivalente a departamento.
SELECT 
    e1.id,
    e1.nombre,
    e1.puesto,
    e1.salario
FROM Empleados e1
WHERE e1.salario < (
    SELECT AVG(e2.salario)
    FROM Empleados e2
    WHERE e2.puesto = e1.puesto
);