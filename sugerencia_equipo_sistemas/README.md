# Sugerencia al equipo de Sistemas

- **Trabajo revisado:** `avance1_olist_4.R`, del repositorio `Juanmartinf22/Sistemas` (datos de Olist).
- **Pregunta del equipo:** ¿cuánto empeora la calificación cuando el pedido llega tarde?

## Lo que está bien resuelto

Comparan solo el día y no la hora, porque la fecha prometida viene sin hora, y trabajan con una fila por orden. Las dos decisiones están explicadas en el script y evitan errores de conteo.

## Sugerencia: separar las reseñas respondidas antes de recibir el pedido

El script compara el puntaje promedio de los pedidos a tiempo (4,29) con el de los que llegaron tarde (2,27).

Mirando la fecha en que se respondió cada reseña (`review_answer_timestamp`), el 70% de los pedidos tardíos fue calificado **antes** de que el paquete llegara. En los pedidos a tiempo eso casi no pasa (0,3%).

| Pedidos que llegaron tarde | Órdenes | Puntaje promedio |
|---|---|---|
| Reseña respondida antes de recibir el pedido | 4.473 | 1,65 |
| Reseña respondida después de recibirlo | 1.908 | 3,72 |
| Total | 6.381 | 2,27 |

El 2,27 mezcla dos situaciones distintas: el cliente que califica mientras sigue esperando y el que califica con el pedido ya en la mano. Les sugiero mostrarlas por separado, porque la respuesta a la pregunta cambia mucho según cuál se mire.

### Cómo hacerlo

En el paso 2, sumar la fecha de respuesta al armar `reviews_unicas`:

```r
reviews_unicas <- reviews %>%
  distinct(order_id, .keep_all = TRUE) %>%
  select(order_id, review_score, review_answer_timestamp)
```

Y después del paso 3:

```r
df %>%
  mutate(resena_antes_de_recibir = review_answer_timestamp < order_delivered_customer_date) %>%
  group_by(llego_tarde, resena_antes_de_recibir) %>%
  summarise(ordenes = n(),
            puntaje_promedio = round(mean(review_score), 2),
            .groups = "drop")
```

## Un detalle más

El README del repositorio todavía no explica el trabajo, y los tres gráficos que genera el script no están subidos. Con la pregunta, los datos usados, cómo correr el script y los gráficos a la vista, el avance se entiende sin abrir el código.

---

Uso de IA: trabajé con un asistente (Claude) para revisar el script y redactar la sugerencia.
