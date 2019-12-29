-- last tested with mariadb Ver 15.1 Distrib 10.4.10-MariaDB

INSERT INTO project_roles
	(title, description)
VALUES
	('Project Manager', 'kann Rollen verteilen');


INSERT INTO session_roles
	(title, description)
VALUES
	('Chairperson', 'initiiert und leitet Sitzung, kann Rollen verteilen'),
	('Content Manager', 'bringt Beiträge in einheitliche Form');


INSERT INTO media_types
	(media_type)
VALUES
	('video'),
	('audio'),
	('image'),
	('text'),
	('unknown');

