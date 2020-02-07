-- last tested with mariadb Ver 15.1 Distrib 10.4.11-MariaDB

USE tisch;

INSERT INTO projects
	(title, description)
VALUES
	('Was weiß der Tisch?', 'Ein interaktives System zur Aufzeichnung und Verarbeitung von Projektdiskussionen.'),
	('Mew2', 'Erschaffung des stärksten Pokémon der Geschichte. Als Basis dient antike DNS vom legendären Mew.'),
	('KRONOS', 'Ziel ist die Ausslöschung aller Superhelden.');

SET @project1 = (SELECT id FROM projects WHERE title = 'Was weiß der Tisch?');
SET @project2 = (SELECT id FROM projects WHERE title = 'Mew2');
SET @project3 = (SELECT id FROM projects WHERE title = 'KRONOS');



INSERT INTO contributors 
	(email_address, forename, surname)
VALUES
	('bo@jack.ch', 'Bojack', 'Pferdmann'),
	('star@mewni.com', 'Star', 'Butterfly'),
	('finn@maths.pb', 'Finn', NULL),
	('krabby-patty@bikinibottom.co', 'Spongebob', NULL);

SET @user1 = (SELECT id FROM contributor WHERE email_address = 'bo@jack.ch');
SET @user2 = (SELECT id FROM contributor WHERE email_address = 'star@mewni.com');
SET @user3 = (SELECT id FROM contributor WHERE email_address = 'krabby-patty@bikinibottom.ru');
SET @user4 = (SELECT id FROM contributor WHERE email_address = 'finn@maths.pb');



-- create session + segment
INSERT INTO sessions
	(fk_project_id, title)
VALUES
	(@project1, 'Erstgespräch'),
	(@project1, 'Brainstorming'),
	(@project2, 'Planung Dschungel-Expedition');

SET @session1_1 = (SELECT id FROM sessions WHERE title = 'Erstgespräch');
SET @session1_2 = (SELECT id FROM sessions WHERE title = 'Brainstorming');
SET @session2_1 = (SELECT id FROM sessions WHERE title = 'Planung Dschungel-Expedition');


INSERT INTO segments
	(fk_session_id, start_time, end_time)
VALUES
	(@session1_1, '2020-01-01 00:00:00', '2020-01-01 00:42:00'),
	(@session1_1, '2020-01-01 00:50:00', '2020-01-01 01:24:00'),
	(@session1_2, '2020-01-08 11:00:00', '2020-01-08 12:04:00'),
	(@session2_1, '2020-02-03 19:00:00', '2020-02-03 19:45:00'),
	(@session2_1, '2020-02-03 20:00:00', '2020-02-03 20:36:00'),
	(@session2_1, '2020-02-03 20:45:00', '2020-02-03 21:05:00');


INSERT INTO contributors_per_session 
	(fk_session_id, fk_contributor_id)
VALUES
	(@session1_1, @user1),
	(@session1_1, @user3),
	(@session1_1, @user4),
	(@session1_2, @user2),
	(@session1_2, @user4),
	(@session2_1, @user1),
	(@session2_1, @user2),
	(@session2_1, @user3),
	(@session2_1, @user4);


SET @type_url = (SELECT id FROM asset_types WHERE type = 'url');
SET @type_internal_text = (SELECT id FROM asset_types WHERE type = 'internal plain text');


INSERT INTO metadata SET
	item_type = 'mark',
	title = 'Zielfestlegung',
	fk_creator_id = @user1;

INSERT INTO marks SET
	fk_session_id = @session2_1,
	fk_metadata_id = LAST_INSERT_ID();


INSERT INTO metadata SET
	item_type = 'asset',
	title = 'Notiz: Packliste',
	fk_creator_id = @user2;

INSERT INTO assets SET
	fk_session_id = @session2_1,
	fk_metadata_id = LAST_INSERT_ID(),
	fk_asset_type_id = @type_internal_text,
	content = '– Seile\n– Machete\n–Moskitoschutz';

