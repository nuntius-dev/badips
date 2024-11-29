#!/bin/bash
# *****************************************************************************************************
# Script para bloquear IPs reportadas en una lista y añadirlas a /etc/hosts.deny
# *****************************************************************************************************

# Variables configurables
HOSTS_DENY="/etc/hosts.deny"
INPUT="badips.list"
TMP_FILE="/tmp/hosts_deny.tmp"
START_BLOCK="# ##### START nuntius.dev Block List — DO NOT EDIT #####"
END_BLOCK="# ##### END nuntius.dev Block List #####"

# URLs y respaldo local
IP_LIST_URL="https://www.nubi-network.com/list.txt"
LOCAL_BACKUP="domains.list"

# Función para manejar errores
function error_exit {
    echo "❌ Error: $1"
    exit 1
}

# Descargar la lista de IPs
echo "🔄 Intentando descargar lista de IPs desde ${IP_LIST_URL}..."
if ! wget -qO "${INPUT}" "${IP_LIST_URL}"; then
    echo "⚠️ No se pudo descargar desde ${IP_LIST_URL}. Usando respaldo local: ${LOCAL_BACKUP}."
    if [[ -f "${LOCAL_BACKUP}" ]]; then
        cp "${LOCAL_BACKUP}" "${INPUT}" || error_exit "No se pudo copiar el respaldo local ${LOCAL_BACKUP}."
    else
        error_exit "El respaldo local ${LOCAL_BACKUP} no existe."
    fi
else
    echo "✅ Lista descargada con éxito desde ${IP_LIST_URL}."
fi

# Verificar la accesibilidad de cada IP
echo "🔄 Verificando accesibilidad de las IPs..."
ACCESSIBLE_IPS=$(mktemp)
TOTAL_IPS=$(wc -l < "${INPUT}")
PROCESSED=0

while IFS= read -r ip; do
    PROCESSED=$((PROCESSED + 1))
    echo -ne "🔍 Verificando IP (${PROCESSED}/${TOTAL_IPS}): $ip...\r"
    if ping -c 1 -w 1 "$ip" &> /dev/null; then
        echo "$ip" >> "${ACCESSIBLE_IPS}"
        echo "✅ IP accesible: $ip"
    else
        echo "❌ IP no accesible: $ip"
    fi
done < "${INPUT}"

echo "✅ Verificación de IPs completada."

# Manejar bloques en hosts.deny
echo "🔄 Procesando ${HOSTS_DENY}..."
if grep -qF "${START_BLOCK}" "${HOSTS_DENY}"; then
    LINE_START=$(grep -nF "${START_BLOCK}" "${HOSTS_DENY}" | cut -d: -f1)
    LINE_END=$(grep -nF "${END_BLOCK}" "${HOSTS_DENY}" | cut -d: -f1)
    { 
        head -n "$((LINE_START - 1))" "${HOSTS_DENY}"
        tail -n "+$((LINE_END + 1))" "${HOSTS_DENY}"
    } > "${TMP_FILE}"
    echo "✅ Bloque anterior eliminado de ${HOSTS_DENY}."
else
    cp "${HOSTS_DENY}" "${TMP_FILE}" || touch "${TMP_FILE}"
    echo "ℹ️ No se encontró bloque previo en ${HOSTS_DENY}. Creando uno nuevo."
fi

# Añadir nuevas entradas
echo "🔄 Añadiendo nuevas IPs al archivo..."
{
    echo "${START_BLOCK}"
    sed "s/^/ALL: /" "${ACCESSIBLE_IPS}"
    echo "${END_BLOCK}"
} >> "${TMP_FILE}"
echo "✅ Nuevas IPs añadidas al bloque."

# Reemplazar archivo original
mv "${TMP_FILE}" "${HOSTS_DENY}" || error_exit "No se pudo actualizar ${HOSTS_DENY}."
echo "✅ Archivo ${HOSTS_DENY} actualizado correctamente."

# Limpiar archivos temporales
echo "🔄 Limpiando archivos temporales..."
rm -f "${INPUT}" "${ACCESSIBLE_IPS}"
echo "✅ Archivos temporales eliminados."

echo "🎉 Bloqueo de IPs completado con éxito."
exit 0
