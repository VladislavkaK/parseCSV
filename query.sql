CREATE USER dev WITH PASSWORD 'dev';

DROP TABLE IF EXISTS films;

CREATE TABLE films (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT NOT NULL,
  link        TEXT,
  release     DATE,
  rating      NUMERIC(3, 1) CHECK (rating >= 0 AND rating <= 10),
  budget      INT8 NOT NULL
);

GRANT ALL ON films TO PUBLIC;

DROP TABLE IF EXISTS keywords_films;

CREATE TABLE keywords_films (
  film_id INT8,
  id      INT8,
  name    TEXT

);

CREATE INDEX ON keywords_films (film_id);

ANALYSE keywords_films;

GRANT ALL ON keywords_films TO PUBLIC;

DROP TABLE IF EXISTS genres_films;

CREATE TABLE genres_films (
  film_id INT8,
  id      INT8,
  name    TEXT

);

CREATE INDEX ON genres_films (film_id);

ANALYSE genres_films;

GRANT ALL ON genres_films TO PUBLIC;

DROP TABLE IF EXISTS companies_films;

CREATE TABLE companies_films (
  film_id INT8,
  id      INT8,
  name    TEXT

);
CREATE INDEX ON companies_films (film_id);

ANALYSE companies_films;

GRANT ALL ON companies_films TO PUBLIC;



DROP TABLE IF EXISTS collections_films;

CREATE TABLE collections_films (
  film_id INT8,
  id      INT8,
  name    TEXT

);




CREATE INDEX ON collections_films (film_id);

ANALYSE collections_films;

GRANT ALL ON collections_films TO PUBLIC;


CREATE TABLE languages (
  film_id INT8,
  name    TEXT

);
GRANT ALL ON languages TO PUBLIC;




CREATE TABLE companies AS
  SELECT DISTINCT
    c.id, c.name
  FROM companies_films c
;

ALTER TABLE companies_films
  DROP COLUMN name
;

CREATE TABLE collections AS
  SELECT DISTINCT
    c.id
    , c.name
  FROM collections_films c
;

ALTER TABLE collections_films
  DROP COLUMN name
;

CREATE TABLE genres AS
  SELECT DISTINCT
    c.id
    , c.name
  FROM genres_films c
;

ALTER TABLE genres_films
  DROP COLUMN name
;

CREATE TABLE keywords AS
  SELECT DISTINCT
    c.id
    , c.name
  FROM keywords_films c
;

ALTER TABLE keywords_films
  DROP COLUMN name
;

ALTER TABLE collections_films ADD PRIMARY KEY (id,film_id);
ALTER TABLE companies ADD PRIMARY KEY (id);
ALTER TABLE genres ADD PRIMARY KEY (id);
ALTER TABLE keywords ADD PRIMARY KEY (id);

DELETE FROM collections_films  WHERE film_id NOT IN (SELECT id FROM films);
DELETE FROM companies_films  WHERE film_id NOT IN (SELECT id FROM films);
DELETE FROM genres_films  WHERE film_id NOT IN (SELECT id FROM films);
DELETE FROM keywords_films  WHERE film_id NOT IN (SELECT id FROM films);

ALTER TABLE collections_films ADD FOREIGN KEY (film_id) REFERENCES films;
ALTER TABLE companies_films ADD FOREIGN KEY (film_id) REFERENCES films;
ALTER TABLE genres_films ADD FOREIGN KEY (film_id) REFERENCES films;
ALTER TABLE keywords_films ADD FOREIGN KEY (film_id) REFERENCES films;


DELETE FROM companies_films  WHERE    id NOT IN (SELECT id FROM companies);
DELETE FROM genres_films  WHERE       id NOT IN (SELECT id FROM genres);
DELETE FROM keywords_films  WHERE     id NOT IN (SELECT id FROM keywords);


ALTER TABLE companies_films ADD FOREIGN KEY   (id) REFERENCES companies ;
ALTER TABLE genres_films ADD FOREIGN KEY      (id) REFERENCES genres ;
ALTER TABLE keywords_films ADD FOREIGN KEY    (id) REFERENCES keywords ;





--�������� ����������
DELETE FROM collections_films
WHERE ctid NOT IN
      (SELECT max(ctid)
       FROM collections_films
       GROUP BY (id, film_id));
DELETE FROM companies_films
WHERE ctid NOT IN
      (SELECT max(ctid)
       FROM companies_films
       GROUP BY (id, film_id));
DELETE FROM genres_films
WHERE ctid NOT IN
      (SELECT max(ctid)
       FROM genres_films
       GROUP BY (id, film_id));
DELETE FROM keywords_films
WHERE ctid NOT IN
      (SELECT max(ctid)
       FROM keywords_films
       GROUP BY (id, film_id));

--1.  ���������� ������� � ����������� ���
SELECT date_part('YEAR', f.release), count(*)
FROM films f
WHERE date_part('YEAR', f.release) = 2020
GROUP BY date_part('YEAR', f.release)
ORDER BY 1;

--2. ���������� � ������
SELECT *
FROM films f
  LEFT JOIN LATERAL (
            SELECT array_agg(cl.name)
            FROM collections_films cf
              JOIN collections cl ON cf.id = cl.id
            WHERE f.id = cf.film_id
            ) clf ON TRUE
  LEFT JOIN LATERAL (
            SELECT array_agg(cl.name)
            FROM companies_films cf
              JOIN companies cl ON cf.id = cl.id
            WHERE f.id = cf.film_id
            ) com ON TRUE
  LEFT JOIN LATERAL (
            SELECT array_agg(cl.name)
            FROM genres_films cf
              JOIN genres cl ON cf.id = cl.id
            WHERE f.id = cf.film_id
            ) gen ON TRUE
  LEFT JOIN LATERAL (
            SELECT array_agg(cl.name)
            FROM keywords_films cf
              JOIN keywords cl ON cf.id = cl.id
            WHERE f.id = cf.film_id
            ) key ON TRUE
WHERE id = 2428;

--3 ����� �������� ����������� � ������������ ����������� ���-100 ����� ������� �������
WITH x AS (
    SELECT cf.id
    FROM films f
      JOIN companies_films cf ON f.id = cf.film_id
    ORDER BY f.budget DESC
    LIMIT 100)
SELECT comp.name
FROM x
  LEFT JOIN LATERAL (SELECT name
                     FROM companies c
                     WHERE c.id = x.id) comp ON TRUE
GROUP BY comp.name
ORDER BY count(*) DESC
LIMIT 1;

--4 ����� �������� ����������� �� ��� ������� � ���������� ��������� ������� �������
WITH x AS (
    SELECT sum(f.budget) s, cf.id
    FROM films f
      JOIN companies_films cf ON cf.film_id = f.id
    GROUP BY cf.id
    ORDER BY s DESC
    LIMIT 1)
SELECT c.name
FROM x
  JOIN companies c ON c.id = x.id;

--5 ����� ����� ������������� ���� ������
WITH x AS (
    SELECT LEAST(gf1.id, gf2.id) l, GREATEST(gf1.id, gf2.id) g
    FROM genres_films gf1
      JOIN genres_films gf2 ON gf1.film_id = gf2.film_id
    WHERE gf1.id != gf2.id
    GROUP BY 1, 2
    ORDER BY count(*) DESC
    LIMIT 1)
SELECT gl.name, gg.name
FROM x
  JOIN genres gl ON gl.id = x.l
  JOIN genres gg ON gg.id = x.g;

--6 ���-3 ���� (��������������� �� ������������ � ������� � ������� ����������� ���) ��� ������� ���������� �����
SELECT (SELECT name
        FROM keywords k
        WHERE id = kf.id)
FROM genres_films gf
  JOIN keywords_films kf ON gf.film_id = kf.film_id
WHERE gf.id IN (SELECT id
                FROM genres g
                WHERE g.name = 'Action')
GROUP BY kf.film_id, kf.id
ORDER BY count(*) DESC

LIMIT 3;

--7 �� ������� ������, � �������, ���������� ���-100 ������� �� ��������
WITH x AS (
    SELECT id
    FROM films f
    ORDER BY f.rating DESC
    LIMIT 100)
SELECT id, array_agg(l.name), COALESCE(array_length(array_agg(l.name), 1) - 1, 0)
FROM x
  LEFT JOIN languages l ON x.id = l.film_id
GROUP BY id;

--8 ����� ������������ � ����������� ������� � ������� ����������� �������� �� ������ ���
SELECT date_part('YEAR', f.release)
  , MAX(f.rating)
  , MIN(f.rating)
FROM films f
  JOIN companies_films cf ON f.id = cf.film_id
  JOIN companies c ON c.id = cf.id
WHERE c.name = 'Warner Bros.'
GROUP BY date_part('YEAR', f.release);

--9 ������ ���������� ������� ����� ��� ���������� ������ (�� id) � ����������� ������
SELECT f2.name, f2.release
FROM collections_films cf1
  JOIN films f1 ON cf1.film_id = f1.id
  JOIN collections_films cf2 ON cf1.id = cf2.id
  JOIN films f2 ON cf2.film_id = f2.id
WHERE f2.release < f1.release
      AND cf1.film_id = 1893
ORDER BY f2.release
;

WITH RECURSIVE x AS (
  SELECT *, id AS self
  FROM numbered
  WHERE id = 1893
  UNION ALL
  SELECT n.*, x.self
  FROM x
    JOIN numbered n ON x.cid = n.cid AND x.rn = n.rn + 1
),
    numbered AS (
      SELECT f1.id, f1.name, f1.release, cf1.id AS cid, ROW_NUMBER()
      OVER (
        PARTITION BY cf1.id
        ORDER BY f1.release )                   AS rn
      FROM collections_films cf1
        JOIN films f1 ON cf1.film_id = f1.id)
SELECT x.name,x.release
FROM x
WHERE x.id != self
ORDER BY x.release;
;

--10 ����� ������� ������ �� ����� ��� ���������� ����
SELECT DISTINCT ON (1) date_part('YEAR', f.release), first_value(f.name)
OVER (
  PARTITION BY date_part('YEAR', f.release)
  ORDER BY f.budget DESC )
FROM films f
  JOIN keywords_films kf ON kf.film_id = f.id
  JOIN keywords k ON k.id = kf.id
WHERE k.name = 'female nudity';