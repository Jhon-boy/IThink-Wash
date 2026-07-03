# IThinkWash - Sistema de Gestión de Lavandería


## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| **Frontend** | Flutter 3.6+ (Dart) |
| **State Management** | Riverpod (flutter_riverpod 2.6.1, riverpod_annotation 2.6.1) |
| **Backend / DB** | Supabase (PostgreSQL) |
| **Autenticación** | Custom auth (SHA256 + tokens con expiración de 4h) |
| **HTTP Client** | Custom HttpClient con connectivity checks + `http` package |
| **Navegación** | BottomNavigationBar (4 tabs) + NavigationDrawer (role-filtered) |
| **Tema** | Material 3, paleta azul primaria #038BDA, fuente Poppins |

### Dependencias Principales
- `supabase_flutter` ^2.9.1
- `flutter_riverpod` ^2.6.1
- `http` ^1.5.0
- `shared_preferences` ^2.5.3
- `shimmer` ^3.0.0
- `crypto` ^3.0.6
- `device_info_plus` ^11.5.0
- `connectivity_plus` ^6.1.5
- `logger` ^2.6.1
- `lottie` ^3.3.1
- `flutter_map` ^8.2.2
- `geolocator` ^13.0.1
- `image_picker` ^1.1.2
- `share_plus` ^12.0.0
- `local_auth` ^3.0.0
- `cached_network_image` ^3.4.1

---

## Arquitectura del Proyecto

### Patrón: Clean Architecture (Feature-First)

Cada módulo funcional tiene 3 capas:
```
lib/modules/<modulo>/
  data/
    datasource/     # Llamadas a Supabase/API
    repository/     # Implementación del repositorio
  domain/
    mappers/        # Transformación entre capas
    repository/     # Interfaces abstractas
    providers/      # Riverpod providers/notifiers
  presentation/     # UI (páginas y widgets)
```

### Estructura de Directorios

```
lib/
  main.dart                    # Entry point (actualmente template default)
  app/
    config/                    # Environment configs (dev, test, prod)
    providers/                 # Providers globales (appState, navigation)
    states/                    # AppState (ChangeNotifier: darkMode, locale, loading)
  core/
    app_constants.dart         # Constantes globales (APP_NAME, IVA, etc.)
    theme_app.dart             # Sistema de tema Material 3
    entities/                  # Mapeo directo a tablas DB
    errors/                    # Exception classes (Server, Cache, Network, Database, Session)
    models/                    # Modelos compuestos/DTOs (UserModel, MenuItem, etc.)
    network/                   # HTTP Client genérico
    services/                  # Servicios core (Supabase, Auth, Storage, Connectivity)
    singleton/                 # App singleton (usuario actual, roles, sucursal)
    utils/                     # Utilidades (formatters, validators, responsive, etc.)
  modules/
    authentication/            # Login, sesión, splash
    main/                      # Home/Inicio, MainPage shell
    notification/              # Notificaciones
    sucursales/                # CRUD sucursales con mapa
    user/                      # CRUD personas, usuarios, empleados, roles
  shared/
    baseApp/                   # Base scaffold, bottom nav, drawer
    enums/                     # Enums centralizados (roles, estados, entidades, environment)
    widgets/                   # Widgets reutilizables (cards, dialogs, search, calendar, etc.)
```

---

## Base de Datos (PostgreSQL - Supabase)

### Convenciones de Nomenclatura
- **Tablas**: `T` + `MODULO` + `NOMBRE` (ej. `TSEGUSUARIO`, `TORDORDEN`, `TPERPERSONA`)
- **Módulos**: ORG (organización), PER (personas), SEG (seguridad), SER (servicios), ORD (órdenes), FIN (finanzas)
- **PKs**: `ID...` (ej. `IDUSUARIO`, `IDORDEN`, `IDPERSONA`)
- **Relaciones**: Siempre por `ID` internos, nunca por cédula/correo/usuario
- **Auditoría**: `FCREACION`, `FMODIFICACION`, `USUARIOCREACION`, `USUARIOMODIFICACION`
- **Estados**: Valores controlados (`ACTIVO`, `INACTIVO`, `EN_PROCESO`, `LISTO_PARA_ENTREGA`, `ENTREGADO`, `CANCELADO`)

### Tablas Principales

| Tabla | Módulo | Propósito |
|-------|--------|-----------|
| `TORGSUCURSAL` | ORG | Sucursales (nombre, dirección, lat/lng, contacto) |
| `TPERPERSONA` | PER | Personas/clientes (identificación, nombres, apellidos, correo, teléfono, dirección) |
| `TSEGROL` | SEG | Roles (nombre, código único, observación) |
| `TSEGCANAL` | SEG | Canales de acceso (WEB, MÓVIL) |
| `TSEGUSUARIO` | SEG | Usuarios del sistema (relacionado a sucursal y persona) |
| `TSEGROLUSUARIO` | SEG | Roles por usuario (N a N) |
| `TSEGUSUARIOCANAL` | SEG | Canales por usuario (N a N) |
| `TSEGDISPOSITIVO` | SEG | Dispositivos registrados (IMEI, marca, modelo, SO) |
| `TSEGSESION` | SEG | Sesiones activas (token UUID, fechas, dispositivo, canal) |
| `TSERCONCEPTO` | SER | Conceptos/servicios (nombre, tipoCobro, unidadMedida, precioBase, imagen) |
| `TSERSERVICIOADICIONAL` | SER | Servicios adicionales (nombre, precioBase) |
| `TORDORDEN` | ORD | Órdenes (sucursal, persona, empleado, fechas, subtotal, total, abonado, saldo, estado) |
| `TORDORDENDETALLE` | ORD | Detalle de orden (concepto, prenda, cantidad, precioUnitario, subtotal) |
| `TORDORDENDETALLEADICIONAL` | ORD | Servicios adicionales por detalle de orden |
| `TORDPAGO` | ORD | Pagos/abonos (orden, tipo, método, monto, fecha, referencia) |
| `TFINMOVIMIENTO` | FIN | Movimientos financieros (sucursal, tipo, categoría, monto, gastos/ingresos) |

---

## Sistema de Autenticación

- **Custom auth** (no usa Supabase Auth nativo)
- Login con hash SHA256 de contraseña
- Token de sesión generado con `uuid`
- Sesión expira en 4 horas (constante `TOKEN_EXPIRATION`)
- Sesión persistida en `SharedPreferences` (token, expiry, user data)
- Verificación en cada operación via `SupabaseService._ensureAuthenticated()`
- Roles manejados mediante tabla `TSEGROLUSUARIO`
- Estados de persona controlados: ACTIVO, BLOQUEADO, SUSPENDIDO, PENDIENTE, INACTIVO

### Roles Definidos (Enum `Rol`)
| Código | Nombre |
|--------|--------|
| ADM | ADMIN |
| EPG | EMPLEADO (Recepcionista) |
| EPC | EMPLEADO_COCINA |
| CLT | CLIENTE |

---

## Reglas y Convenciones de Desarrollo

### Código
- Usar **Clean Architecture** con 3 capas (data/domain/presentation) por módulo
- State management con **Riverpod** (ChangeNotifierProvider, StateProvider, StateNotifierProvider)
- Manejo de errores con **Either monad** (Left/Right) o excepciones personalizadas
- Servicio DB genérico `SupabaseService` con métodos: `select`, `selectSingle`, `insert`, `update`, `delete`, `rpc`, `count`
- No usar nunca el cliente nativo de Supabase directamente; siempre a través de `SupabaseService`
- Las entidades (`core/entities/`) deben mapear 1:1 con las tablas de la DB
- Los modelos (`core/models/`) son DTOs compuestos para la UI
- Las pantallas deben usar los widgets compartidos de `shared/widgets/`
- Toda página debe usar `PantallaBase` como scaffold (AppBar, BottomNav, Drawer, notificaciones)
- El menú (drawer y bottom nav) se filtra por roles usando `MenuItem`
- El singleton `SingletonApp` almacena el usuario actual, roles y sucursal activa
- Los environments se configuran en `app/config/` y se seleccionan via `EnvironmentConfig.initialize()`
- Usar `ResponsiveUtil` para adaptar layouts a diferentes tamaños de pantalla
- Usar `AppUtils` para utilidades comunes (hashing, validación, formateo, etc.)

### Base de Datos
- Toda tabla sigue: `T` + `MODULO` + `NOMBRE`
- Toda PK se llama: `ID...`
- Toda FK usa el ID interno de la tabla referenciada
- Toda tabla tiene campos de auditoría
- Los estados usan strings controlados (valores fijos, no booleanos sueltos)
- No ejecutar el SQL directamente (es solo referencia de contexto)

### Git
- Ramas: `release` (producción), `sprint__01` (desarrollo activo)
- Commits descriptivos en español

---

## Próximos Módulos a Implementar (Pendientes)

Basado en el contexto de negocio y la estructura actual de la DB, estos módulos NO están implementados aún:

1. **Órdenes (ORD)** - CRUD completo de órdenes con detalle, cálculo de subtotal/total, manejo de estados
2. **Pagos (ORD)** - Registro de pagos/abonos, actualización de saldos
3. **Conceptos/Servicios (SER)** - CRUD de conceptos y servicios adicionales
4. **Movimientos Financieros (FIN)** - Ingresos/egresos, cálculo de utilidad
5. **Reportes** - Dashboard con estadísticas y reportes
6. **Gestión de Roles** - Asignación masiva de roles a usuarios
7. **Sesiones / Dispositivos** - Administración de sesiones activas y dispositivos registrados
8. **Pantalla de Inicio (Dashboard)** - Resumen de órdenes activas, ingresos del día, alertas

Nota: `main.dart` aún es el template default de Flutter. Debe ser reemplazado con la configuración real de la app (inicialización de Supabase, Riverpod, temas, entorno, splash).
