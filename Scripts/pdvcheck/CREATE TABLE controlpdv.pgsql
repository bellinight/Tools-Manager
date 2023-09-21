CREATE TABLE controlpdv (
  id SERIAL,  
  addpdv INT,  
  registro DATE,
  totalPDVS INT
);
 INSERT INTO controlpdv ( registro, totalpdvs)
    SELECT  CURRENT_DATE , count(idecf) FROM pdv


DROP TABLE controlpdv


SELECT * FROM controlpdv
order by registro asc


SELECT totalpdvs FROM controlpdv
     WHERE totalpdvs > (SELECT MAX(controlpdv.id), totalpdvs FROM controlpdv
     GROUP by controlpdv.totalpdvs)