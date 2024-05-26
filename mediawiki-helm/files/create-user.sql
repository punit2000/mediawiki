CREATE DATABASE {{ .Values.mariadb.dbUsers.database }};
CREATE USER '{{ .Values.mariadb.dbUsers.username }}'@'%' IDENTIFIED BY '{{ .Values.mariadb.dbUsers.password }}';
GRANT ALL PRIVILEGES ON {{ .Values.mariadb.dbUsers.database }}.* TO '{{ .Values.mariadb.dbUsers.username }}'@'%' WITH GRANT OPTION;