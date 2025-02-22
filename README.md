# sharding-

para ejecutarlo solo escribe python setup_and_run.py y el dejara todo listo

```python
python setup_and_run.py
```

# Gestión de Nodos en un Clúster Citus

Citus es una extensión de PostgreSQL que permite la distribución de datos y consultas en múltiples nodos, facilitando el escalado horizontal. Para gestionar los nodos en un clúster de Citus, es esencial saber cómo registrar nuevos nodos y validar los existentes. A continuación, se detallan los pasos para realizar estas tareas.

## Registro de Nodos

Para añadir un nuevo nodo trabajador al clúster, se utiliza la función `master_add_node`. Esta función registra el nodo en la tabla de metadatos `pg_dist_node` y, además, copia las tablas de referencia al nuevo nodo.

**Sintaxis:**

```sql
SELECT * FROM master_add_node('nombre_del_nodo', puerto);
```

## Ejemplo
```sql
SELECT * FROM master_add_node('citus_worker1', 5432);
SELECT * FROM master_add_node('citus_worker2', 5432);

```

## para validar nodos activos 
```sql
SELECT * FROM master_get_active_worker_nodes();

```
## Ejemplo practico si lo desean 

