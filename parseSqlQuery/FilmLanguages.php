<?php

class FilmLanguages {
    private $id;
    private $languages;

    public static function fromCSV($headers, $line): FilmLanguages {
        try {
            $row = array_combine($headers, $line);

            $item = new FilmLanguages();
            $item->id = intval($row['id']);
            $item->languages = $row['spoken_languages'];

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
    public function getLanguages()
    {
        return $this->languages;
    }

}