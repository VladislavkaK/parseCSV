<?php

class FilmCollections {
    private $id;
    private $collections;

    public static function fromCSV($headers, $line): FilmCollections {
        try {
            $row = array_combine($headers, $line);

            $item = new FilmCollections();
            $item->id = intval($row['id']);
            $item->collections = $row['belongs_to_collection'];

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
    public function getCollections()
    {
        return $this->collections;
    }

}