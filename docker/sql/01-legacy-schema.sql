-- Pre-rework database, exactly as the old plugins created it, with a few rows
-- so the legacy import migrations have something to move.

CREATE TABLE IF NOT EXISTS `cod_accounts` (
	`name` VARCHAR(64),
	`pass` VARCHAR(64),
	PRIMARY KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `cod_honor` (
	`name` VARCHAR(64),
	`honor` INT(11) NOT NULL DEFAULT 0,
	PRIMARY KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `cod_mod` (
	`name` VARCHAR(64) NOT NULL,
	`class` VARCHAR(64) NOT NULL,
	`exp` INT UNSIGNED NOT NULL DEFAULT 0,
	`level` INT UNSIGNED NOT NULL DEFAULT 1,
	`intelligence` INT UNSIGNED NOT NULL DEFAULT 0,
	`health` INT UNSIGNED NOT NULL DEFAULT 0,
	`stamina` INT UNSIGNED NOT NULL DEFAULT 0,
	`condition` INT UNSIGNED NOT NULL DEFAULT 0,
	`strength` INT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`name`, `class`)
);

CREATE TABLE IF NOT EXISTS `cod_stats` (
	`name` VARCHAR(64) NOT NULL,
	`admin` INT NOT NULL DEFAULT 0,
	`kills` INT NOT NULL DEFAULT 0,
	`time` INT NOT NULL DEFAULT 0,
	`firstvisit` INT NOT NULL DEFAULT 0,
	`lastvisit` INT NOT NULL DEFAULT 0,
	`bestkills` INT NOT NULL DEFAULT 0,
	`bestdeaths` INT NOT NULL DEFAULT 0,
	`besths` INT NOT NULL DEFAULT 0,
	`beststats` INT NOT NULL DEFAULT 0,
	`bronze` INT NOT NULL DEFAULT 0,
	`silver` INT NOT NULL DEFAULT 0,
	`gold` INT NOT NULL DEFAULT 0,
	`medals` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `cod_clans` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(64) NOT NULL,
	`honor` INT NOT NULL DEFAULT 0,
	`kills` INT NOT NULL DEFAULT 0,
	`level` INT NOT NULL DEFAULT 1,
	`wins` INT NOT NULL DEFAULT 0,
	`health` INT NOT NULL DEFAULT 0,
	`gravity` INT NOT NULL DEFAULT 0,
	`damage` INT NOT NULL DEFAULT 0,
	`exp` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `cod_clans_members` (
	`name` VARCHAR(64) NOT NULL,
	`clan` INT NOT NULL DEFAULT 0,
	`flag` INT NOT NULL DEFAULT 0,
	`honor` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `cod_clans_applications` (
	`name` VARCHAR(64) NOT NULL,
	`clan` INT NOT NULL,
	PRIMARY KEY (`name`, `clan`)
);

CREATE TABLE IF NOT EXISTS `cod_clans_wars` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`clan` INT NOT NULL,
	`clan2` INT NOT NULL,
	`progress` INT NOT NULL DEFAULT 0,
	`progress2` INT NOT NULL DEFAULT 0,
	`duration` INT NOT NULL DEFAULT 0,
	`reward` INT NOT NULL DEFAULT 0,
	`started` INT NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`)
);

INSERT INTO `cod_accounts` (`name`, `pass`) VALUES
	('Zolnierz', 'secret1'),
	('Kapral', 'secret2'),
	('Sierzant', 'secret3');

INSERT INTO `cod_honor` (`name`, `honor`) VALUES
	('Zolnierz', 12500),
	('Kapral', 400),
	('Bezkonta', 75);

INSERT INTO `cod_mod` (`name`, `class`, `exp`, `level`, `intelligence`, `health`, `stamina`, `condition`, `strength`) VALUES
	('Zolnierz', 'Snajper', 5400, 12, 3, 4, 2, 1, 5),
	('Zolnierz', 'Komandos', 800, 4, 1, 2, 0, 0, 3),
	('Zolnierz', 'hud', 255, 128, 64, 10, 20, 0, 0),
	('Kapral', 'Snajper', 120, 2, 0, 1, 0, 0, 1),
	('Sierzant', 'Medyk', 30, 1, 0, 0, 0, 0, 0);

INSERT INTO `cod_stats` (`name`, `admin`, `kills`, `time`, `firstvisit`, `lastvisit`, `bestkills`, `bestdeaths`, `besths`, `beststats`, `bronze`, `silver`, `gold`, `medals`) VALUES
	('Zolnierz', 1, 4210, 360000, 1600000000, 1700000000, 42, 11, 19, 91, 3, 2, 1, 10),
	('Kapral', 0, 130, 7200, 1650000000, 1700000000, 9, 7, 2, 6, 1, 0, 0, 1);

INSERT INTO `cod_clans` (`id`, `name`, `honor`, `kills`, `level`, `wins`, `health`, `gravity`, `damage`, `exp`) VALUES
	(1, 'Wilki', 9000, 512, 5, 7, 20, 3, 4, 1500),
	(2, 'Sokoly', 1200, 64, 2, 1, 5, 0, 1, 200);

INSERT INTO `cod_clans_members` (`name`, `clan`, `flag`, `honor`) VALUES
	('Zolnierz', 1, 3, 5000),
	('Kapral', 1, 1, 250),
	('Sierzant', 2, 3, 100),
	('Bezkonta', 0, 0, 0);

INSERT INTO `cod_clans_applications` (`name`, `clan`) VALUES
	('Bezkonta', 2);

INSERT INTO `cod_clans_wars` (`id`, `clan`, `clan2`, `progress`, `progress2`, `duration`, `reward`, `started`) VALUES
	(1, 1, 2, 12, 4, 100, 500, 1);
