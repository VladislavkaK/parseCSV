<?php

class FilmCompanies {
    private $id;
    private $companies;

    public static function fromCSV($headers, $line): FilmCompanies {
        try {
            $row = array_combine($headers, $line);

            $item = new FilmCompanies();
            $item->id = intval($row['id']);
            $item->companies = $row['production_companies'];

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
    public function getCompanies()
    {
        return $this->companies;
    }

}