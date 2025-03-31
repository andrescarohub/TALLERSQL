   1. Obtener la lista de todos los pedidos con los nombres de clientes usando INNER JOIN
SELECT 
    Pedidos.id AS pedido_id, 
    Pedidos.fecha, 
    Pedidos.total, 
    Clientes.nombre AS nombre_cliente
FROM Pedidos
INNER JOIN Clientes ON Pedidos.cliente_id = Clientes.id;
2. Listar los productos y proveedores que los suministran con INNER JOIN
SELECT 
    Productos.id AS producto_id,
    Productos.nombre AS nombre_producto,
    Productos.precio,
    Proveedores.nombre AS nombre_proveedor
FROM Productos 
INNER JOIN Proveedores ON Productos.proveedor_id = Proveedores.id;
3. Mostrar los pedidos y las ubicaciones de los clientes con LEFT JOIN
SELECT 
    Pedidos.id AS pedido_id,
    Pedidos.fecha,
    Pedidos.total,
    Clientes.nombre AS nombre_cliente,
    Direcciones.direccion,
    Direcciones.ciudad,
    Direcciones.estado,
    Direcciones.pais
FROM Pedidos
LEFT JOIN Clientes ON Pedidos.cliente_id = Clientes.id
LEFT JOIN ClientesDireccion ON Clientes.id = ClientesDireccion.cliente_id
LEFT JOIN Direcciones ON ClientesDireccion.direccion_id = Direcciones.id;
4. Consultar los empleados que han registrado pedidos, incluyendo empleados sin pedidos (LEFT JOIN)
SELECT 
    Empleados.id AS empleado_id,
    Empleados.nombre AS nombre_empleado,
    Pedidos.id AS pedido_id,
    Pedidos.fecha,
    Pedidos.total
FROM Empleados
LEFT JOIN Pedidos ON Empleados.id = Pedidos.empleado_id;
5. Obtener el tipo de producto y los productos asociados con INNER JOIN
SELECT 
    TiposProductos.id AS tipo_id,
    TiposProductos.tipo_nombre,
    Productos.id AS producto_id,
    Productos.nombre AS nombre_producto,
    Productos.precio
FROM TiposProductos
INNER JOIN Productos ON TiposProductos.id = Productos.tipo_id;
6. Listar todos los clientes y el número de pedidos realizados con COUNT y GROUP BY
SELECT 
    Clientes.id,
    Clientes.nombre,
    COUNT(Pedidos.id) AS total_pedidos
FROM Clientes
LEFT JOIN Pedidos ON Clientes.id = Pedidos.cliente_id
GROUP BY Clientes.id, Clientes.nombre;
7. Combinar Pedidos y Empleados para mostrar qué empleados gestionaron pedidos específicos
SELECT 
    Pedidos.id AS pedido_id,
    Pedidos.fecha,
    Pedidos.total,
    Empleados.nombre AS nombre_empleado,
    Empleados.puesto
FROM Pedidos
INNER JOIN Empleados ON Pedidos.empleado_id = Empleados.id;
8. Mostrar productos que no han sido pedidos (RIGHT JOIN)
SELECT 
    Productos.id AS producto_id,
    Productos.nombre AS nombre_producto,
    DetallesPedido.id AS detalle_pedido_id
FROM DetallesPedido
RIGHT JOIN Productos ON DetallesPedido.producto_id = Productos.id
WHERE DetallesPedido.id IS NULL;
9. Mostrar el total de pedidos y ubicación de clientes usando múltiples JOIN
SELECT 
    Clientes.id AS cliente_id,
    Clientes.nombre AS nombre_cliente,
    Direcciones.ciudad,
    Direcciones.pais,
    COUNT(Pedidos.id) AS total_pedidos,
    SUM(Pedidos.total) AS suma_total
FROM Clientes
LEFT JOIN ClientesDireccion ON Clientes.id = ClientesDireccion.cliente_id
LEFT JOIN Direcciones ON ClientesDireccion.direccion_id = Direcciones.id
LEFT JOIN Pedidos ON Clientes.id = Pedidos.cliente_id
GROUP BY Clientes.id, Clientes.nombre, Direcciones.ciudad, Direcciones.pais;
10. Unir Proveedores, Productos, y TiposProductos para un listado completo de inventario
SELECT 
    Proveedores.nombre AS proveedor,
    Productos.id AS producto_id,
    Productos.nombre AS nombre_producto,
    Productos.precio,
    TiposProductos.tipo_nombre AS categoria,
    TiposProductos.descripcion
FROM Productos
INNER JOIN Proveedores ON Productos.proveedor_id = Proveedores.id
INNER JOIN TiposProductos ON Productos.tipo_id = TiposProductos.id;