<?php

class FilmTags {
    private $id;
    private $name;

    public static function fromCSV($headers, $line): FilmTags {
        try {
            $row = array_combine($headers, $line);

            $item = new FilmTags();
            $item->id = intval($row['id']);
            $item->name = $row['keywords'];

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
    public function getName()
    {
        return $this->name;
    }

}