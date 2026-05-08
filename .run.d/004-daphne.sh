
daphne_runserver() {
    if [ $# -eq 0 ]; then
        if [ "$PYTHON_POETRY" -eq 1 ]; then
            daphne="poetry run daphne"
        else
            daphne="daphne"
        fi
        exec $daphne -b "$HTTP_ADDRESS" -p "$HTTP_PORT" "django_project.asgi:application"
    else
        exec $daphne "$@"
    fi
}
