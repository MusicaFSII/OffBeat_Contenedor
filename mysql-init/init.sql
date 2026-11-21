CREATE DATABASE IF NOT EXISTS offbeat_blogs;
CREATE DATABASE IF NOT EXISTS offbeat_usuarios;
CREATE DATABASE IF NOT EXISTS offbeat_compras;
CREATE DATABASE IF NOT EXISTS offbeat_productos;

GRANT ALL PRIVILEGES ON offbeat_blogs.*     TO 'offbeat'@'%';
GRANT ALL PRIVILEGES ON offbeat_usuarios.*  TO 'offbeat'@'%';
GRANT ALL PRIVILEGES ON offbeat_compras.*   TO 'offbeat'@'%';
GRANT ALL PRIVILEGES ON offbeat_productos.* TO 'offbeat'@'%';
FLUSH PRIVILEGES;