-- last tested with mariadb Ver 15.1 Distrib 10.4.10-MariaDB

CREATE OR REPLACE DATABASE tisch
	CHARACTER SET = 'utf8mb4'
	COLLATE = 'utf8mb4_german2_ci';

USE tisch;



CREATE TABLE projects (
	id INT AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(127) NOT NULL UNIQUE,
	creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	description VARCHAR(2047)
);



CREATE TABLE sessions (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_project_id INT NOT NULL,
		FOREIGN KEY(fk_project_id) REFERENCES projects(id),
	title VARCHAR(127) NOT NULL
);


CREATE TABLE segments (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	end_time DATETIME DEFAULT NULL -- if NULL → currently running
);



-- (semi) automatic recordings (audio & video)
CREATE TABLE recordings (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	recording_type ENUM('audio', 'video') NOT NULL,
	creation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	duration INT UNSIGNED, -- in seconds
	file_path VARCHAR(255) NOT NULL UNIQUE
);


CREATE TABLE transcripts (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_record_id INT NOT NULL,
		FOREIGN KEY(fk_record_id) REFERENCES recordings(id),
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


-- allows to track who participated in a session without them directly uploading anything
CREATE TABLE contributors_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),

	CONSTRAINT unique_contributor_per_session
		UNIQUE (fk_session_id, fk_contributor_id)
);


-- combine project and session roles for structural simplicity
CREATE TABLE roles (
	id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	title VARCHAR(127) UNIQUE NOT NULL,
	description VARCHAR(127)
);

CREATE TABLE role_per_project (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_project_id INT NOT NULL,
		FOREIGN KEY(fk_project_id) REFERENCES projects(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES roles(id)
);

CREATE TABLE role_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES roles(id)
);



CREATE TABLE metadata (
	id INT AUTO_INCREMENT PRIMARY KEY,
	item_type ENUM('mark', 'asset') NOT NULL,
	title VARCHAR(255) NOT NULL,
	description VARCHAR(510),
	creation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	fk_creator_id INT NOT NULL,
		FOREIGN KEY(fk_creator_id) REFERENCES contributors(id),
	tags VARCHAR(510), -- newline (\n) is the separator

	FULLTEXT (tags)
);


-- marks are time-bound, user-generated pieces of information
CREATE TABLE marks (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_metadata_id INT UNIQUE NOT NULL,
		FOREIGN KEY(fk_metadata_id) REFERENCES metadata(id),
	`timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- used to describe the type of an Asset or Upload
CREATE TABLE asset_types (
	id TINYINT AUTO_INCREMENT PRIMARY KEY,
	`type` VARCHAR(63) UNIQUE NOT NULL,
	description VARCHAR(255)
);

-- Every piece of content (→ Items), that is not a Mark, is an Asset:
-- uploads, notes, labels.
CREATE TABLE assets (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_metadata_id INT UNIQUE NOT NULL,
		FOREIGN KEY(fk_metadata_id) REFERENCES metadata(id),
	fk_asset_type_id TINYINT UNIQUE NOT NULL,
		FOREIGN KEY(fk_asset_type_id) REFERENCES asset_types(id),
	content TEXT NOT NULL
);


CREATE TABLE ratings_per_metadata (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_metadata_id INT UNIQUE NOT NULL,
		FOREIGN KEY(fk_metadata_id) REFERENCES metadata(id),
	fk_contributor_id INT NOT NULL UNIQUE,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	rating TINYINT NOT NULL,

	CONSTRAINT unique_rating_per_user_per_metadata
		UNIQUE (fk_metadata_id, fk_contributor_id)
);


-- Items can refer to multiple other items.
CREATE TABLE metadata_per_metadata (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_from_metadata_id INT UNIQUE NOT NULL,
		FOREIGN KEY(fk_from_metadata_id) REFERENCES metadata(id),
	fk_to_metadata_id INT UNIQUE NOT NULL,
		FOREIGN KEY(fk_to_metadata_id) REFERENCES metadata(id),
	title VARCHAR(127)
);


-- Keeps track of tags; they are not referred to from other tables.
CREATE TABLE tags_per_session (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	tag VARCHAR(63),

	CONSTRAINT unique_tag_per_session
		UNIQUE (fk_session_id, tag)
);


-- Only for keeping track of uploads and quickly querying/filtering them;
-- no other table refers to this table, only to the file itself.
-- Paths match the following pattern:
-- …/project_title-id/session_title-id/contributor_name-id/upload_id.foo
CREATE TABLE uploads (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	upload_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	upload_name VARCHAR(255) NOT NULL,
	file_path VARCHAR(510) UNIQUE NOT NULL,
	asset_type TINYINT,
		FOREIGN KEY(asset_type) REFERENCES asset_types(id)
);



CREATE TABLE arrangements (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_session_id INT NOT NULL,
		FOREIGN KEY(fk_session_id) REFERENCES sessions(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id),
	title VARCHAR(127) NOT NULL,
	description VARCHAR(510),
	creation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE items_per_arrangement (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arrangement_id INT NOT NULL,
		FOREIGN KEY(fk_arrangement_id) REFERENCES arrangements(id),
	fk_metadata_id INT NOT NULL,
		FOREIGN KEY(fk_metadata_id) REFERENCES metadata(id),
	fk_contributor_id INT NOT NULL,
		FOREIGN KEY(fk_contributor_id) REFERENCES contributors(id)
);

-- describes arrangement of Items
CREATE TABLE properties (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_arranged_item_id INT NOT NULL,
		FOREIGN KEY(fk_arranged_item_id) REFERENCES items_per_arrangement(id),
	x FLOAT DEFAULT NULL,
	y FLOAT DEFAULT NULL,
	z TINYINT DEFAULT NULL,
	scale FLOAT DEFAULT NULL,
	`timestamp` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	deleted BOOL NOT NULL DEFAULT false
);



CREATE TABLE permissions (
	id INT AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(127) NOT NULL,
	description VARCHAR(510)
);

CREATE TABLE permission_per_role (
	id INT AUTO_INCREMENT PRIMARY KEY,
	fk_role_id TINYINT UNSIGNED NOT NULL,
		FOREIGN KEY(fk_role_id) REFERENCES roles(id),
	fk_permission_id INT NOT NULL,
		FOREIGN KEY(fk_permission_id) REFERENCES permissions(id)
);

