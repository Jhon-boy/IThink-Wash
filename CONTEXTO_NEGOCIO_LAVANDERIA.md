# SISTEMA DE GESTIÓN DE LAVANDERÍA

> Documento de Contexto del Negocio
>
> Versión: 1.0
> Estado: En construcción
> Propietario del Producto (Product Owner): Cliente (Propietario de la lavandería)

---

# 1. PROPÓSITO DEL DOCUMENTO

Este documento tiene como objetivo explicar el funcionamiento del negocio de la lavandería de forma clara y sencilla.

# 2. DESCRIPCIÓN GENERAL DEL NEGOCIO

Actualmente la lavandería administra todas sus operaciones utilizando registros manuales.

Cada pedido se registra en papel y posteriormente se controla de manera visual.

Este proceso ocasiona diversos problemas:

- Pérdida de información.
- Dificultad para conocer cuánto dinero falta por cobrar.
- No existe un historial de pagos.
- No existen reportes.
- No existe control por sucursal.
- No existe control de usuarios.
- No existe control de estadísticas.
- Es difícil conocer la rentabilidad del negocio.

El objetivo del proyecto es digitalizar completamente el negocio mediante un sistema Web y una Aplicación Móvil.

---

# 3. OBJETIVOS DEL SISTEMA

El sistema debe permitir:

- Registrar clientes.
- Registrar órdenes de lavandería.
- Registrar los diferentes servicios ofrecidos.
- Registrar pagos y abonos.
- Controlar estados de las órdenes.
- Administrar sucursales.
- Administrar usuarios.
- Obtener reportes.
- Obtener estadísticas.
- Registrar gastos.
- Controlar el acceso desde Web y Aplicación Móvil.

---

# 4. ACTORES DEL NEGOCIO

Actualmente existen dos tipos principales de usuarios.

## Administrador

Es el propietario o encargado de la lavandería.

Puede:

- Administrar sucursales.
- Crear usuarios.
- Crear roles.
- Registrar conceptos.
- Registrar servicios adicionales.
- Registrar gastos.
- Consultar estadísticas.
- Consultar reportes.
- Visualizar todas las órdenes.

---

## Recepcionista

Es la persona que atiende al cliente.

Puede:

- Registrar clientes.
- Registrar órdenes.
- Registrar pagos.
- Registrar abonos.
- Entregar prendas.
- Consultar órdenes.

---

## Cliente

Es quien solicita el servicio de lavandería.

El cliente:

- Entrega prendas.
- Puede realizar abonos.
- Regresa posteriormente a retirar su ropa.

---

# 5. SERVICIOS QUE OFRECE LA LAVANDERÍA

El negocio trabaja mediante conceptos.

Un concepto representa un servicio principal.

Ejemplos:

- Lavado por libra.
- Lavado de traje.
- Lavado de zapatos.
- Lavado de edredones.
- Lavado de vestidos.
- Lavado de chompa de traje.

Cada concepto posee:

- Nombre
- Descripción
- Precio base
- Imagen
- Tipo de cobro
- Unidad de medida
- Estado

---

# 6. TIPOS DE COBRO

Actualmente existen dos formas de cobrar.

## POR PESO

Ejemplo:

Lavado normal

Precio:

0.40 USD por libra.

Ejemplo:

3 libras

Total:

1.20 USD

---

## PRECIO FIJO

Ejemplo

Lavado de traje

10 USD

Lavado de zapatos

2 USD

Lavado de edredón

5 USD

---

# 7. SERVICIOS ADICIONALES

Una prenda puede tener servicios adicionales.

Ejemplos:

- Planchado
- Tinturado
- Secado

Estos servicios incrementan el valor total de la orden.

Cada servicio posee:

- Nombre
- Descripción
- Precio base
- Estado

---

# 8. FLUJO DEL NEGOCIO

## PASO 1

El cliente llega a una sucursal con sus prendas.

El recepcionista recibe la ropa.

Se determina qué servicios requiere.

---

## PASO 2

Se registra la orden.

La orden contiene:

- Cliente.
- Prendas.
- Conceptos.
- Servicios adicionales.
- Observaciones.
- Fecha de recepción.
- Fecha estimada de entrega.

El sistema calcula automáticamente:

- Subtotal.
- Total.

La orden inicia con estado:

EN_PROCESO.

---

## PASO 3

El cliente puede pagar inmediatamente.

También puede dejar únicamente un abono.

El sistema debe permitir múltiples pagos.

Cada pago debe registrar:

- Fecha.
- Hora.
- Usuario.
- Método de pago.
- Canal.
- Dispositivo.

El sistema debe mantener actualizado:

- Total.
- Total abonado.
- Saldo pendiente.

---

## PASO 4

La lavandería realiza el trabajo.

Cuando las prendas estén listas:

La orden cambia al estado:

LISTO_PARA_ENTREGA.

---

## PASO 5

El cliente regresa.

Si mantiene saldo pendiente:

Debe cancelarlo.

Posteriormente:

Se entregan las prendas.

La orden cambia al estado:

ENTREGADO.

El sistema genera nuevamente el comprobante mostrando:

- Servicios.
- Pagos realizados.
- Saldo cancelado.
- Estado final.

---

# 9. GASTOS

El administrador registra gastos manualmente.

Ejemplos:

- Sueldos.
- Compra de insumos.
- Mantenimiento.
- Agua.
- Luz.
- Internet.
- Otros.

Estos gastos permiten conocer la utilidad real del negocio.

---

# 10. REPORTES

El sistema deberá generar reportes como:

- Ventas por día.
- Ventas por mes.
- Ventas por sucursal.
- Clientes frecuentes.
- Conceptos más vendidos.
- Servicios adicionales más utilizados.
- Ingresos.
- Gastos.
- Utilidad.
- Órdenes pendientes.
- Órdenes entregadas.

---

# 11. SEGURIDAD

El sistema posee usuarios.

Cada usuario pertenece a uno o varios roles.

Los usuarios pueden ingresar desde:

- WEB
- MÓVIL

El sistema registra:

- Canal utilizado.
- Dispositivo utilizado.
- Sesión.
- Fecha de ingreso.

---

# 12. ESTRUCTURA DE LA BASE DE DATOS

La base de datos está organizada por módulos.

Cada tabla pertenece únicamente a un módulo.

La nomenclatura es:

T + MODULO + NOMBRE

Ejemplos:

TPERPERSONA

TSEGUSUARIO

TSEGROL

TORDORDEN

TSERCONCEPTO

TFINMOVIMIENTO

---

# 13. MÓDULOS

## ORG

Organización

Contiene:

- Sucursales

---

## PER

Personas

Contiene:

- Personas

---

## SEG

Seguridad

Contiene:

- Usuarios
- Roles
- Roles por Usuario
- Canales
- Canales por Usuario
- Dispositivos
- Sesiones

---

## SER

Servicios

Contiene:

- Conceptos
- Servicios adicionales

---

## ORD

Órdenes

Contiene:

- Órdenes
- Detalles
- Pagos

---

## FIN

Finanzas

Contiene:

- Ingresos
- Egresos

---

# 14. CONVENCIONES DE DESARROLLO

Toda la base de datos sigue las siguientes reglas.

## Tablas

Siempre:

T + MODULO + NOMBRE

Ejemplo

TSEGUSUARIO

Nunca:

USUARIO

tblUsuario

Usuario

---

## Claves primarias

Siempre:

ID...

Ejemplo

IDUSUARIO

IDPERSONA

IDORDEN

---

## Relaciones

Las relaciones SIEMPRE utilizan los ID internos.

Nunca se relaciona mediante:

- Cédula
- Correo
- Usuario

Ejemplo correcto

IDPERSONA

Ejemplo incorrecto

IDENTIFICACION

---

## Auditoría

Las tablas mantienen:

FCREACION

FMODIFICACION

USUARIOCREACION

USUARIOMODIFICACION

---

## Estados

Siempre utilizar valores controlados.

Ejemplo

ACTIVO

INACTIVO

EN_PROCESO

LISTO_PARA_ENTREGA

ENTREGADO

CANCELADO

---

# 15. VISIÓN DEL PROYECTO

El objetivo final es que toda la operación de la lavandería pueda ser administrada desde una única plataforma.

El sistema debe reemplazar completamente el proceso manual y convertirse en la principal herramienta de trabajo del negocio.

---