
django_runserver() {
    if [ $# -eq 0 ]; then
        exec $python manage.py runserver "$HTTP_ADDRESS:$HTTP_PORT"
    else
        exec $python manage.py runserver "$@"
    fi
    return $?
}

django-extensions_runserver() {
    if [ $# -eq 0 ]; then
        exec $python manage.py runserver_plus "$HTTP_ADDRESS:$HTTP_PORT"
    else
        exec $python manage.py runserver_plus "$@"
    fi
}

manage() {
    $python manage.py "$@"
    return $?
}

migrate() {
    manage migrate "$@"
    return $?
}

makemigrations() {
    manage makemigrations "$@"
    return $?
}

collectstatic() {
    manage collectstatic --noinput
    return $?
}

makemessages() {
    manage makemessages "$@"
    return $?
}

compilemessages() {
    manage compilemessages "$@"
    return $?
}
