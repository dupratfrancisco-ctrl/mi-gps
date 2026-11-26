# Mi GPS para iPhone (con Isla Dinámica)

App nativa que muestra Mi GPS y pone la navegación en la Isla Dinámica y en la pantalla bloqueada.

## 1. Armar el proyecto (una vez)
Abrí la app **Terminal** en la Mac, pegá esto y apretá Enter:

    cd ~ && curl -fsSL https://github.com/dupratfrancisco-ctrl/mi-gps/archive/refs/heads/main.zip -o migps.zip && unzip -oq migps.zip && bash mi-gps-main/ios/armar.sh

## 2. Firmar e instalar en el iPhone
1. Conectá el iPhone a la Mac con el cable.
2. En Xcode, arriba a la izquierda tocá **MiGPS** (el ícono azul) → pestaña **Signing & Capabilities**.
3. En **Team** elegí tu Apple ID (si no aparece: *Add an Account…* e iniciá sesión).
4. Repetí el paso 3 eligiendo el target **MiGPSWidget** en la lista de la izquierda.
5. Arriba, al lado del botón ▶, elegí tu iPhone y tocá **▶**.
6. La primera vez, en el iPhone: **Ajustes → General → VPN y gestión de dispositivos** → tu Apple ID → **Confiar**.
   Si te pide **Modo de desarrollador**: Ajustes → Privacidad y seguridad → Modo de desarrollador → activar y reiniciar.

Con Apple ID gratis la app dura 7 días; después repetís el paso 5.
