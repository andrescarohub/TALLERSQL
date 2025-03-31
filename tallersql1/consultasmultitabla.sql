-- 1. Listar todos los pedidos y el cliente asociado
SELECT 
    p.id AS pedido_id,
    p.fecha AS fecha_pedido,
    p.total AS total_pedido,
    c.id AS cliente_id,
    c.nombre AS nombre_cliente,
    c.email AS email_cliente
FROM 
    Pedidos p
JOIN 
    Clientes c ON p.cliente_id = c.id
ORDER BY 
    p.fecha DESC;

-- 2. Mostrar la ubicación de cada cliente en sus pedidos
SELECT 
    p.id AS pedido_id,
    p.fecha AS fecha_pedido,
    c.nombre AS nombre_cliente,
    d.direccion,
    d.ciudad,
    d.estado,
    d.codigo_postal,
    d.pais
FROM 
    Pedidos p
JOIN 
    Clientes c ON p.cliente_id = c.id
JOIN 
    ClientesDireccion cd ON c.id = cd.cliente_id
JOIN 
    Direcciones d ON cd.direccion_id = d.id
ORDER BY 
    p.fecha DESC;

-- 3. Listar productos junto con el proveedor y tipo de producto
SELECT 
    pr.id AS producto_id,
    pr.nombre AS nombre_producto,
    pr.precio,
    p.nombre AS nombre_proveedor,
    tp.tipo_nombre AS tipo_producto,
    tp.descripcion AS descripcion_tipo
FROM 
    Productos pr
JOIN 
    Proveedores p ON pr.proveedor_id = p.id
JOIN 
    TiposProductos tp ON pr.tipo_id = tp.id
ORDER BY 
    p.nombre, tp.tipo_nombre;

-- 4. Consultar empleados que gestionan pedidos de clientes en una ciudad específica (ej: 'Madrid')
SELECT DISTINCT
    e.id AS empleado_id,
    e.nombre AS nombre_empleado,
    e.puesto,
    d.ciudad AS ciudad_cliente
FROM 
    Empleados e
JOIN 
    Pedidos p ON e.id = p.empleado_id
JOIN 
    Clientes c ON p.cliente_id = c.id
JOIN 
    ClientesDireccion cd ON c.id = cd.cliente_id
JOIN 
    Direcciones d ON cd.direccion_id = d.id
WHERE 
    d.ciudad = 'Madrid';

-- 5. Consultar los 5 productos más vendidos
SELECT 
    p.id AS producto_id,
    p.nombre AS nombre_producto,
    SUM(dp.cantidad) AS total_vendido,
    SUM(dp.cantidad * dp.precio) AS ingreso_total
FROM 
    Productos p
JOIN 
    DetallesPedido dp ON p.id = dp.producto_id
GROUP BY 
    p.id, p.nombre
ORDER BY 
    total_vendido DESC
LIMIT 5;

-- 6. Obtener la cantidad total de pedidos por cliente y ciudad
SELECT 
    c.id AS cliente_id,
    c.nombre AS nombre_cliente,
    d.ciudad,
    COUNT(p.id) AS total_pedidos
FROM 
    Clientes c
JOIN 
    Pedidos p ON c.id = p.cliente_id
JOIN 
    ClientesDireccion cd ON c.id = cd.cliente_id
JOIN 
    Direcciones d ON cd.direccion_id = d.id
GROUP BY 
    c.id, c.nombre, d.ciudad
ORDER BY 
    total_pedidos DESC;

-- 7. Listar clientes y proveedores en la misma ciudad
SELECT 
    c.nombre AS nombre_cliente,
    p.nombre AS nombre_proveedor,
    d.ciudad
FROM 
    Clientes c
JOIN 
    ClientesDireccion cd ON c.id = cd.cliente_id
JOIN 
    Direcciones d ON cd.direccion_id = d.id
JOIN 
    ProveedoresDireccion pd ON pd.direccion_id = d.id
JOIN 
    Proveedores p ON pd.proveedor_id = p.id
ORDER BY 
    d.ciudad, c.nombre;

-- 8. Mostrar el total de ventas agrupado por tipo de producto
SELECT 
    tp.id AS tipo_id,
    tp.tipo_nombre,
    SUM(dp.cantidad * dp.precio) AS ventas_totales
FROM 
    TiposProductos tp
JOIN 
    Productos pr ON tp.id = pr.tipo_id
JOIN 
    DetallesPedido dp ON pr.id = dp.producto_id
GROUP BY 
    tp.id, tp.tipo_nombre
ORDER BY 
    ventas_totales DESC;

-- 9. Listar empleados que gestionan pedidos de productos de un proveedor específico (ej: id=1)
SELECT DISTINCT
    e.id AS empleado_id,
    e.nombre AS nombre_empleado,
    pv.nombre AS nombre_proveedor
FROM 
    Empleados e
JOIN 
    Pedidos pe ON e.id = pe.empleado_id
JOIN 
    DetallesPedido dp ON pe.id = dp.pedido_id
JOIN 
    Productos pr ON dp.producto_id = pr.id
JOIN 
    Proveedores pv ON pr.proveedor_id = pv.id
WHERE 
    pv.id = 1;

-- 10. Obtener el ingreso total de cada proveedor a partir de los productos vendidos
SELECT 
    pv.id AS proveedor_id,
    pv.nombre AS nombre_proveedor,
    SUM(dp.cantidad * dp.precio) AS ingreso_total
FROM 
    Proveedores pv
JOIN 
    Productos pr ON pv.id = pr.proveedor_id
JOIN 
    DetallesPedido dp ON pr.id = dp.producto_id
GROUP BY 
    pv.id, pv.nombre
ORDER BY 
    ingreso_total DESC;