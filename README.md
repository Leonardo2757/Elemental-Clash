# Elemental Clash 🃏⚡

**Juego de cartas por turnos para 2 jugadores locales desarrollado en Godot 4**

## Descripción
Elemental Clash es un juego de cartas 2D donde dos jugadores compiten seleccionando cartas de su mazo de 20 cartas simultáneamente. Las cartas tienen elementos (Fuego, Agua, Tierra, Rayo, Especial) con ventajas y desventajas entre sí. El clima real de Guadalajara influye en qué elemento recibe bonificación de daño cada partida.

## Controles
| Jugador | Navegar | Seleccionar |
|---------|---------|-------------|
| Jugador 1 | A / D | F |
| Jugador 2 | ← / → | Enter |

## Sistema elemental
- **Fuego** vence a Tierra, pierde contra Agua
- **Agua** vence a Fuego, pierde contra Tierra
- **Tierra** vence a Agua, pierde contra Fuego
- **Rayo** vence a Agua, pierde contra Tierra
- Vencer por ventaja elemental otorga **+3 de daño**

## Cartas especiales
| Carta | Efecto |
|-------|--------|
| Espejo | Copia el elemento y ataque del rival |
| Escudo | Bloquea todo el daño del turno |
| Caos | Inflige exactamente 5 de daño fijo |

## Requisitos técnicos cubiertos
- ✅ 2 jugadores locales con controles diferenciados
- ✅ Máquina de estados (MENU → PROFILES → SELECTING → REVEALING → GAME_OVER)
- ✅ API externa (Open-Meteo, clima en tiempo real) con reintentos y fallback local
- ✅ POST de resultados a API remota (httpbin.org como placeholder)
- ✅ Persistencia JSON (reemplazable por SQLite con el addon)
- ✅ Perfiles de jugador con historial individual
- ✅ Tabla de líderes top 10
- ✅ Autosave cada 30 segundos
- ✅ Recuperación de sesión interrumpida
- ✅ Pantalla de configuración (volumen música, SFX, URL APIs, intervalo autosave)
- ✅ Retroalimentación audiovisual (tonos procedurales + colores)
- ✅ Indicadores de carga
- ✅ Revancha sin reiniciar la aplicación
- ✅ Exportable a web (GL Compatibility)

## Instrucciones de instalación
1. Descargar **Godot 4.2+** desde [godotengine.org](https://godotengine.org)
2. Abrir el proyecto: `Proyecto → Importar → seleccionar project.godot`
3. Presionar **F5** para ejecutar
4. Para exportar a web: `Proyecto → Exportar → Web (HTML5)`

## Exportación para itch.io
1. En Godot: `Proyecto → Exportar → Agregar plantilla → Web`
2. Activar "Export PCK/Zip" si es necesario
3. Subir la carpeta generada a itch.io como HTML
4. En itch.io seleccionar "This file will be played in the browser"

## Estructura del proyecto
```
elemental_clash/
├── project.godot
├── icon.svg
├── README.md
├── scripts/
│   ├── CardData.gd          # Recurso de carta
│   ├── DeckBuilder.gd       # Constructor de mazo 20 cartas
│   ├── GameManager.gd       # Singleton: lógica y máquina de estados
│   ├── DatabaseManager.gd   # Persistencia JSON/SQLite
│   ├── APIManager.gd        # API clima + POST resultados
│   ├── AudioManager.gd      # Audio procedural
│   ├── SaveManager.gd       # Autosave cada 30s
│   ├── ConfigManager.gd     # Configuración persistente
│   ├── Main.gd              # Controlador raíz
│   ├── CardNode.gd          # Nodo visual de carta
│   ├── ScreenMenu.gd
│   ├── ScreenProfiles.gd
│   ├── ScreenGame.gd
│   ├── ScreenGameOver.gd
│   ├── ScreenSettings.gd
│   ├── ScreenLeaderboard.gd
│   └── ScreenHistory.gd
└── scenes/
	├── Main.tscn
	└── CardNode.tscn
```

## Créditos
- API clima: [Open-Meteo](https://open-meteo.com/) (open source, sin API key)

## Notas sobre SQLite
Para usar SQLite real en lugar del fallback JSON:
1. Descargar el addon [godot-sqlite](https://github.com/2shady4u/godot-sqlite)
2. Colocar en `addons/godot-sqlite/`
3. Activar en `Proyecto → Ajustes del proyecto → Plugins`
4. Reemplazar los métodos `_save_db` / `_load_db` en `DatabaseManager.gd`
