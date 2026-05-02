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
