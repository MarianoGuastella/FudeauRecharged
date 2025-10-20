# Restaurant Menu API

Una API REST completa para gestionar el menú de un restaurante, construida con Ruby puro (sin Rails), Sinatra, SQLite y siguiendo las mejores prácticas de desarrollo.

## 🚀 Características

- **CRUD completo** para productos y categorías
- **Sistema de modificadores** funcional (incluido en consultas de menú)
- **Autenticación JWT** (JSON Web Tokens con expiración y firma segura)
- **Categorías jerárquicas** (categorías y subcategorías)
- **Endpoint de menú completo** con toda la estructura incluyendo modificadores
- **Base de datos SQLite** para persistencia
- **Tests de integración** completos (58 tests, 100% pasando)
- **Calidad de código** con RuboCop configurado para Sinatra
- **Containerización con Docker**
- **Documentación API** completa incluida

## 📋 Requisitos

- Ruby 3.1.0 o superior
- SQLite3
- Docker (opcional)

##  **Inicio Rápido**

### **Opción 1: Con Docker (Recomendado)**
```bash
# Clonar y entrar al directorio
git clone <repository-url>
cd FudeauRecharged

# Levantar aplicación con Docker  
make docker-run
# o
docker-compose up app

# La aplicación estará en http://localhost:4567

# Probar que funciona
curl http://localhost:4567/health
```

### **Opción 2: Instalación Local**
```bash
# Clonar y entrar al directorio
git clone <repository-url>
cd FudeauRecharged

# Setup completo automático
make setup

# Iniciar servidor
make server  
# La aplicación estará en http://localhost:4567
```

## Instalación y Configuración Detallada

### Instalación Local

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd FudeauRecharged
```

2. **Instalar dependencias**
```bash
bundle install
```

3. **Configurar variables de entorno**
```bash
cp .env.example .env
# Editar .env con tus configuraciones
```

4. **Configuración completa (recomendado)**
```bash
make setup
```

Este comando ejecutará:
- Instalación de dependencias
- Migraciones de base de datos
- Datos de prueba (seeds)

### Usando Docker

**Ejecutar aplicación con Docker:**
```bash
docker-compose up app
# o
make docker-run
```

La aplicación estará disponible en `http://localhost:4567`

## 🚀 Ejecución

### Servidor de desarrollo
```bash
make server
# o
bundle exec puma -p 4567 config.ru
```

### Servidor con auto-reload
```bash
make server-dev
# o
bundle exec rerun 'bundle exec puma -p 4567 config.ru'
```

La API estará disponible en `http://localhost:4567`

## 🧪 Tests

```bash
# Ejecutar todos los tests
make test

# Ejecutar tests específicos
bundle exec rspec spec/integration/auth_spec.rb
```

## Calidad de Código

Este proyecto utiliza RuboCop para mantener la calidad y consistencia del código, configurado específicamente para proyectos Sinatra.

```bash
# Verificar estilo de código
make lint

# Corregir automáticamente problemas de estilo
make lint-fix

# Ejecutar con configuración específica
bundle exec rubocop --config .rubocop.yml
```

**Configuración de RuboCop:**
- Configurado para Ruby 3.0+
- Adaptado para proyectos Sinatra (no Rails)
- Límites ajustados para rutas de API que pueden ser más largas
- Excluye directorios de dependencias y temporales
- Incluye reglas de seguridad básicas

## 📚 API Endpoints

**Total de endpoints implementados: 26**

### Autenticación (3 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| POST | `/auth/register` | Registro de usuario | No |
| POST | `/auth/login` | Login de usuario | No |
| GET | `/auth/me` | Información del usuario actual | Sí |

### Categorías (5 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/categories` | Listar categorías (paginado) | No |
| GET | `/categories/tree` | Árbol de categorías | No |
| POST | `/categories` | Crear categoría | Sí |
| PUT | `/categories/:id` | Actualizar categoría | Sí |
| DELETE | `/categories/:id` | Eliminar categoría | Sí |

#### Paginación de categorías:
- `?page=1` - Número de página (default: 1)
- `?per_page=20` - Resultados por página (default: 20, máximo: 100)

### Productos (5 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/products` | Listar productos (con filtros y paginación) | No |
| GET | `/products/:id` | Obtener producto específico | No |
| POST | `/products` | Crear producto | Sí |
| PUT | `/products/:id` | Actualizar producto | Sí |
| DELETE | `/products/:id` | Eliminar producto | Sí |

#### Filtros y paginación para productos:
- `?category_id=123` - Filtrar por categoría
- `?available=true` - Solo productos disponibles
- `?page=1` - Número de página (default: 1)
- `?per_page=20` - Resultados por página (default: 20, máximo: 100)

### Modificadores de Productos (10 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/product-modifiers` | Listar modificadores (con filtros y paginación) | No |
| GET | `/product-modifiers/:id` | Obtener modificador específico | No |
| POST | `/product-modifiers` | Crear modificador | Sí |
| PUT | `/product-modifiers/:id` | Actualizar modificador | Sí |
| DELETE | `/product-modifiers/:id` | Eliminar modificador | Sí |
| GET | `/product-modifiers/:id/options` | Listar opciones de modificador (paginado) | No |
| POST | `/product-modifiers/:id/options` | Crear opción de modificador | Sí |
| PUT | `/product-modifiers/:id/options/:option_id` | Actualizar opción | Sí |
| DELETE | `/product-modifiers/:id/options/:option_id` | Eliminar opción | Sí |

#### Filtros y paginación para modificadores:
- `?product_id=123` - Filtrar modificadores por producto
- `?page=1` - Número de página (default: 1)
- `?per_page=20` - Resultados por página (default: 20, máximo: 100)

**Nota**: Los modificadores también se incluyen automáticamente en los endpoints de menú con toda su estructura.

### Menú (2 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/menus` | Obtener menú completo con modificadores | No |
| GET | `/menus/categories/:id` | Obtener menú de categoría específica | No |

**Nota**: Los endpoints de menú NO usan paginación ya que retornan la estructura completa del menú para ser consumida por clientes (apps móviles, web).

### Salud del Sistema (1 endpoint)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/health` | Estado del sistema | No |

## Autenticación

El sistema utiliza autenticación con **JWT (JSON Web Tokens)**:

1. **Registro o Login**: El usuario se registra (`/auth/register`) o hace login (`/auth/login`).
2. **Recibe un token JWT**: La respuesta incluye un token JWT firmado con expiración de 24 horas.
3. **Usa el token**: Para endpoints protegidos, envía el header: `Authorization: Bearer <jwt_token>`.

**Ejemplo de respuesta de login:**
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "Usuario"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJleHAiOjE3Mjk1NTUyMDAsImlhdCI6MTcyOTQ2ODgwMH0.signature"
}
```

**Características del JWT:**
- **Algoritmo**: HS256
- **Expiración**: 24 horas desde la emisión
- **Payload**: Incluye `user_id`, `email`, `exp` (expiración) e `iat` (issued at)
- **Secreto**: Configurable mediante la variable de entorno `JWT_SECRET`

**Configuración de seguridad:**
```bash
# En producción, asegúrate de configurar un secreto fuerte
export JWT_SECRET="tu-clave-secreta-super-segura-de-al-menos-32-caracteres"
```

### Paginación

Los endpoints de listado (GET de categorías, productos, modificadores y opciones) soportan paginación mediante parámetros de query:

**Parámetros:**
- `page`: Número de página (default: 1, mínimo: 1)
- `per_page`: Elementos por página (default: 20, mínimo: 1, máximo: 100)

**Ejemplo de uso:**
```bash
# Obtener la segunda página con 50 elementos
curl "http://localhost:4567/api/products?page=2&per_page=50"
```

**Respuesta con metadatos:**
```json
{
  "data": [...],
  "pagination": {
    "current_page": 2,
    "per_page": 50,
    "total_count": 150,
    "total_pages": 3
  }
}
```

**Notas importantes:**
- El endpoint `/api/menu` NO utiliza paginación, ya que devuelve la estructura completa del menú
- Si se solicita un `per_page` mayor a 100, se limitará automáticamente a 100
- Si se solicita un `page` mayor al total de páginas, se devolverá un arreglo vacío con los metadatos correctos

## Ejemplos de Uso

### 1. Registro de Usuario
```bash
curl -X POST http://localhost:4567/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "name": "Usuario de Prueba"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:4567/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

**Respuesta:**
```json
{
  "user": { "id": 1, "email": "user@example.com", "name": "Usuario" },
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJleHAiOjE3Mjk1NTUyMDAsImlhdCI6MTcyOTQ2ODgwMH0.signature"
}
```

### 3. Crear Categoría
```bash
curl -X POST http://localhost:4567/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Bebidas",
    "description": "Toda clase de bebidas",
    "sort_order": 1
  }'
```

### 4. Crear Producto
```bash
curl -X POST http://localhost:4567/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Hamburguesa Clásica",
    "description": "Hamburguesa con carne, lechuga y tomate",
    "price": 12.99,
    "category_id": 1
  }'
```

### 5. Crear Modificador
```bash
curl -X POST http://localhost:4567/product-modifiers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Toppings",
    "description": "Elige tus ingredientes adicionales",
    "product_id": 1,
    "required": false,
    "min_selections": 0,
    "max_selections": 3
  }'
```

### 6. Crear Opción de Modificador
```bash
curl -X POST http://localhost:4567/product-modifiers/1/options \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "product_id": 5,
    "additional_price": 1.50,
    "default_selected": false
  }'
```

### 7. Obtener Modificadores de un Producto
```bash
curl -X GET "http://localhost:4567/product-modifiers?product_id=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 8. Obtener Menú Completo (incluyendo modificadores)
```bash
curl -X GET http://localhost:4567/menus \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Respuesta incluye**:
- Categorías y subcategorías
- Productos con precios
- Modificadores de cada producto
- Opciones de modificadores con precios adicionales

## 🔧 Ejemplos Avanzados - Modificadores

### Crear un Modificador Completo
```bash
# 1. Crear el modificador
curl -X POST http://localhost:4567/product-modifiers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Tamaño de Pizza",
    "description": "Elige el tamaño de tu pizza",
    "product_id": 10,
    "required": true,
    "min_selections": 1,
    "max_selections": 1
  }'

# 2. Agregar opciones al modificador (ID del modificador: 5)
curl -X POST http://localhost:4567/product-modifiers/5/options \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "product_id": 15,
    "additional_price": 0.00,
    "default_selected": true
  }'

curl -X POST http://localhost:4567/product-modifiers/5/options \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "product_id": 16,
    "additional_price": 3.00,
    "default_selected": false
  }'
```

### Gestionar Modificadores Existentes
```bash
# Obtener todos los modificadores de un producto
curl -X GET "http://localhost:4567/product-modifiers?product_id=10" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Obtener detalles de un modificador específico
curl -X GET http://localhost:4567/product-modifiers/5 \
  -H "Authorization: Bearer YOUR_TOKEN"

# Actualizar un modificador
curl -X PUT http://localhost:4567/product-modifiers/5 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "max_selections": 2,
    "description": "Elige hasta 2 tamaños de pizza"
  }'

# Eliminar una opción específica
curl -X DELETE http://localhost:4567/product-modifiers/5/options/8 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Respuestas de Ejemplo

**GET /product-modifiers/5**
```json
{
  "id": 5,
  "name": "Tamaño de Pizza",
  "description": "Elige el tamaño de tu pizza",
  "required": true,
  "min_selections": 1,
  "max_selections": 1,
  "product": {
    "id": 10,
    "name": "Pizza Margherita",
    "category": "Pizza"
  },
  "options": [
    {
      "id": 15,
      "product": {
        "id": 20,
        "name": "Pequeña",
        "price": "0.00"
      },
      "additional_price": "0.00",
      "default_selected": true
    },
    {
      "id": 16,
      "product": {
        "id": 21,
        "name": "Grande",
        "price": "0.00"
      },
      "additional_price": "3.00",
      "default_selected": false
    }
  ]
}
```

## 🗄️ Estructura de la Base de Datos

### Tablas Principales

- **users**: Usuarios del sistema con autenticación
- **categories**: Categorías de productos (con soporte para jerarquías)
- **products**: Productos del menú
- **product_modifiers**: Modificadores de productos (ej: "Toppings")
- **product_modifier_options**: Opciones de modificadores (ej: "Queso", "Bacon")

### Relaciones

- Categorías pueden tener subcategorías (self-referential)
- Productos pertenecen a una categoría
- Productos pueden tener múltiples modificadores
- Modificadores pueden tener múltiples opciones
- Las opciones de modificadores son productos existentes
- **Modificadores se consultan a través de endpoints de menú Y endpoints CRUD dedicados**

## 🧩 Estructura del Proyecto

```
.
├── app/
│   ├── models/             # Modelos de datos (User, Category, Product, ProductModifier, etc.)
│   ├── helpers/            # Helpers para autenticación y manejo de errores
│   └── routes/             # Endpoints organizados por módulos
│       ├── auth_routes.rb              # Autenticación y autorización
│       ├── category_routes.rb          # CRUD de categorías
│       ├── product_routes.rb           # CRUD de productos
│       ├── menu_routes.rb              # Consultas de menú completo
│       ├── product_modifier_routes.rb  # Coordinador de modificadores
│       ├── product_modifier_crud_routes.rb    # CRUD de modificadores
│       └── product_modifier_option_routes.rb  # CRUD de opciones
├── config/                 # Configuraciones de base de datos
├── db/
│   └── migrations/         # Migraciones de base de datos
├── lib/                    # Scripts utilitarios (seeds, migrate)
├── spec/
│   └── integration/        # Tests de integración completos (61 tests)
│       ├── auth_spec.rb              # Tests de autenticación
│       ├── categories_spec.rb        # Tests de categorías
│       ├── products_spec.rb          # Tests de productos
│       ├── menus_spec.rb            # Tests de menús
│       ├── basic_api_spec.rb        # Tests básicos de API
│       └── product_modifiers_spec.rb # Tests de modificadores (CRUD)
├── app.rb                  # Aplicación principal Sinatra
├── config.ru              # Configuración Rack
├── Dockerfile              # Containerización
├── docker-compose.yml      # Orquestación
└── Makefile               # Comandos comunes
```

## 📊 Datos de Prueba

El sistema incluye datos de prueba que se pueden cargar con:

```bash
make seed
# o
bundle exec ruby lib/seeds.rb
```

Esto creará:
- Usuario administrador (usando variables de entorno ADMIN_EMAIL / ADMIN_PASSWORD)
- Categorías de ejemplo (Bebidas, Comida, Postres)
- Productos de ejemplo con precios
- **Modificadores funcionales** (Burger Toppings, Pizza Size, Extra Toppings)
- **Opciones de modificadores** vinculadas a productos existentes

**Ejemplos de modificadores incluidos**:
- Hamburguesas con toppings opcionales (queso, bacon, hongos, cebolla)
- Pizzas con tamaños requeridos (pequeña, mediana, grande)
- Pizzas con ingredientes adicionales opcionales

## 🔧 Estado de Modificadores

### ✅ Lo que está implementado:
- **Modelos completos**: ProductModifier y ProductModifierOption
- **Base de datos**: Tablas con relaciones y validaciones
- **Consultas funcionales**: Los modificadores aparecen en `/menus` y `/menus/categories/:id`
- **CRUD completo**: Endpoints dedicados para gestión administrativa
- **Gestión de opciones**: CRUD completo para opciones de modificadores
- **Seeds con datos**: Ejemplos reales de hamburguesas con toppings y pizzas con tamaños
- **Tests de integración**: Validación de estructura completa en menús y CRUD
- **Validaciones de integridad**: No se pueden eliminar productos usados como opciones
- **Validaciones de negocio**: Constraints de selección, productos únicos por modificador

### ✅ Endpoints CRUD de Modificadores:
- ✅ `GET /product-modifiers` - Listar con filtros y paginación
- ✅ `GET /product-modifiers/:id` - Obtener con opciones incluidas
- ✅ `POST /product-modifiers` - Crear con validaciones
- ✅ `PUT /product-modifiers/:id` - Actualizar con validaciones
- ✅ `DELETE /product-modifiers/:id` - Eliminar en cascada
- ✅ `GET /product-modifiers/:id/options` - Gestionar opciones
- ✅ `POST /product-modifiers/:id/options` - Crear opciones
- ✅ `PUT /product-modifiers/:id/options/:option_id` - Actualizar opciones
- ✅ `DELETE /product-modifiers/:id/options/:option_id` - Eliminar opciones

**El sistema de modificadores está 100% completo** - tanto funcional como administrativo.

## 🔧 Comandos Útiles

```bash
# Ver todos los comandos disponibles
make help

# Configuración inicial completa
make setup

# Ejecutar migraciones
make migrate

# Cargar datos de prueba
make seed

# Ejecutar tests
make test

# Iniciar servidor
make server

# Limpiar base de datos
make clean

# Docker
make docker-build
make docker-run
```

## 🐳 Docker

### Variables de Entorno para Producción

Crear un archivo `.env.production`:

```env
RACK_ENV=production
PORT=4567
JWT_SECRET=tu-clave-secreta-super-segura-de-al-menos-32-caracteres-generada-aleatoriamente
ADMIN_EMAIL=admin@restaurant.com
ADMIN_PASSWORD=secure_password_here
DATABASE_URL=sqlite://db/production.sqlite3
```

**Importante**: Genera una clave JWT_SECRET segura usando:
```bash
# Opción 1: OpenSSL
openssl rand -hex 32

# Opción 2: Ruby
ruby -e "require 'securerandom'; puts SecureRandom.hex(32)"
```

### Comandos Docker

```bash
# Construir imagen
docker build -t restaurant-api .

# Ejecutar aplicación
docker-compose up app
make docker-run

# Con variables de entorno personalizadas
cp .env.production.example .env.production
# Editar .env.production con valores seguros
docker-compose --env-file .env.production up app
```

## 🔒 Seguridad

- **Autenticación JWT**: Todos los endpoints (excepto registro, login y health) requieren autenticación mediante JWT en header `Authorization: Bearer <jwt_token>`
- **JSON Web Tokens (JWT)**: Tokens firmados con HS256, expiración de 24 horas, payload con user_id y email
- **Secreto JWT configurable**: Variable de entorno `JWT_SECRET` para firma de tokens
- **Validación de datos**: Validaciones en modelos usando Sequel validation_helpers plugin
- **Hashing de contraseñas**: Usando BCrypt con salt automático
- **Variables de entorno**: Secretos y configuración manejados via environment variables
- **Expiración automática**: Los tokens JWT expiran después de 24 horas
- **Protección CSRF**: Los JWT no son vulnerables a CSRF cuando se usan correctamente

## ✅ Tests

Los tests de integración cubren:

- ✅ **58 tests ejecutándose** con 100% de éxito
- ✅ Autenticación JWT (registro, login, tokens, expiración)
- ✅ CRUD de categorías con jerarquías
- ✅ CRUD de productos con filtros y paginación
- ✅ **CRUD completo de modificadores de productos**
- ✅ **CRUD completo de opciones de modificadores**
- ✅ **Modificadores en consultas de menú** (estructura completa)
- ✅ Endpoint de menú completo con modificadores
- ✅ **Validaciones de integridad** (productos con modificadores)
- ✅ **Validaciones de negocio** (constraints, duplicados)
- ✅ Validaciones y manejo de errores
- ✅ Autorización y autenticación JWT

**Categorías de tests**:
- Auth API (8 tests) - incluyendo validación JWT
- Products API (8 tests) 
- Categories API (6 tests)
- Menus API (5 tests) - incluye validación de modificadores
- Basic API (8 tests)
- **Product Modifiers API (16 tests)** - CRUD completo de modificadores
- **Product Modifier Options API (7 tests)** - CRUD de opciones

Ejecutar tests:
```bash
bundle exec rspec
# o 
make test
```

## 🚀 Despliegue en Producción

1. **Configurar variables de entorno de producción**
2. **Construir imagen Docker**
3. **Desplegar con Docker Compose o Kubernetes**
4. **Configurar proxy reverso (nginx) si es necesario**

## 📄 Licencia

[Incluir información de licencia]

## 🤝 Contribución

[Incluir guidelines de contribución]

---

## 📊 Estado del Proyecto

**✅ Completamente Funcional**
- 26 endpoints implementados y funcionando
- 58 tests de integración (100% pasando)
- Sistema de modificadores 100% completo (CRUD + consultas)
- CRUD completo para gestión administrativa de modificadores
- Base de datos completa con todas las relaciones
- Autenticación JWT con firma HS256 y expiración de 24 horas
- Containerización Docker lista
- Calidad de código con RuboCop (refactorizado en módulos)

**🎯 Sistema Completo**
- ✅ CRUD de usuarios y autenticación
- ✅ CRUD de categorías con jerarquías
- ✅ CRUD de productos con filtros
- ✅ CRUD de modificadores de productos
- ✅ CRUD de opciones de modificadores
- ✅ Consultas de menú con toda la estructura
- ✅ Validaciones de integridad y negocio

**Desarrollado siguiendo las mejores prácticas de Ruby y APIs REST** 🚀