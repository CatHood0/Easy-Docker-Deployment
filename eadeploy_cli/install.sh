#!/bin/bash

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Instalador automático de eadeploy${NC}"
echo "=========================================="

# Detectar sistema operativo y arquitectura
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

echo -e "🔍 Detectado: ${GREEN}$OS $ARCH${NC}"

# Mapear arquitecturas
case "$ARCH" in
    "x86_64")
        if [ "$OS" = "darwin" ]; then
            ARCH="intel"
            EXECUTABLE="eadeploy-macos-intel"
        else
            ARCH="x64" 
            EXECUTABLE="eadeploy-linux-x64"
        fi
        ;;
    "arm64"|"aarch64")
        if [ "$OS" = "darwin" ]; then
            ARCH="arm64"
            EXECUTABLE="eadeploy-macos-arm64"
        else
            ARCH="arm64"
            EXECUTABLE="eadeploy-linux-arm64"
        fi
        ;;
    *)
        echo -e "${RED}❌ Arquitectura no soportada: $ARCH${NC}"
        exit 1
        ;;
esac

# Normalizar nombre del OS para macOS
if [ "$OS" = "darwin" ]; then
    OS="macos"
fi

echo -e "📦 Usando ejecutable: ${GREEN}$EXECUTABLE${NC}"

# Verificar que existe el ejecutable
if [ ! -f "dist/$EXECUTABLE" ]; then
    echo -e "${RED}❌ No se encontró el ejecutable: dist/$EXECUTABLE${NC}"
    echo "💡 Ejecuta primero: dart run build_all.dart"
    echo "📋 Ejecutables disponibles:"
    ls -la dist/ 2>/dev/null || echo "   No existe directorio dist/"
    exit 1
fi

# Definir directorios de instalación
case "$OS" in
    "linux")
        INSTALL_DIR="$HOME/.local/bin"
        SYSTEM_DIRS=("/usr/local/bin" "/usr/bin")
        ;;
    "macos")
        INSTALL_DIR="/usr/local/bin"
        SYSTEM_DIRS=("/usr/local/bin" "/opt/homebrew/bin")
        ;;
    *)
        echo -e "${RED}❌ Sistema operativo no soportado: $OS${NC}"
        exit 1
        ;;
esac

# Intentar directorio de instalación preferido
echo -e "📁 Directorio de instalación: ${YELLOW}$INSTALL_DIR${NC}"

# Crear directorio si no existe
if [ ! -d "$INSTALL_DIR" ]; then
    echo "📂 Creando directorio: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Verificar permisos de escritura
if [ ! -w "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Sin permisos de escritura en $INSTALL_DIR${NC}"
    echo "🔒 Intentando con sudo..."
    
    # Copiar con sudo
    sudo cp "dist/$EXECUTABLE" "$INSTALL_DIR/eadeploy"
    sudo chmod +x "$INSTALL_DIR/eadeploy"
else
    # Copiar normalmente
    cp "dist/$EXECUTABLE" "$INSTALL_DIR/eadeploy"
    chmod +x "$INSTALL_DIR/eadeploy"
fi

# Verificar instalación
if [ -f "$INSTALL_DIR/eadeploy" ] && [ -x "$INSTALL_DIR/eadeploy" ]; then
    echo -e "${GREEN}✅ eadeploy instalado correctamente en: $INSTALL_DIR/eadeploy${NC}"
else
    echo -e "${RED}❌ Error en la instalación${NC}"
    exit 1
fi

# Verificar si está en PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}⚠️  El directorio $INSTALL_DIR no está en tu PATH${NC}"
    echo "📝 Añade esta línea a tu ~/.bashrc, ~/.zshrc o ~/.profile:"
    echo -e "${BLUE}   export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
    
    # Preguntar si quiere añadirlo automáticamente
    read -p "¿Quieres añadirlo automáticamente? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        SHELL_RC="$HOME/.bashrc"
        if [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        fi
        
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
        echo -e "${GREEN}✅ Añadido a $SHELL_RC${NC}"
        echo "🔃 Ejecuta: source $SHELL_RC o reinicia tu terminal"
    fi
fi

# Probar el comando
echo ""
echo -e "${GREEN}🎉 ¡Instalación completada!${NC}"
echo "🧪 Probando el comando..."
if command -v eadeploy >/dev/null 2>&1; then
    eadeploy --help
else
    echo "💡 Ejecuta: $INSTALL_DIR/eadeploy --help"
fi

echo ""
echo -e "${BLUE}📚 Uso:${NC}"
echo "   eadeploy --help      # Ver ayuda"
echo "   eadeploy --version   # Ver versión"
