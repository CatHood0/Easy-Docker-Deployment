![](/assets/app_main_screen.png)

Easy Auto Deploy nace de una necesidad crítica en equipos de desarollo: el conocimiento técnico concentrado en pocas personas crea un riesgo operacional inaceptable. Cuando el único desarollador que sabe desplegar la aplicación no está disponible u deja la empresa, proyectos enteros pueden quedar paralizados y las caídas en produción se convierten en el pan de cada día.

Esta herramienta democratiza el depliegue de aplicaciones, transformando procesos complejos de Docker y DevOps en experiencias accesibles de un solo clic (aunque también puede hacerse vía comando usando la CLI). No se trata de reemplazar a los desarrolladores, sino de empoderar a todo el equipo - desde managers hasta compañeros no tan técnicos- para mantener los sistemas funcionando sin depender de un único desarrollador que debe correr a salvar el día.

> [!IMPORTANT]
> Esta herramienta no trata de ser un reemplazo ni de desarrolladores, ni muchos menos Docker (lo contrario, existe gracias a Docker). En caso de preferirlo, siempre es recomendable usar la herramienta nativa en caso de no confíar en otras soluciones. Al final del días, este proyecto existe simplemente para facilitar el desarrollo.

FASE 1: LO MÁS BASICO DEL SISTEMA

1.1. SISTEMA DE EVENTOS Y PIPELINE

- Definir arquitectura de eventos
  - Crear DeploymentEvent base class
  - Implementar EventBus para comunicación entre servicios
  - Definir tipos de eventos: PostInitEvent, PreCloneEvent, PostDeployEvent, etc.
  - Sistema de suscripción a eventos
- Implementar Pipeline de Deployment
  - Crear DeploymentPipeline abstract class
  - Definir las 7 fases del pipeline
  - Sistema de hooks pre/post ejecución
  - Manejo de errores y rollback automático
- Sistema de configuración YAML
  - Parser de archivos YAML para configuración
  - Validación de esquemas de configuración
  - Sistema de templates de configuración
  - Merge de configuraciones (base + entorno)

1.2. INFRAESTRUCTURA CLI

- Setup de CLI Framework
  - Configurar args package como base
  - Crear Command base class con helpers
  - Sistema de logging consistente (colores, niveles)
  - Manejo de errores unificado y lo más user-friendly posible
- Comandos Core de Proyecto
  - project:create con validaciones y modo interactivo
  - project:list con table output y filtros
  - project:info con información detallada
  - project:delete con confirmación
- Sistema de Almacenamiento
  - Guardar configuraciones en YAML
  - Sistema de encriptación para datos sensibles (pensandolo)
  - Backup automático de configuraciones (opcional)
  - Migración de versiones de configuración (debería?)

FASE 2: DEPLOYMENT ROBUSTO

2.1. PIPELINE DE DEPLOYMENT MEJORADO

- Implementar las 7 fases completas
  - post-app-init (Una fase que no hace más que ejecutarse siempre que inicia la aplicación
  - pre-clone: Verificación de requisitos
  - clone: Clonación de repositorio
  - post-clone: Procesamiento de templates
  - pre-deploy: Verificaciones Docker
  - deploy: Ejecución de docker-compose
  - post-deploy: Health checks
  - monitoring: Monitoreo continuo
  
2.2. SISTEMA DE COMANDOS PERSONALIZADOS

- Motor de Comandos
  - Implementar Command base class
  - Crear comandos: CreateCommand, MoveCommand, UpdateCommand, RenameCommand
  - Sistema de variables y templates en comandos
  - Ordenamiento y dependencias entre comandos
- UI para Configuración de Comandos
  - Editor visual de pipeline
  - Drag & drop de etapas de deployment
  - Configuración de variables por comando
  - Validación en tiempo real

FASE 3: INTERFAZ GRÁFICA

3.1. GUI PRINCIPAL

- Pantalla de Dashboard
  - Lista de proyectos con estados
  - Métricas de despliegues recientes
  - Estado del sistema (Docker, recursos)
  - Notificaciones y alertas
- Gestión de Proyectos
  - Crear/editar proyectos con formulario
  - Configuración de variables de entorno
  - Visualización de pipeline de deployment
  - Historial de despliegues
- Monitor en Tiempo Real
  - Terminal de logs con seguimiento
  - Estado de contenedores en tiempo real
  - Métricas de recursos (CPU, memoria)
  - Sistema de notificaciones push

3.2. INTEGRACIÓN CLI-GUI

- Comunicación Bidireccional
  - GUI ejecuta comandos CLI internamente
  - CLI emite eventos para updates en GUI
  - Sistema de estado compartido
  - Sincronización de configuraciones

🔧 FASE 4: SISTEMA DE INTEGRACIONES

4.1. INTEGRACIONES CORE

- Sistema de Integraciones Modular
  - Integration base class
  - Sistema de registro y descubrimiento
  - Configuración UI para integraciones
  - Lifecycle management de integraciones
- Integración Nginx
  - Auto-configuración de reverse proxy
  - Generación de config SSL automática
  - Load balancing configuration
  - Health checks de endpoints
- Integración de Easy-Docker y Easy-Docker-Compose (configura tus proyectos sin interactuar con un IDE)
  - Client para Dockerfile LSP
  - Auto-completado en editores
  - Validación en tiempo real
  - Quick-fixes automáticos

🧪 FASE 5: TESTING Y CALIDAD

5.1. TESTING COMPREHENSIVO

- Unit Tests
  - Tests para todos los servicios core
  - Tests para comandos CLI
  - Tests de parsers de configuración
  - Mock de dependencias externas (Docker, Git)
- Integration Tests
  - Tests de pipeline completo
  - Tests de deployment real en contenedores aislados
  - Tests de UI con golden files
  - Performance testing
- End-to-End Tests
  - Flujos completos de usuario
  - Tests cross-platform (Windows, Linux, macOS)
  - Tests de recuperación de errores
  - Load testing

5.2. CALIDAD DE CÓDIGO

- Static Analysis
  - Configurar linter (dart analyze)
  - Configurar formatter (dart format)
  - Análisis de código estático
  - Métricas de calidad (cobertura, complejidad)
- Documentación
  - Documentación técnica (architectura)
  - Documentación de usuario (guides)
  - Documentación de API (plugins)
  - Ejemplos y tutorials

🚀 FASE 6: PREPARACIÓN PARA PRODUCCIÓN

6.1. EMPAQUETADO Y DISTRIBUCIÓN

- Build y Packaging
  - Scripts de build para todas las plataformas
  - Instaladores (deb, rpm, msi, pkg)
  - Auto-update mechanism
  - Code signing para distribuciones

6.2. MONITOREO Y LOGGING

- Observabilidad
  - Logging estructurado (JSON)
  - Health checks del sistema

MÉTRICAS DE PROGRESO

FUNCIONALIDADES PRINCIPALES

- MVP Funcional: CLI básica funcionando
- Pipeline Completo: Deployment end-to-end robusto
- GUI Operacional: Interfaz gráfica completa
- Sistema Extensible: Plugins e integraciones
- Production Ready: Testing completo y empaquetado

