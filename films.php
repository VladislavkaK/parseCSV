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
    $stmt = $db->prepare(
        'INSERT INTO films (id, name, description, link, release, rating,budget) ' .
        'VALUES (:id, :name, :description, :link, :release, :rating,:budget) ON CONFLICT DO NOTHING;'
    );

    $db->beginTransaction();
    while (($row = fgetcsv($file)) !== false) {
        $line++;
        try {
            $film = FilmInfo::fromCSV($headers, $row);

            $stmt->bindValue(':id', $film->getId());
            $stmt->bindValue(':name', $film->getName());
            $stmt->bindValue(':description', $film->getDescription());
            $stmt->bindValue(':link', $film->getLink());
            $stmt->bindValue(':release', $film->getRelease());
            $stmt->bindValue(':rating', $film->getRating());
            $stmt->bindValue(':budget', $film->getBudget());

            $stmt->execute();

        } catch (FilmParsingException $e) {
            echo 'bad film' . PHP_EOL;
            echo $line . PHP_EOL;
            $count++;
        } catch (PDOException $e) {
            echo $e->getMessage();
            var_dump($film);
            exit(1);
        }
    }
    echo 'Count of bad films: ' . $count . PHP_EOL;

    $db->commit();

    fclose($file);

} catch (PDOException $e) {
    echo $e->getMessage();
}


