-- Crear tabla de Usuarios
CREATE TABLE usuarios (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de Publicaciones
CREATE TABLE publicaciones (
    post_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(user_id)
);

-- Crear tabla de Comentarios
CREATE TABLE comentarios (
    comment_id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,  -- se usará para distribuir y para la FK
    parent_comment_id INT,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES publicaciones(post_id),
    FOREIGN KEY (user_id) REFERENCES usuarios(user_id)
);

-- Creamos una clave única en comentarios que incluya (post_id, comment_id)
ALTER TABLE comentarios
  ADD CONSTRAINT unique_post_comment UNIQUE (post_id, comment_id);

-- Definir la FK auto-referenciada incluyendo la columna de distribución.
-- Esto asegura que el comentario padre esté en el mismo shard (mismo post_id) que el comentario hijo.
ALTER TABLE comentarios
  ADD CONSTRAINT fk_parent_comment
  FOREIGN KEY (post_id, parent_comment_id)
  REFERENCES comentarios (post_id, comment_id);

ALTER TABLE comentarios
  ADD COLUMN dist_key TEXT GENERATED ALWAYS AS (
    post_id::text || '-' || comment_id::text || '-' || user_id::text
  ) STORED;

-- Crear tipos ENUM para Reacciones
CREATE TYPE reaction_enum AS ENUM ('like', 'dislike');
CREATE TYPE target_enum AS ENUM ('post', 'comment');

-- Crear tabla de Reacciones
CREATE TABLE reacciones (
    reaction_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    target_type target_enum NOT NULL,
    target_id INT NOT NULL,
    reaction_type reaction_enum NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(user_id)
    -- NOTA: target_id es polimórfico y no se puede imponer FK directamente.
);

-- Crear tabla de Recompartir
CREATE TABLE recompartir (
    share_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    original_post_id INT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES usuarios(user_id),
    FOREIGN KEY (original_post_id) REFERENCES publicaciones(post_id)
);


---------------------------------------------------------
-- Configuración de Citus:
---------------------------------------------------------

-- Usuarios se define como tabla de referencia.
SELECT create_reference_table('usuarios'::regclass);

-- Distribuir la tabla de Publicaciones por la columna post_id.
SELECT create_distributed_table('publicaciones'::regclass, 'post_id');

-- Distribuir la tabla de Comentarios por la columna post_id (para que queden colocadas con Publicaciones).
--SELECT create_distributed_table('comentarios'::regclass, 'dist_key');

-- Distribuir la tabla de Reacciones por su clave primaria reaction_id.
SELECT create_distributed_table('reacciones'::regclass, 'reaction_id');

-- Distribuir la tabla de Recompartir por su clave primaria share_id.
--SELECT create_distributed_table('recompartir'::regclass, 'share_id');

-- Verificar que la tabla 'usuarios' aparece en la vista de tablas de Citus.
SELECT * FROM citus_tables WHERE table_name = 'usuarios';
