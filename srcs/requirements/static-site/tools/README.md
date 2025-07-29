# Inception Project

Este proyecto despliega una infraestructura web completa utilizando Docker y Docker Compose. La arquitectura está compuesta por múltiples servicios contenerizados que trabajan juntos para ofrecer un sitio de WordPress funcional, junto con varios servicios adicionales de gestión, caché y monitoreo.

---
## 🚀 Arquitectura de Servicios

La aplicación se compone de los siguientes servicios, cada uno en su propio contenedor:

| Servicio | Propósito | Puerto(s) Expuestos (Host:Container) | Volúmenes Utilizados |
| :--- | :--- | :--- | :--- |
| **NGINX** | Servidor web y proxy inverso. Punto de entrada único con TLS. | `443:443` | `wp_files` (lectura) |
| **WordPress** | El Sistema de Gestión de Contenidos (CMS). | `9000` (interno para PHP-FPM) | `wp_files` |
| **MariaDB** | Base de datos SQL para WordPress. | `3306` (interno) | `db_data` |
| **Redis** | Caché de objetos en memoria para acelerar WordPress. | `6379` (interno) | N/A |
| **Adminer** | Interfaz web ligera para la gestión de la base de datos. | `8080:8080` | N/A |
| **FTP Server** | Servidor FTP (`vsftpd`) para acceso a los archivos de WordPress. | `21:21`, `21100-21110` | `wp_files` |
| **Static Site** | Un sitio web estático simple servido por NGINX. | `8000:80` | N/A |
| **Portainer** | Interfaz gráfica para la gestión del entorno Docker. | `9443:9443` | `portainer_data`, `docker.sock` |

---
## 🛠️ Componentes Globales

### Red (Network)
* **`inception`**: Todos los servicios están conectados a una única red de tipo `bridge` personalizada. Esto permite la comunicación entre ellos usando los nombres de los servicios como si fueran DNS.

### Volúmenes (Volumes)
Los datos persistentes se gestionan mediante volúmenes para asegurar que no se pierdan al reiniciar o reconstruir los contenedores.

* **`wp_files`**:
    * **Tipo**: Bind Mount
    * **Ruta en el Host**: `/home/cde-la-r/data/wordpress`
    * **Propósito**: Almacena todos los archivos del core, temas y plugins de WordPress.
* **`db_data`**:
    * **Tipo**: Bind Mount
    * **Ruta en el Host**: `/home/cde-la-r/data/db`
    * **Propósito**: Almacena los datos de la base de datos MariaDB.
* **`portainer_data`**:
    * **Tipo**: Volumen Gestionado por Docker
    * **Propósito**: Almacena los datos de configuración de Portainer.

### Configuración
* **`.env`**: Un archivo en `srcs/.env` contiene todas las variables de entorno y secretos (contraseñas, nombres de usuario, etc.) para mantener la configuración segura y separada del código.
* **`Makefile`**: Proporciona una interfaz de comandos simple (`make`, `make clean`, `make re`) para gestionar el ciclo de vida de la aplicación.

---
## 🖥️ Puntos de Acceso

Una vez que la aplicación está en marcha (`make`), los servicios son accesibles en las siguientes direcciones:

* **WordPress**: `https://cde-la-r.42.fr`
* **Adminer**: `http://cde-la-r.42.fr:8080`
* **Sitio Estático**: `http://cde-la-r.42.fr:8000`
* **Portainer**: `https://cde-la-r.42.fr:9443`
* **FTP Server**: `ftp://cde-la-r.42.fr` (Puerto 21)
