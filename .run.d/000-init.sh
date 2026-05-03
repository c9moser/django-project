RE_TRUE="^(1|[yY]|[yY][eE][sS]|[tT][rR][uU][eE]|[Oo][Nn])$" ; export RE_TRUE
RE_FALSE="^(0|[nN]|[nN][oO]|[fF][aA][lL][sS][eE]|[Oo][Ff][fF])$" ; export RE_FALSE

if [ -n "$MEDIA_ROOT" ]; then
    if [ ! -d "$MEDIA_ROOT" ]; then
        echo "[INFO] MEDIA_ROOT directory '$MEDIA_ROOT' does not exist, creating it..."
        mkdir -p "$MEDIA_ROOT" || { echo "[CRITICAL] Failed to create MEDIA_ROOT directory '$MEDIA_ROOT'!" >&2; exit 1; }
    fi
fi

if [ -n "$STATIC_ROOT" ]; then
    if [ ! -d "$STATIC_ROOT" ]; then
        echo "[INFO] STATIC_ROOT directory '$STATIC_ROOT' does not exist, creating it..."
        mkdir -p "$STATIC_ROOT" || { echo "[CRITICAL] Failed to create STATIC_ROOT directory '$STATIC_ROOT'!" >&2; exit 1; }
    fi
fi

if [ -n "$( echo "$CONTAINERIZED" | grep -E "$RE_TRUE" )" ]; then
    echo "[INFO] Running in containerized environment, setting PYTHON_REQUIREMENTS to /app/requirements.txt"
    if [ ! -d '/data/.config' ]; then
        echo "[INFO] /data/.config directory does not exist, creating it..."
        mkdir -p '/data/.config' || { echo "[CRITICAL] Failed to create /data/.config directory!" >&2; exit 1; }
    fi
    export PYTHON_REQUIREMENTS='/app/requirements.txt'
fi
