


/* ________________________________________________________________________________
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
The amount of memory required by MySQL for reads and writes depends on the tables involved in the operations.
It is a best practice to have at least enough RAM to the hold the indexes of actively used tables.
To find the ten largest tables and indexes in a database, use the following query: */

SELECT CONCAT(table_schema, '.', table_name),
       CONCAT(ROUND(table_rows / 1000000, 2), 'M')                                    rows,
       CONCAT(ROUND(data_length / ( 1024 * 1024 * 1024 ), 2), 'G')                    DATA,
       CONCAT(ROUND(index_length / ( 1024 * 1024 * 1024 ), 2), 'G')                   idx,
       CONCAT(ROUND(( data_length + index_length ) / ( 1024 * 1024 * 1024 ), 2), 'G') total_size,
       ROUND(index_length / data_length, 2)                                           idxfrac
FROM   information_schema.TABLES
ORDER  BY data_length + index_length DESC
LIMIT  10;

