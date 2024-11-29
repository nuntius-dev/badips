# BadIPs Blocker Service

Este proyecto es un script de Bash diseñado para bloquear direcciones IP maliciosas reportadas en una lista específica, agregándolas al archivo `/etc/hosts.deny`. Su propósito es mejorar la seguridad del sistema al prevenir el acceso de IPs no deseadas.

[escritorio](BadIPs.png)
## Características

- **Automatización:** Descarga automáticamente una lista de IPs desde una fuente remota.
- **Verificación de accesibilidad:** Revisa si las IPs son accesibles antes de bloquearlas.
- **Bloqueo dinámico:** Actualiza el archivo `/etc/hosts.deny` con un bloque específico para las IPs maliciosas.
- **Respaldo local:** Usa un archivo local (`domains.list`) en caso de que falle la descarga remota.
- **Verbose output:** Informa detalladamente cada paso del proceso para una mejor comprensión.

## Requisitos

- **Sistema operativo:** Linux (con soporte para `/etc/hosts.deny`).
- **Dependencias:** 
  - `wget`: Para descargar la lista de IPs.
  - `ping`: Para verificar la accesibilidad de las IPs.
  - Acceso como usuario root o permisos para modificar `/etc/hosts.deny`.

## Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/nuntius-dev/badips-blocker.git
   cd badips-blocker
   ```

2. **Dar permisos de ejecución al script:**
   ```bash
   chmod +x block_bad_ips.sh
   ```

3. **Opcional:** Asegúrate de tener un archivo de respaldo local `domains.list` en el mismo directorio del script.

## Uso

1. Ejecuta el script como root o con permisos elevados:
   ```bash
   sudo ./block_bad_ips.sh
   ```

2. El script:
   - Descargará la lista de IPs desde el enlace configurado o usará el archivo de respaldo.
   - Verificará la accesibilidad de cada IP.
   - Actualizará el archivo `/etc/hosts.deny` para bloquear las IPs maliciosas.

3. Revisa los mensajes en consola para confirmar cada paso del proceso.

## Ejemplo de Salida

```plaintext
🔄 Intentando descargar lista de IPs desde https://www.nubi-network.com/list.txt...
✅ Lista descargada con éxito desde https://www.nubi-network.com/list.txt.
🔄 Verificando accesibilidad de las IPs...
🔍 Verificando IP (1/100): 113.206.242.21... ✅ IP accesible: 113.206.242.21
🔍 Verificando IP (2/100): 216.68.209.51... ❌ IP no accesible: 216.68.209.51
✅ Verificación de IPs completada.
🔄 Procesando /etc/hosts.deny...
✅ Bloque anterior eliminado de /etc/hosts.deny.
🔄 Añadiendo nuevas IPs al archivo...
✅ Nuevas IPs añadidas al bloque.
🔄 Limpiando archivos temporales...
✅ Archivos temporales eliminados.
🎉 Bloqueo de IPs completado con éxito.
```

## Personalización

- **Fuente remota de IPs:** Edita la variable `IP_LIST_URL` en el script para usar tu propio enlace.
- **Archivo local de respaldo:** Usa un archivo personalizado llamado `domains.list` con las IPs que deseas bloquear.

## Notas de Seguridad

- Asegúrate de tener permisos adecuados para modificar `/etc/hosts.deny`.
- Verifica que la lista de IPs sea confiable para evitar bloqueos innecesarios.

## Contribuciones

¡Tu ayuda es bienvenida! Si deseas contribuir:

1. Haz un fork del repositorio.
2. Crea una rama para tu característica o corrección:
   ```bash
   git checkout -b mi-nueva-funcionalidad
   ```
3. Haz tus cambios y crea un pull request.
Sí, puedes ejecutar el script de forma silenciosa utilizando una de las siguientes opciones:

### 1. **Ejecución en segundo plano**  
Puedes ejecutar el script en segundo plano usando `&`. Esto inicia el script y libera la terminal para otras tareas:  

```bash
sudo ./block_bad_ips.sh &
```

Esto ejecutará el script, pero algunos mensajes de salida aún aparecerán en la terminal.

---

### 2. **Redirigir la salida a un archivo o descartar los mensajes**
Si quieres evitar que los mensajes se muestren en la terminal, puedes redirigir tanto la salida estándar como los errores estándar:

```bash
sudo ./block_bad_ips.sh > /dev/null 2>&1 &
```

- `> /dev/null`: Redirige la salida estándar (stdout) para que no se muestre.
- `2>&1`: Redirige la salida de error (stderr) al mismo lugar que stdout.

---

### 3. **Usar `nohup` para persistencia (opcional)**  
Si quieres que el script siga ejecutándose incluso después de cerrar la terminal:

```bash
nohup sudo ./block_bad_ips.sh > /dev/null 2>&1 &
```

- `nohup`: Asegura que el proceso no se detenga si la sesión termina.

---

### 4. **Usar `cron` para ejecuciones automatizadas**  
Si el script necesita ejecutarse regularmente de forma silenciosa, puedes configurarlo en `cron`:

1. Edita el archivo de tareas cron:
   ```bash
   sudo crontab -e
   ```

2. Añade una línea para ejecutar el script (por ejemplo, todos los días a las 3:00 AM):
   ```plaintext
   0 3 * * * /ruta/al/script/block_bad_ips.sh > /dev/null 2>&1
   ```

Esto ejecutará el script en segundo plano en el horario definido.


## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

[![comprar cafe](kofi.png)](https://ko-fi.com/P5P013UUGZ)
