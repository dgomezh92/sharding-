#!/usr/bin/env python3
import os
import stat
import subprocess
import sys

def create_directories(directories):
    for directory in directories:
        if not os.path.exists(directory):
            os.makedirs(directory)
            print(f"Directorio creado: {directory}")
        else:
            print(f"El directorio ya existe: {directory}")

def create_pgpass_file(pgpass_file, content):
    try:
        fd = os.open(pgpass_file, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o666)
        # Se crea con 0o666 en Windows; se corregirá en el contenedor.
    except Exception as e:
        print(f"Error al abrir {pgpass_file}: {e}")
        sys.exit(1)
    with os.fdopen(fd, 'w') as f:
        f.write(content)
    print(f"Archivo {pgpass_file} creado con el contenido necesario.")

def run_docker_compose():
    try:
        print("Ejecutando 'docker-compose up -d'...")
        subprocess.run(["docker-compose", "up", "-d"], check=True)
        print("Contenedores levantados correctamente.")
    except subprocess.CalledProcessError as e:
        print("Error al ejecutar docker-compose:", e)
        sys.exit(1)

if __name__ == '__main__':
    # Crear directorios para persistencia de datos
    directories = [
        "./citus_coordinator_data",
        "./citus_worker1_data",
        "./citus_worker2_data"
    ]
    create_directories(directories)
    
    # Crear el archivo .pgpass con una entrada genérica para cualquier host en el puerto 5432
    pgpass_file = "./.pgpass"
    pgpass_content = "*:5432:*:postgres:commonpassword\n"
    create_pgpass_file(pgpass_file, pgpass_content)
    
    # Ejecutar docker-compose (se asume que docker-compose.yml ya existe en el mismo directorio)
    run_docker_compose()
