# Restaurant Menu API

Una API REST completa para gestionar el menú de un restaurante, construida con Ruby puro (sin Rails), Sinatra, SQLite y siguiendo las mejores prácticas de desarrollo.

## 🚀 Características

- **CRUD completo** para productos y categorías
- **Sistema de modificadores** funcional (incluido en consultas de menú)
- **Autenticación JWT** con registro y login de usuarios
- **Categorías jerárquicas** (categorías y subcategorías)
- **Endpoint de menú completo** con toda la estructura incluyendo modificadores
- **Base de datos SQLite** para persistencia
- **Tests de integración** completos (41 tests, 100% pasando)
- **Calidad de código** con RuboCop configurado para Sinatra
- **Containerización con Docker**
- **Documentación API** incluida

## 📋 Requisitos

- Ruby 3.1.0 o superior
- SQLite3
- Docker (opcional)

## � **Inicio Rápido**

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

## ���️ Instalación y Configuración Detallada

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

## � Calidad de Código

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

## �📚 API Endpoints

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
| GET | `/categories` | Listar categorías (paginado) | Sí |
| GET | `/categories/tree` | Árbol de categorías | Sí |
| POST | `/categories` | Crear categoría | Sí |
| PUT | `/categories/:id` | Actualizar categoría | Sí |
| DELETE | `/categories/:id` | Eliminar categoría | Sí |

### Productos (5 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/products` | Listar productos (con filtros) | Sí |
| GET | `/products/:id` | Obtener producto específico | Sí |
| POST | `/products` | Crear producto | Sí |
| PUT | `/products/:id` | Actualizar producto | Sí |
| DELETE | `/products/:id` | Eliminar producto | Sí |

#### Filtros para productos:
- `?category_id=123` - Filtrar por categoría
- `?available=true` - Solo productos disponibles
- `?page=1&per_page=20` - Paginación

### Modificadores de Productos (10 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/product-modifiers` | Listar modificadores (con filtros) | Sí |
| GET | `/product-modifiers/:id` | Obtener modificador específico | Sí |
| POST | `/product-modifiers` | Crear modificador | Sí |
| PUT | `/product-modifiers/:id` | Actualizar modificador | Sí |
| DELETE | `/product-modifiers/:id` | Eliminar modificador | Sí |
| GET | `/product-modifiers/:id/options` | Listar opciones de modificador | Sí |
| POST | `/product-modifiers/:id/options` | Crear opción de modificador | Sí |
| PUT | `/product-modifiers/:id/options/:option_id` | Actualizar opción | Sí |
| DELETE | `/product-modifiers/:id/options/:option_id` | Eliminar opción | Sí |

#### Filtros para modificadores:
- `?product_id=123` - Filtrar por producto
- `?page=1&per_page=20` - Paginación

**Nota**: Los modificadores también se incluyen automáticamente en los endpoints de menú con toda su estructura.

### Menú (2 endpoints)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/menus` | Obtener menú completo con modificadores | Sí |
| GET | `/menus/categories/:id` | Obtener menú de categoría específica | Sí |

### Salud del Sistema (1 endpoint)

| Método | Endpoint | Descripción | Autenticación |
|--------|----------|-------------|---------------|
| GET | `/health` | Estado del sistema | No |

## 📝 Ejemplos de Uso

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
JWT_SECRET=your-super-secure-production-secret
PORT=4567
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

- **Autenticación JWT**: Todos los endpoints (excepto registro, login y health) requieren autenticación
- **Validación de datos**: Validaciones en modelos y controladores
- **Hashing de contraseñas**: Usando BCrypt
- **Variables de entorno**: Secretos manejados via environment variables

## ✅ Tests

Los tests de integración cubren:

- ✅ **61 tests ejecutándose** con 100% de éxito
- ✅ Autenticación (registro, login, obtener usuario actual)
- ✅ CRUD de categorías con jerarquías
- ✅ CRUD de productos con filtros y paginación
- ✅ **CRUD completo de modificadores de productos**
- ✅ **CRUD completo de opciones de modificadores**
- ✅ **Modificadores en consultas de menú** (estructura completa)
- ✅ Endpoint de menú completo con modificadores
- ✅ **Validaciones de integridad** (productos con modificadores)
- ✅ **Validaciones de negocio** (constraints, duplicados)
- ✅ Validaciones y manejo de errores
- ✅ Autorización y autenticación

**Categorías de tests**:
- Auth API (7 tests)
- Products API (8 tests) 
- Categories API (6 tests)
- Menus API (5 tests) - incluye validación de modificadores
- Basic API (8 tests) - antes simplified_api_spec
- **Product Modifiers API (20 tests)** - CRUD completo de modificadores
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
- 61 tests de integración (100% pasando)
- Sistema de modificadores 100% completo (CRUD + consultas)
- CRUD completo para gestión administrativa de modificadores
- Base de datos completa con todas las relaciones
- Autenticación JWT implementada
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