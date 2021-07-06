/*
Ejercicios de consultas sobre la base de datos Chinook
REALIZADO POR AGUSTIN CORONAS
*/

-- EJ 1 Nombres de los clientes de Brasil
SELECT first_name, last_name FROM customer WHERE country = 'Brazil';

--EJ 2 Para cada cliente, las facturas que tiene
SELECT c.first_name, c.last_name, i.invoice_date, i.invoice_id 
FROM customer c, invoice i WHERE i.customer_id = c.customer_id
ORDER BY c.first_name;

--EJ 3 Para cada track, el nombre del artista que hizo el album al que pertenece dicho track
SELECT ar.name 
FROM track t 
JOIN album al ON t.album_id = al.album_id 
JOIN artist ar ON al.artist_id = ar.artist_id;

-- EJ 5 Los nombres de las playlist que tienen más de 10 tracks de albumes de Iron Maiden
SELECT pl.name 
FROM playlist pl 
JOIN playlist_track plt on pl.playlist_id = plt.playlist_id
JOIN track t ON plt.track_id = t.track_id 
JOIN album al ON t.album_id = al.album_id 
JOIN artist ar ON al.artist_id = ar.artist_id 
WHERE ar.name = 'Iron Maiden'
GROUP BY pl.playlist_id
HAVING COUNT(*) > 10;

--EJ 6 Cantidad de Albumes que tiene cada playlist 
SELECT pl.name, COUNT(DISTINCT al.album_id) AS CANTIDAD_DE_ALBUM_POR_PLAYLIST
    FROM playlist pl
    JOIN playlist_track plt ON pl.playlist_id = plt.playlist_id
    JOIN track t ON plt.track_id = t.track_id 
    JOIN album al ON t.album_id = al.album_id
    GROUP BY pl.playlist_id
    ORDER BY pl.playlist_id;

--EJ 7 nombres de los empleados con mas de 25 años que tienen una factura con mas de 10 items
SELECT DISTINCT e.first_name, e.last_name
    FROM invoice i
    JOIN customer c ON i.customer_id = c.customer_id
    JOIN employee e ON e.employee_id = c.support_rep_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    WHERE '1996-07-2T00:00:00' > e.birth_date 
    GROUP BY e.employee_id, i.invoice_id
    HAVING SUM(il.quantity) > 10;


--EJ 8 Para cada cliente, las facturas que tiene y si no tiene ninguna factura que aparezca tambien
SELECT c.first_name, c.last_name, i.invoice_date, i.invoice_id 
FROM customer c LEFT OUTER JOIN invoice i ON i.customer_id = c.customer_id
ORDER BY c.first_name;

--EJ 9 NOMBRES DE LOS EMPLEADOS QUE SOPORTAN CLIENTES CON MAS DE 10 FACTURAS
SELECT DISTINCT e.first_name, e.last_name
FROM customer c JOIN employee e ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id, c.customer_id
HAVING COUNT(*) > 10;

--EJ 10 LISTAR EMPLEADOS JUNTO A SU JEFE
SELECT e.first_name, e.last_name, e2.first_name, e2.last_name
FROM employee e JOIN employee e2 ON e.reports_to = e2.employee_id;

--EJ 11 IDEM PERO LISTANDO A TODOS LOS EMPLEADOS
SELECT e.first_name, e.last_name, e2.first_name, e2.last_name
FROM employee e LEFT OUTER JOIN employee e2 ON e.reports_to = e2.employee_id;

--EJ 12 PROMEDIO DE TRACKS COMPRADOS POR CLIENTE 
SELECT info.first_name,info.last_name, info.customer_id, ROUND(AVG(info.cuenta))
FROM (SELECT c2.first_name, c2.last_name, c2.customer_id, i2.invoice_id, COUNT(*) AS cuenta
    FROM invoice i2
    JOIN customer c2 ON i2.customer_id = c2.customer_id
    JOIN invoice_line il ON i2.invoice_id = il.invoice_id
    GROUP BY c2.customer_id, i2.invoice_id) AS info
GROUP BY info.first_name, info.last_name, info.customer_id;

--EJ 13 para cada empleado el total de tracks de rock comprados x clientes que soporta
SELECT e.first_name, e.last_name, COUNT(*)
FROM invoice i 
    JOIN customer c ON i.customer_id = c.customer_id
    JOIN employee e ON e.employee_id = c.support_rep_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY e.employee_id;

--EJ 14 albumes que tienen al menos un track en todas las playlist
SELECT al.title
    FROM album al 
    JOIN track t ON al.album_id = t.album_id 
    JOIN playlist_track plt ON plt.track_id = al.album_id 
    JOIN playlist pl ON pl.playlist_id = plt.playlist_id 
    GROUP BY  al.album_id, pl.playlist_id
    HAVING COUNT(DISTINCT pl.playlist_id) = (SELECT COUNT(DISTINCT playlist_id) from playlist)
    ORDER BY al.album_id;

-- EJ 15 artistas con menos albums en las playlist
SELECT ar.name 
    FROM artist ar 
    LEFT OUTER JOIN album al ON al.artist_id = ar.artist_id
    JOIN track t ON al.album_id = t.album_id 
    JOIN playlist_track plt ON plt.track_id = t.track_id 
    GROUP BY ar.artist_id
    HAVING COUNT(DISTINCT al.album_id) =
        (SELECT MIN(num_de_albumes_en_playlist.conteo) 
            FROM (SELECT COUNT(DISTINCT al2.album_id) AS conteo FROM artist ar2 
                    LEFT OUTER JOIN album al2 ON al2.artist_id = ar2.artist_id
                    JOIN track t2 ON al2.album_id = t2.album_id 
                    JOIN playlist_track plt2 ON plt2.track_id = t2.track_id 
                    GROUP BY ar2.artist_id) AS num_de_albumes_en_playlist)

--EJ 16 playlist que no contengan ningun trackde los albumes de los artistas “Black Sabbath” o “Chico Buarque”
SELECT name 
    FROM playlist 
EXCEPT
SELECT DISTINCT pl.name
FROM playlist pl 
JOIN playlist_track plt ON plt.playlist_id = pl.playlist_id
JOIN track t ON t.track_id = plt.track_id 
JOIN album al ON t.album_id = al.album_id
JOIN artist ar ON al.artist_id = ar.artist_id
WHERE ar.name = 'Black Sabbath' OR ar.name = 'Chico Buarque'
GROUP BY pl.playlist_id;

--EJ 17 clientes que compraron trakcs de un unico genero
SELECT c.first_name, c.last_name
FROM invoice i 
    JOIN customer c ON i.customer_id = c.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON t.track_id = il.track_id
    JOIN genre g ON g.genre_id = t.genre_id
GROUP BY c.customer_id
HAVING COUNT(DISTINCT g.genre_id) = 1;


--EJ 18 promedio de tracks por genero en las playlist (USANDO CTE)
WITH cant_tracks(cant, genre_id, playlist_id) AS 
(
    SELECT COUNT(*) cant, genre_id, pl.playlist_id 
    FROM playlist pl JOIN playlist_track plt ON plt.playlist_id = pl.playlist_id
                     JOIN track t ON t.track_id = plt.track_id 
    GROUP BY genre_id, pl.playlist_id
)
SELECT ROUND(AVG(cant)) promedio, ct.genre_id, min(name) genero 
FROM cant_tracks ct JOIN genre g ON ct.genre_id = g.genre_id
GROUP BY ct.genre_id;

-- EJ 19 Obtener los nombres de los tracks, sus compositores, el álbum y el artista al que pertenecen de todos aquellos tracks que están en facturas con más de 12 años de emitidas.
SELECT t.name AS trackName, t.composer, al.title, ar.name AS artistName
FROM track t, album al, artist ar, invoice_line il, invoice i
WHERE '2009-05-21 18:10:00' > i.invoice_date
AND il.invoice_id = i.invoice_id 
AND t.track_id = il.track_id
AND t.album_id = al.album_id
AND al.artist_id = ar.artist_id;

--EJ 20 Una consulta que devuelva, para cada empleado, cuál es el promedio de ventas de su clientes asociados. También se quiere saber, de cada empleado asociado a esas ventas, quién es su supervisor inmediato y quién es el supervisor de su supervisor. Es decir: cada empleado debe tener una columna con su supervisor inmediato, a continuación una columna con el supervisor del supervisor, y a continuación el promedio de ventas. Puede usar la función round que redondea decimales.
SELECT e.employee_id, e.first_name, e.last_name, COALESCE(ROUND(AVG(i.total)), 0) as promedio_de_ventas, e.reports_to, e2.reports_to as boss_reports_to
FROM employee e 
LEFT OUTER JOIN customer c ON c.support_rep_id = e.employee_id 
LEFT OUTER JOIN invoice i ON i.customer_id = c.customer_id 
LEFT OUTER JOIN employee e2 ON e2.employee_id = e.reports_to
GROUP BY e.employee_id, e2.reports_to
ORDER BY e.employee_id;

-- EJ 21 Ordenar los géneros según la cantidad de facturas generadas
SELECT g.name AS nombre_Del_Genero, COUNT(DISTINCT i.invoice_id) AS cantidad_De_Facturas
FROM genre g, track t, invoice_line il, invoice i
WHERE g.genre_id = t.genre_id 
AND t.track_id = il.track_id 
AND il.invoice_id = i.invoice_id 
GROUP BY g.genre_id
ORDER BY (cantidad_De_Facturas) DESC;

-- EJ 22 Seleccione los tracks con su compositor que no aparecen en ninguna factura.
SELECT track_id, name, composer 
FROM track t 
EXCEPT 
SELECT t.track_id, t.name, t.composer 
FROM track t 
JOIN invoice_line il ON t.track_id = il.track_id
ORDER BY track_id;
--EJ 23 Listar nombres de playlists que tienen tracks que aparecen en las facturas de menor importe.
WITH fact_de_menor_importe (invoice_id) AS (
    SELECT invoice_id FROM invoice WHERE total = (SELECT MIN(total) FROM invoice)
)
SELECT DISTINCT pl.name 
FROM playlist pl 
JOIN playlist_track plt ON pl.playlist_id = plt.playlist_id
JOIN track t ON plt.track_id = t.track_id 
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON i.invoice_id = il.invoice_id
JOIN fact_de_menor_importe fdmi ON fdmi.invoice_id = i.invoice_id

