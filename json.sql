SELECT array_agg(x.x) FROM

(WITH j(j)
AS (VALUES
        ('[{''id'': 28, ''name'': ''Action''}, {''id'': 80, ''name'': ''Crime''}, {''id'': 18, ''name'': ''Drama''}, {''id'': 53, ''name'': ''Thriller''}]')
        ,('[]')
)
SELECT json_array_elements(replace(j.j ,chr(39),chr(34))::JSON)->>'name' x
FROM j) x
;

UPDATE films SET tags= ARRAY[]::TEXT[]