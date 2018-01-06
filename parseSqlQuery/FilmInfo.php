<?php

class FilmInfo
{
    private $id;
    private $name;
    private $description;
    private $link;
    private $release;
    private $rating;
    private $budget;

    public static function fromCSV($headers, $line): FilmInfo
    {
        try {
            $row = array_combine($headers, $line);

            $item = new FilmInfo();
            $item->id = intval($row['id']);
            $item->name = $row['title'];
            $item->description = $row['overview'];
            $item->link = $row['homepage'];
            $item->release = $row['release_date'] === "" ? null : $row['release_date'];
            $item->rating = floatval($row['vote_average']);
            $item->budget = intval($row['budget']);


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

    /**
     * @return mixed
     */
    public function getDescription()
    {
        return $this->description;
    }

    /**
     * @return mixed
     */
    public function getLink()
    {
        return $this->link;
    }


    /**
     * @return mixed
     */
    public function getRelease()
    {
        return $this->release;
    }

    /**
     * @return mixed
     */
    public function getRating()
    {
        return $this->rating;
    }

    /**
     * @return mixed
     */
    public function getBudget()
    {
        return $this->budget;
    }
}