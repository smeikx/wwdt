CREATE DATABASE IF NOT EXISTS tisch
	CHARACTER SET = 'utf8mb4'
	COLLATE = 'utf8mb4_german2_ci';


CREATE TABLE IF NOT EXISTS projects (
	project_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL, 
	title VARCHAR(255) NOT NULL,
	description VARCHAR(2048) NULL,
);


CREATE TABLE IF NOT EXISTS sessions (
	session_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL, 
	project_id INT NOT NULL,
		FOREIGN KEY(project_id) REFERENCES projects(project_id),
	start DATETIME NOT NULL,
	end DATETIME NOT NULL
);


CREATE TABLE IF NOT EXISTS media_types (
	media_type_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL, 
	media_type VARCHAR NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS recordings (
	record_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL, 
	session_id INT,
		FOREIGN KEY(session_id) REFERENCES sessions(session_id),
	media_type_id INT,
		FOREIGN KEY(media_type_id) REFERENCES media_types(media_type_id),
	file_path VARCHAR UNIQUE
);


