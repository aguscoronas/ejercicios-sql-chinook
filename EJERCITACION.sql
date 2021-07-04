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
GROUP BY pl.playlist_id, pl.name 
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
    GROUP BY e.employee_id
    HAVING SUM(il.quantity) > 10


