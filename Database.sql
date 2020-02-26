-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.11-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win32
-- HeidiSQL Versão:              10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Copiando estrutura do banco de dados para fcrp
CREATE DATABASE IF NOT EXISTS `fcrp` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `fcrp`;

-- Copiando estrutura para tabela fcrp.characters
CREATE TABLE IF NOT EXISTS `characters` (
  `charid` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `characterName` varchar(50) NOT NULL,
  `level` int(11) DEFAULT 1,
  `xp` int(11) DEFAULT 0,
  `groups` text NOT NULL DEFAULT '{}',
  `charTable` text NOT NULL DEFAULT '{}',
  `clothes` text DEFAULT '{}',
  `weapons` text NOT NULL DEFAULT '{}',
  `is_dead` int(11) DEFAULT 0,
  PRIMARY KEY (`charid`),
  KEY `FK_characters_users` (`user_id`),
  CONSTRAINT `FK_characters_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para procedure fcrp.getData
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `getData`(
	IN `typeData` VARCHAR(10),
	IN `id` INT(8),
	IN `valor` VARCHAR(50)
)
BEGIN
	IF (valor = 'all' && typeData = 'clothes') THEN
		SELECT clothes as Value FROM characters WHERE charid = id;
	ELSEIF (valor = 'all' && typeData = 'groups') THEN
		SELECT groups as Value FROM characters WHERE charid = id;
	ELSEIF (valor = 'all' && typeData = 'charTable') THEN
		SELECT charTable as Value FROM characters WHERE charid = id;
	END IF;
	
	IF (typeData = 'groups') THEN
		SELECT json_extract(groups, CONCAT("$.", valor)) as Value FROM characters WHERE charid = id;
	ELSEIF (typeData = 'clothes') THEN
		SELECT json_extract(clothes, CONCAT("$.", valor)) as Value FROM characters WHERE charid = id;
	ELSEIF (typeData = 'charTable') THEN
		SELECT json_extract(charTable, CONCAT("$.", valor)) as Value FROM characters WHERE charid = id;
	END IF;
END//
DELIMITER ;

-- Copiando estrutura para tabela fcrp.horses
CREATE TABLE IF NOT EXISTS `horses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charid` int(11) NOT NULL,
  `model` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_horses_characters` (`charid`),
  CONSTRAINT `FK_horses_characters` FOREIGN KEY (`charid`) REFERENCES `characters` (`charid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para procedure fcrp.inventories
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `inventories`(
	IN `iid` VARCHAR(20),
	IN `charid` INT(8),
	IN `itemName` VARCHAR(100),
	IN `itemCount` INT(8),
	IN `typeInv` VARCHAR(8)
)
BEGIN
    IF (typeInv = "update") THEN
        UPDATE inventories SET items = JSON_SET(items, CONCAT("$.", itemName), itemCount) WHERE id = iid;
    ELSEIF (typeInv = "remove") THEN
        UPDATE inventories SET items = JSON_REMOVE(items, CONCAT("$.", itemName)) WHERE id = iid;
    ELSEIF (typeInv = "select") THEN
        SELECT * from inventories WHERE id = iid;
    ELSEIF (typeInv = "insert") THEN
        INSERT INTO inventories(id, charid, capacity, items) VALUES (iid, charid, 20, "{}");
    ELSEIF (typeInv = "deadPlayer") THEN
        UPDATE inventories SET items = '{}' WHERE id = iid and charid = charid;
    END IF;
END//
DELIMITER ;

-- Copiando estrutura para tabela fcrp.inventories
CREATE TABLE IF NOT EXISTS `inventories` (
  `id` varchar(100) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `items` text NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_inventoriers_characters` (`charid`),
  CONSTRAINT `FK_inventories_characters` FOREIGN KEY (`charid`) REFERENCES `characters` (`charid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela fcrp.posses
CREATE TABLE IF NOT EXISTS `posses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charid` int(11) NOT NULL,
  `members` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `charid` (`charid`),
  CONSTRAINT `FK_posses_characters` FOREIGN KEY (`charid`) REFERENCES `characters` (`charid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela fcrp.quests
CREATE TABLE IF NOT EXISTS `quests` (
  `questId` varchar(50) NOT NULL DEFAULT '0',
  `charid` int(11) NOT NULL AUTO_INCREMENT,
  `questSteps` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`questId`),
  KEY `charid` (`charid`),
  CONSTRAINT `FK_quests_characters` FOREIGN KEY (`charid`) REFERENCES `characters` (`charid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para procedure fcrp.remData
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `remData`(
	IN `typeData` VARCHAR(20),
	IN `valor` VARCHAR(50),
	IN `id` INT(8)
)
BEGIN
	IF (typeData = 'groups') THEN
		UPDATE characters SET groups = JSON_REMOVE(groups, CONCAT("$.", valor)) WHERE charid = id;
	ELSEIF (typeData = 'clothes') THEN
		UPDATE characters SET clothes = JSON_REMOVE(clothes, CONCAT("$.", valor)) WHERE charid = id;
	ELSEIF (typeData = 'charTable') THEN
		UPDATE characters SET charTable = JSON_REMOVE(charTable, CONCAT("$.", valor)) WHERE charid = id;
	END IF;
END//
DELIMITER ;

-- Copiando estrutura para procedure fcrp.setData
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `setData`(
	IN `typeData` VARCHAR(20),
	IN `valor` VARCHAR(50),
	IN `valueKey` VARCHAR(50),
	IN `id` INT(8)


)
BEGIN
	IF (typeData = 'groups') THEN
		UPDATE characters SET groups = JSON_SET(groups, CONCAT("$.", valor), valueKey) WHERE charid = id;
	ELSEIF (typeData = 'clothes') THEN
		UPDATE characters SET clothes = JSON_SET(clothes, CONCAT("$.", valor), valueKey) WHERE charid = id;
	ELSEIF (typeData = 'charTable') THEN
		UPDATE characters SET charTable = JSON_SET(charTable, CONCAT("$.", valor), valueKey) WHERE charid = id;
	END IF;
END//
DELIMITER ;

-- Copiando estrutura para tabela fcrp.users
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(21) NOT NULL,
  `name` varchar(50) NOT NULL,
  `banned` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`),
  KEY `identifier` (`identifier`),
  CONSTRAINT `FK_users_whitelist` FOREIGN KEY (`identifier`) REFERENCES `whitelist` (`identifier`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela fcrp.whitelist
CREATE TABLE IF NOT EXISTS `whitelist` (
  `id` int(11) NOT NULL,
  `identifier` varchar(21) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Exportação de dados foi desmarcado.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
