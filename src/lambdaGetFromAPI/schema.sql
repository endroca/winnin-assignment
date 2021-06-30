CREATE DATABASE IF NOT EXISTS `db`;

CREATE TABLE IF NOT EXISTS `db`.`posts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `author_fullname` varchar(100) NOT NULL,
  `ups` int(11) NOT NULL,
  `num_comments` int(11) NOT NULL,
  `created` timestamp NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;