-- inserts default data that helps quickly using the database after init
-- last tested with mariadb Ver 15.1 Distrib 10.4.11-MariaDB

USE tisch;


INSERT INTO roles
	(title, description)
VALUES
	-- session roles
	('Moderation', 'startet, stoppt und verwaltet eine Session');


INSERT INTO asset_types
	(`type`, description)
VALUES
	('video', 'video file'),
	('audio', 'audio file'),
	('url', 'web link'),
	('document', 'arbitrary file'),
	('internal plain text', 'plain text, contained in the database'),
	('label', 'a label inside an arrangement');

