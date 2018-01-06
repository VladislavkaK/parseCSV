<?php

class FilmGenres {
    private $id;
    private $genres;

    public static function fromCSV($headers, $line): FilmGenres {
        try {
            $row = array_combine($headers, $line);

            $item = new FilmGenres();
            $item->id = intval($row['id']);
            $item->genres = $row['genres'];

            // TODO: handle errors

            return $item;
        } catch (NoticeException | WarningException $e) {
            throw new FilmParsingException();
        }
    }

    /**
     * @return mixed
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * @return mixed
     */
    public function getGenres()
    {
        return $this->genres;
    }

}