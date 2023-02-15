
ALTER TABLE `users` ADD COLUMN `status` LONGTEXT NULL;

INSERT INTO `items` (`name`, `label`, `weight`) VALUES
	('bread', 'Bread', 1),
	('water', 'Water', 1),
	('beer', 'Beer', 1)
;
