# Name_Switcher

Este script en PowerShell proporciona una interfaz gráfica (GUI) para renombrar archivos de series de televisión de manera rápida y organizada. Está pensado para usuarios que desean estandarizar el nombre de sus episodios de forma masiva con un formato común, facilitando la gestión y reproducción en sistemas multimedia.

Características
Interfaz gráfica amigable y responsiva con Windows Forms.

Selección de carpeta que contiene los archivos a renombrar.

Filtro de búsqueda para mostrar sólo archivos que coincidan con un texto específico.

Soporte para extensiones de vídeo comunes (mkv, mp4, avi, etc.).

Configuración de nombre de la serie y número de temporada.

Varias opciones de ordenamiento (por número inicial ascendente/descendente, por nombre ascendente/descendente).

Vista previa en tiempo real de los nombres actuales y cómo quedarán tras el renombrado.

Confirmación antes de renombrar para evitar errores.

Manejo de errores para evitar sobrescrituras y problemas con nombres inválidos.

Formato de renombrado
Los archivos serán renombrados al formato:

* NombreDeLaSerie SXXEXX.ext

- NombreDeLaSerie: texto definido por el usuario.
- SXX: número de temporada con dos dígitos.
- EXX: número de episodio correlativo con dos dígitos.
- .ext: extensión original del archivo.

Uso
Ejecuta el script en PowerShell con permisos necesarios.

Selecciona la carpeta donde están los archivos de la serie.

Escribe el nombre de la serie y el número de temporada.

Opcionalmente, usa el filtro para limitar la lista de archivos.

Revisa la previsualización y ajusta el orden si quieres.

Haz clic en "Renombrar archivos" para aplicar los cambios.

