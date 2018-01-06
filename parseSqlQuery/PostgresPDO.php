<?php

class PostgresPDO
{
    public static function getPDO(string $dsn, string $user, string $password): PDO
    {
        $db = new PDO(
            $dsn,
            $user,
            $password,
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );
        return $db;
    }
}