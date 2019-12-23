-- last tested with mariadb Ver 15.1 Distrib 10.4.10-MariaDB

CREATE DATABASE tisch
	CHARACTER SET = 'utf8mb4'
	COLLATE = 'utf8mb4_german2_ci';

USE tisch;



CREATE TABLE projects (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(127) NOT NULL,
	creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	description VARCHAR(2047)
);



CREATE TABLE sessions (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(127) NOT NULL,
	project_id INT NOT NULL,
		FOREIGN KEY(project_id) REFERENCES projects(id),
);


CREATE TABLE session_timestamps (
	id INT AUTO_INCREMENT PRIMARY KEY,
	session_id INT NOT NULL,
		FOREIGN KEY(session_id) REFERENCES sessions(id),
	start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	end_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- known types of media files
CREATE TABLE media_types (
	id INT AUTO_INCREMENT PRIMARY KEY,
	media_type VARCHAR(63) NOT NULL UNIQUE
);



-- automatic recordings, mostly audio & video (but expandable)
CREATE TABLE recordings (
	id INT AUTO_INCREMENT PRIMARY KEY,
	session_id INT,
		FOREIGN KEY(session_id) REFERENCES sessions(id),
	media_type_id INT,
		FOREIGN KEY(media_type_id) REFERENCES media_types(id),
	creation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMPDEFAULT CURRENT_TIMESTAMP,
	file_path VARCHAR(255) NOT NULL UNIQUE
);



-- list of all contributors
-- XXX: password not yet in use!
CREATE TABLE contributors (
	id INT AUTO_INCREMENT PRIMARY KEY,
	email_address VARCHAR(254) NOT NULL UNIQUE, -- https://stackoverflow.com/a/7717596
	forename VARCHAR(127) NOT NULL,
	surname VARCHAR(127),
	password VARCHAR(63) /*, NOT NULL*/
);


CREATE TABLE project_roles (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(63) UNIQUE NOT NULL,
	description VARCHAR(127)
);


-- roles for contributors associated with different privileges
CREATE TABLE session_roles (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(63) UNIQUE NOT NULL,
	description VARCHAR(127)
);


CREATE TABLE role_per_project (
	id INT AUTO_INCREMENT PRIMARY KEY,
	project_id INT NOT NULL,
		FOREIGN KEY(project_id) REFERENCES projects(id),
	contributor_id INT NOT NULL,
		FOREIGN KEY(contributor_id) REFERENCES contributors(id),
	role_id INT NOT NULL,
		FOREIGN KEY(role_id) REFERENCES project_roles(id)
);


CREATE TABLE role_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	session_id INT NOT NULL,
		FOREIGN KEY(session_id) REFERENCES sessions(id),
	contributor_id INT NOT NULL,
		FOREIGN KEY(contributor_id) REFERENCES contributors(id),
	role_id INT NOT NULL,
		FOREIGN KEY(role_id) REFERENCES session_roles(id)
);


-- allows to track who participated in a session without them directly uploading anything
CREATE TABLE contributors_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	session_id INT NOT NULL,
		FOREIGN KEY(session_id) REFERENCES sessions(id),
	contributor_id INT NOT NULL,
		FOREIGN KEY(contributor_id) REFERENCES contributors(id)
);



-- Paths match the following pattern:
-- …/project_title-id/session_title-id/contributor_name-id/upload_id.foo
CREATE TABLE uploads (
	id INT AUTO_INCREMENT PRIMARY KEY,
	session_id INT NOT NULL,
		FOREIGN KEY(session_id) REFERENCES sessions(id),
	contributor_id INT NOT NULL,
		FOREIGN KEY(contributor_id) REFERENCES contributors(id),
	upload_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	upload_name VARCHAR(255) NOT NULL,
	display_name VARCHAR(255) NOT NULL,
	file_path VARCHAR(511) UNIQUE NOT NULL,
	media_type INT,
		FOREIGN KEY(media_type) REFERENCES media_types(id)
);


-- marks are time-bound, user-generated pieces of information
CREATE TABLE marks (
	id INT AUTO_INCREMENT PRIMARY KEY,
	session_id INT NOT NULL,
		FOREIGN KEY(session_id) REFERENCES sessions(id),
	creation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	title VARCHAR(127) NOT NULL,
	description TEXT
);


CREATE TABLE timestamps_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	mark_id INT NOT NULL UNIQUE, -- not PRIMARY to potentially allow multiple timestamps per mark
		FOREIGN KEY(mark_id) REFERENCES marks(id),
	`timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- tags for associating marks with each other
CREATE TABLE tags (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(63) UNIQUE
);


CREATE TABLE tags_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	mark_id INT NOT NULL,
		FOREIGN KEY(mark_id) REFERENCES marks(id),
	tag_id INT NOT NULL,
		FOREIGN KEY(tag_id) REFERENCES tags(id)
);


-- deliberately allows multiple positions per timestamped mark
-- coordinates range between 0 and 1, describing the position relative from the upper left corner of a frame
CREATE TABLE frame_positions_per_timestamped_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	timestamped_mark_id INT NOT NULL,
		FOREIGN KEY(timestamped_mark_id) REFERENCES timestamps_per_mark(id),
	x FLOAT UNSIGNED NOT NULL,
	y FLOAT UNSIGNED NOT NULL
);


-- files are always bound to a mark
CREATE TABLE files_per_mark (
	id INT AUTO_INCREMENT PRIMARY KEY,
	mark_id INT NOT NULL,
		FOREIGN KEY(mark_id) REFERENCES marks(id),
	file_id INT NOT NULL,
		FOREIGN KEY(file_id) REFERENCES uploads(id)
);




-- INSERTS ------------------------------------------------------------------


INSERT INTO roles
	(title, description)
VALUES
	('Admin', 'may do anything'),
	('Projektleiter', 'kann Rollen verteilen');


INSERT INTO media_types
	(media_type)
VALUES
	('video'),
	('audio'),
	('image');