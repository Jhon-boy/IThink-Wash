# Contexto del Negocio - Sistema de Gestión de Lavandería

## Objetivo

Desarrollar un sistema Web y Móvil para administrar una lavandería que
actualmente realiza todos sus procesos de forma manual.

## Actores

-   Administrador
-   Recepcionista
-   Cliente

## Flujo Principal

1.  Recepción de prendas por conceptos (lavado por libra, traje,
    zapatos, edredones, vestidos, etc.).
2.  Registro de orden con estado EN_PROCESO.
3.  Registro de uno o varios abonos (efectivo o transferencia),
    manteniendo total, abonado y saldo.
4.  Pago final, entrega de prendas y cambio de estado a ENTREGADO.

## Servicios adicionales

-   Planchado
-   Tinturado
-   Secado

## Administración

-   Sucursales
-   Usuarios
-   Roles
-   Conceptos
-   Servicios
-   Reportes
-   Estadísticas
-   Egresos manuales (sueldos, mantenimiento, etc.)

## Canales

-   WEB
-   MOVIL Cada usuario puede acceder desde uno o varios canales.

## Dispositivos

Cada usuario puede tener uno o varios dispositivos asociados.

## Sesiones

Cada sesión registra usuario, canal y dispositivo.

## Preguntas abiertas

1.  ¿Se manejará factura electrónica o comprobante interno?
2.  ¿Se permitirá retiro parcial?
3.  ¿Cada sucursal tendrá precios propios?
4.  ¿Se permitirán descuentos?
