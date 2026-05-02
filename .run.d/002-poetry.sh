# poetry.sh - Poetry support for run.sh

poetry() {
    if ! command -v poetry >/dev/null 2>&1; then
        echo "[CRITICAL] Poetry is enabled but not found in PATH!" >&2
        echo "Install it (for example: pip install poetry) and retry." >&2
        exit 1
    fi
    local poetry_cmd="$(which poetry)"
    $poetry_cmd "$@"
    return $?
}

poetry_install() {
    if ! command -v poetry >/dev/null 2>&1; then
        echo "[CRITICAL] Poetry is enabled but not found in PATH!" >&2
        echo "Install it (for example: pip install poetry) and retry." >&2
        exit 1
    fi
    if [ $# -eq 0 ]; then
        echo "[INFO] No command provided for poetry install, defaulting to 'install --no-interaction --all --no-root'"
        poetry install --no-interaction --all --no-root
    else
        poetry install "$@"
    fi
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "[CRITICAL] Poetry install failed!" >&2
        exit $rc
    fi
    return 0
}

poetry_update() {
    if ! command -v poetry >/dev/null 2>&1; then
        echo "[CRITICAL] Poetry is enabled but not found in PATH!" >&2
        echo "Install it (for example: pip install poetry) and retry." >&2
        exit 1
    fi
    if [ $# -eq 0 ]; then
        echo "[INFO] No command provided for poetry update, defaulting to 'update --no-interaction --all --no-root'"
        poetry update --no-interaction --all --no-root
    else
        poetry update "$@"
    fi
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "[CRITICAL] Poetry update failed!" >&2
        exit $rc
    fi
    return 0
}

poetry_manage() {
    if ! command -v poetry >/dev/null 2>&1; then
        echo "[CRITICAL] Poetry is enabled but not found in PATH!" >&2
        echo "Install it (for example: pip install poetry) and retry." >&2
        exit 1
    fi
    poetry run python manage.py "$@"
    return $?
}


if [ -n "$( echo "$PYTHON_POETRY" | grep -E '^(1|[yY]|[yY][eE][sS]|[oO][nN]|[tT][rR][uU][eE]|[Oo][Nn])$')" ]; then
    if ! command -v poetry >/dev/null 2>&1; then
        echo "[CRITICAL] Poetry is enabled but not found in PATH!" >&2
        echo "Install it (for example: pip install poetry) and retry." >&2
        exit 1
    fi
    update() {
        poetry_update "$@"
        rc=$?
        if [ $rc -ne 0 ]; then
            echo "[CRITICAL] Poetry update failed!" >&2
            exit $rc
        fi
    }
    install() {
        poetry_install "$@"
        poetry_manage "collectstatic" --noinput
        poetry_manage "migrate" --noinput
        rc=$?
    }
    manage() {
        poetry_manage "$@"
        return $?
    }
    echo "[INFO] Poetry is enabled"
fi