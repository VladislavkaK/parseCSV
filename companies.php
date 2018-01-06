<?php

set_include_path(get_include_path() . PATH_SEPARATOR . 'parseSqlQuery' . PATH_SEPARATOR);
spl_autoload_register();

set_error_handler(function ($errno, $errstr) {
    if ($errno == E_WARNING) {
        throw new WarningException($errstr);
    } else {
        if ($errno == E_NOTICE) {
            throw new NoticeException($errstr);
        }
    }
}, E_ALL);

try {
    $db = PostgresPDO::getPDO("pgsql:host=localhost;dbname=postgres", "postgres", "postgrespass");


    $file = fopen('movies_metadata.csv', 'r');
    if ($file === false) {
        throw new RuntimeException('Can\'t open file');
    }

    if (($headers = fgetcsv($file)) === false) {
        throw new RuntimeException('Can\'t get headers row');
    }

    $line = 0;
    $count = 0;

    $db->exec("TRUNCATE companies_films");


    $stmt = $db->prepare("INSERT INTO companies_films (film_id,id, name) " .
        "SELECT :id,(json_array_elements(:name)->>'id')::INT8,json_array_elements(:name)->>'name' AS companies");

    while (($row = fgetcsv($file)) !== false) {
        $line++;
        $db->beginTransaction();

        try {
            $film = FilmCompanies::fromCSV($headers, $row);

            $id = $film->getId();
            $stmt->bindValue(':id', $id);
            $name = $film->getCompanies();
            $old_name = $name;

            $name = str_replace("''", '<^^^^>', $name);
            $name = preg_replace("/(\"+.*?)'(.*?\"+)/", '"$1<^>$2"', $name);
            $name = str_replace("\"\"", '<^^>', $name);
            $name = str_replace("\"", '<^^^>', $name);
            $name = str_replace("'", '"', $name);
            //$name = str_replace("<^^^>", '"', $name);
            $name = str_replace("<^^>", '"', $name);
            $name = str_replace("\\xa0", '', $name);

            $stmt->bindValue(':name', $name);
            $stmt->execute();


        } catch (FilmParsingException $e) {
            echo 'bad film ' . $e . PHP_EOL;
            echo $line . PHP_EOL;
            $count++;
        } catch (PDOException $e) {
            echo $id . PHP_EOL;
            echo $old_name . PHP_EOL;
            echo $name . PHP_EOL;
            echo $e->getMessage() . PHP_EOL . PHP_EOL;
            $count++;

        }
        $db->commit();

    }
    echo 'Count of bad films: ' . $count . PHP_EOL;

    $db->commit();

    fclose($file);

} catch (PDOException $e) {
    echo $e->getMessage();
}
