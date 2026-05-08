#!/bin/sh
self="$(realpath "$0")"
BASE_DIR="$(dirname "$self")"; export BASE_DIR

cd "$BASE_DIR"


if [ -z "${PYTHON_REQUIREMENTS%%/*}" ]; then  # check if path is relative
	PYTHON_REQUIREMENTS="$BASE_DIR/$PYTHON_REQUIREMENTS"
fi
export PYTHON_REQUIREMENTS
echo "[INFO] PYTHON_REQUIREMENTS=$PYTHON_REQUIREMENTS"

for i in $(ls $BASE_DIR/.run.d/* | sort); do
	if [ "${i##*.}" = "sh" ]; then
		echo "[INFO] Sourcing initialization script: $i"
		. "$i"  || exit $?
	elif [ -x "$i" ]; then
		echo "[INFO] Running initialization script: $i"
		"$i" || exit $?
	fi
done

# initializing


help() {
	less << EOF
Usage: run.sh <command> [options] [args]

Available commands:
  Generic commands:
	help                     Show this help message and exit
    runserver                Start the HTTP server (default)
    manage                   Run a Django management command
    makemigrations           Create new migrations based on the changes detected to your models
    migrate                  Apply database migrations
    collectstatic            Collect static files into STATIC_ROOT
    makemessages             Create message files for translation
    compilemessages          Compile message files for translation
    createsuperuser          Create a superuser account

  Poetry commands:
    poetry-install           Install dependencies using Poetry
    poetry-update            Update dependencies using Poetry
    poetry                   Run a Poetry command

  Django runserver variants:
    django-runserver         Start Django's development server
    django-runserver-plus    Start Django's development server with django-extensions' runserver_plus

  Daphne commands:
    daphne-runserver         Start the Daphne ASGI server

  uWSGI commands:
    uwsgi-runserver          Start the uWSGI server
    uwsgi-mkconfig           Create a default uWSGI configuration file if it doesn't exist

  Apache commands:
	apache-runserver         Start the Apache HTTP server in the foreground
	apache-mkconfig          Create an Apache configuration file for the Django project
EOF
}



if [ $# -eq 0 ]; then
	echo "[INFO] No command provided, defaulting to 'runserver'"
	${HTTP_SERVER}_runserver
	exit $?
fi

case "$1" in
	runserver)
		shift
		if [ -z "$HTTP_SERVER" ]; then
			HTTP_SERVER=django
			export HTTP_SERVER
		fi
		echo "[INFO] Starting HTTP server: $HTTP_SERVER"
		${HTTP_SERVER}_runserver "$@"
		exit $?
		;;

	# django management commands
	manage)
		shift
		manage "$@"
		exit $?
		;;
	makemigrations)
		shift
		makemigrations "$@"
		exit $?
		;;
	migrate)
		shift
		migrate "$@"
		exit $?
		;;
	collectstatic)
		shift
		collectstatic "$@"
		exit $?
		;;
	makemessages)
		shift
		makemessages "$@"
		exit $?
		;;
	compilemessages)
		shift
		compilemessages "$@"
		exit $?
		;;
	createsuperuser)
		shift
		createsuperuser "$@"
		exit $?
		;;

	# django runserver variants
	django-runserver)
		shift
		django_runserver "$@"
		exit $?
		;;
	django-runserver-plus)
		shift
		django-extensions_runserver "$@"
		exit $?
		;;
	django-extensions-runserver)
		shift
		django-extensions_runserver "$@"
		exit $?
		;;
	# Poetry commands
	poetry-install)
		shift
		poetry_install "$@"
		exit $?
		;;
	poetry-update)
		shift
		poetry_update "$@"
		exit $?
		;;
	poetry)
		shift
		poetry "$@"
		exit $?
		;;

    # Apache
	apache-runserver)echo "[INFO] Running command: $*"
		exec "$@"
		exit $?
		shift
		apache_runserver "$@"
		exit $?
		;;
	apache-mkconfig)
		shift
		apache_mkconfig "$@"
		exit $?
		;;

	# Daphne
	daphne-runserver)
		shift
		daphne_runserver "$@"
		exit $?
		;;

	# uWSGI
	uwsgi-runserver)
		shift
		uwsgi_runserver "$@"
		exit $?
		;;
	uwsgi-mkconfig)
		shift
		uwsgi_mkconfig "$@"
		exit $?
		;;
	help)
		help
		exit 0
		;;
	*)
		echo "[ERROR] Unknown command: $1" >&2
		echo "Use 'run.sh help' to see available commands." >&2
		exit 1
		;;
esac
