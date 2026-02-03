#!/bin/bash
# docker-manager.sh - Gestor básico de contenedores Docker

set -e

# Colores básicos
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Mostrar ayuda
show_help() {
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos disponibles:"
    echo "  list        Listar contenedores (activos o todos)"
    echo "  images      Listar imágenes"
    echo "  volumes     Listar volúmenes"
    echo "  clean       Limpiar contenedores parados"
    echo "  clean-all   Limpiar TODO (contenedores, imágenes, volúmenes no usados)"
    echo "  stats       Mostrar estadísticas"
    echo "  prune       Eliminar recursos no usados"
    echo "  restart     Reiniciar contenedor"
    echo "  stop-all    Detener todos los contenedores"
    echo "  ports       Ver puertos mapeados"
}

# Verificar que Docker esté disponible
check_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Error: Docker no está instalado o no está en PATH"
        exit 1
    fi
}

# Listar contenedores
list_containers() {
    echo -e "${GREEN}=== Contenedores Activos ===${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    if [ "${1:-}" = "--all" ]; then
        echo ""
        echo -e "${YELLOW}=== Contenedores Parados ===${NC}"
        docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}"
    fi
}

# Listar imágenes
list_images() {
    echo -e "${GREEN}=== Imágenes ===${NC}"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
}

# Listar volúmenes
list_volumes() {
    echo -e "${GREEN}=== Volúmenes ===${NC}"
    docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"
}

# Limpiar contenedores parados
clean_containers() {
    echo "Limpiando contenedores parados..."
    docker ps -aq --filter "status=exited" | xargs -r docker rm
    echo -e "${GREEN}✓ Listo${NC}"
}

# Limpiar TODO
clean_all() {
    echo -e "${YELLOW}Esta acción eliminará:${NC}"
    echo "  • Contenedores parados"
    echo "  • Imágenes sin uso"
    echo "  • Volúmenes no referenciados"
    echo "  • Redes no usadas"
    echo ""
    read -p "¿Continuar? (s/N): " confirm
    
    if [[ $confirm =~ ^[Ss]$ ]]; then
        echo "Limpiando..."
        
        # Contenedores parados
        docker ps -aq --filter "status=exited" | xargs -r docker rm
        
        # Imágenes colgantes
        docker images -q -f "dangling=true" | xargs -r docker rmi
        
        # Volúmenes no usados
        docker volume prune -f
        
        echo -e "${GREEN}✓ Limpieza completa${NC}"
    else
        echo "Cancelado"
    fi
}

# Mostrar estadísticas
show_stats() {
    echo -e "${GREEN}=== Estadísticas Docker ===${NC}"
    echo ""
    
    # Contenedores
    echo "Contenedores:"
    echo "  • Activos: $(docker ps -q | wc -l)"
    echo "  • Total:   $(docker ps -aq | wc -l)"
    
    # Imágenes
    echo -e "\nImágenes:"
    docker images -q | wc -l | xargs echo "  • Total:"
    
    # Volúmenes
    echo -e "\nVolúmenes:"
    docker volume ls -q | wc -l | xargs echo "  • Total:"
    
    # Uso de disco
    echo -e "\nUso de disco:"
    docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}" | sed 's/^/  /'
}

# Eliminar recursos no usados
prune_system() {
    echo "Eliminando recursos no usados..."
    docker system prune -af
    echo -e "${GREEN}✓ Listo${NC}"
}

# Reiniciar contenedor
restart_container() {
    if [ $# -lt 1 ]; then
        echo "Uso: $0 restart <nombre_contenedor>"
        exit 1
    fi
    
    container="$1"
    
    if docker ps -a --format "{{.Names}}" | grep -q "^${container}$"; then
        echo "Reiniciando $container..."
        docker restart "$container"
        echo -e "${GREEN}✓ $container reiniciado${NC}"
    else
        echo -e "${RED}Error: Contenedor '$container' no encontrado${NC}"
        exit 1
    fi
}

# Detener todos los contenedores
stop_all_containers() {
    echo "Deteniendo todos los contenedores..."
    
    running=$(docker ps -q)
    if [ -n "$running" ]; then
        docker stop $running
        echo -e "${GREEN}✓ Todos los contenedores detenidos${NC}"
    else
        echo "No hay contenedores activos"
    fi
}

# Ver puertos mapeados
show_ports() {
    echo -e "${GREEN}=== Puertos Mapeados ===${NC}"
    docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -v "PORTS" | while read line; do
        name=$(echo "$line" | awk '{print $1}')
        ports=$(echo "$line" | cut -d' ' -f2-)
        if [ -n "$ports" ] && [ "$ports" != "-" ]; then
            echo "$name:"
            echo "$ports" | tr ',' '\n' | sed 's/^/  /'
            echo ""
        fi
    done
}

# Programa principal
main() {
    check_docker
    
    case "${1:-}" in
        list)
            list_containers "${2:-}"
            ;;
        images)
            list_images
            ;;
        volumes)
            list_volumes
            ;;
        clean)
            clean_containers
            ;;
        clean-all)
            clean_all
            ;;
        stats)
            show_stats
            ;;
        prune)
            prune_system
            ;;
        restart)
            restart_container "${2:-}"
            ;;
        stop-all)
            stop_all_containers
            ;;
        ports)
            show_ports
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            echo "Comando no reconocido: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar
main "$@"