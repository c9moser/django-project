#!/bin/sh
self="$(realpath "$0")"
BASE_DIR="$(dirname "$self")"; epxort BASE_DIR

cd "$BASE_DIR"

: ${DEFAULT_VIRTUAL_ENV:="$BASE_DIR/.venv"}
: ${PYTHON_REQUIREMENTS:=$BASE_DIR/requirements.txt}

if [ -n "${PYTHON_REQUIREMENTS%%/*}" ]; then  # check if path is relative
	PYTHON_REQUIREMENTS="$BASE_DIR/$PYTHON_REQUIREMENTS"
fi
export PYTHON_REQUIREMENTS
echo "[INFO] PYTHON_REQUIREMENTS=$PYTHON_REQUIREMENTS"

: ${PYTHON_POETRY:=0}
if [ -n "$(echo ${PYTHON_POETRY} | grep -E '^(1|[yY][eE][sS]|[oO][nN]|[tT][rR][uU][eE])$')" ]; then
	if ! command -v poetry >/dev/null 2>&1; then
		echo "[CRITICAL] Poetry is not installed or not in PATH" >&2
		echo "Install it (for example: pip install poetry) and retry." >&2
		exit 1
	fi
fi

# initializing


IFS=$'\n'
for i in $(ls "$BASE_DIR/run.d/* | sort"); do
	if [ "${i##**.}" = "sh" ]; then
		. "$i" || exit $?
	elif [ -x "$i" ]; then
		echo "[INFO] Running initialization script: $i"
		"$i" || exit $?
	fi
done

if [ $# -eq 0 ]; then
	echo "[INFO] No command provided, defaulting to 'runserver'"
	runserver
	exit $?
fi

case "$1" in
	runserver)
		shift
		runserver "$@"
		exit $?
		;;
	makemigrations)
		shift
		manage makemigrations "$@"
		exit $?
		;;
	migrate)
		shift
		manage migrate "$@"
		exit $?
		;;
	collectstatic)
		shift
		manage collectstatic "$@"
		exit $?
		;;
	update)
		shift
		update "$@"
		exit $?
		;;
	manage)
		shift
		manage "$@"
		exit $?
		;;
	makemessages)
		shift
		manage makemessages "$@"
		exit $?
		;;
	compilemessages)
		shift
		manage compilemessages "$@"
		exit $?
		;;
	createsuperuser)
		shift
		manage createsuperuser "$@"
		exit $?
		;;
	poetry)
		shift
		poetry "$@"
		exit $?
		;;
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
	poetry-manage)
		shift
		poetry_manage "$@"
		exit $?
		;;
	poetry-makemessages)
		shift
		poetry_manage makemessages "$@"
		exit $?
		;;
	poetry-compilemessages)
		shift
		poetry_manage compilemessages "$@"
		exit $?
		;;
	poetry-migrate)
		shift
		poetry_manage migrate "$@"
		exit $?
		;;
	poetry-makemigrations)
		shift
		poetry_manage makemigrations "$@"
		exit $?
		;;
	poetry-collectstatic)
		shift
		poetry_manage collectstatic "$@"
		exit $?
		;;
	porty-runserver)
		shift
		poetry_manage runserver "$@"
		exit $?
		;;
	py-runserver)
		shift
		py-runserver "$@"
		exit $?
		;;
	py-update)
		shift
		py-update "$@"
		exit $?
		;;
	py-manage)
		shift
		py-manage "$@"
		exit $?
		;;
	py-compilemessages)
		shift
		py-manage compilemessages "$@"
		exit $?
		;;
	py-makemessages)
		shift
		py-manage makemessages "$@"
		exit $?
		;;
	py-migrate)
		shift
		py-manage migrate "$@"
		exit $?
		;;
	py-makemigrations)
		shift
		py-manage makemigrations "$@"
		exit $?
		;;
	py-collectstatic)
		shift
		py-manage collectstatic "$@"
		exit $?
		;;
	help)
		less << EOF
Usage: run.sh <command> [options] [args]

Available commands:
  runserver        - Start the development server (usage: runserver [otpions])
  makemigrations   - Create new database migrations based on the models
  					(usage: makemigrations [app_label])
  migrate          - Apply database migrations
  					(usage: migrate [app_label] [migration_name])
  collectstatic    - Collect static files into STATIC_ROOT
  					(usage: collectstatic [options])
  update           - Update dependencies and apply migrations
  					(usage: update)
  makemessages     - Create message files for translation
  					(usage: makemessages [options])
  compilemessages  - Compile message files for translation
  					(usage: compilemessages [options])
  createsuperuser  - Create a new superuser account
  					(usage: createsuperuser)
  manage		   - Run a custom manage.py command (usage: manage <command> [args])
  createvenv	   - Create a Python virtual environment
  					(usage: createvenv)
  py-runserver     - Run the development server using Poetry environment
  					(usage: py-runserver [ip:port])
  py-update        - Update dependencies and apply migrations using Poetry environment
  					(usage: py-update)
  py-manage        - Run a custom manage.py command using Poetry environment
  					(usage: py-manage <command> [args])
  py-makemessages   - Create message files for translation using Poetry environment
  					(usage: py-makemessages [options])
  py-compilemessages- Compile message files for translation using Poetry environment
  					(usage: py-compilemessages [options])
  py-migrate       - Apply database migrations using Poetry environment
  					(usage: py-migrate [app_label] [migration_name])
  py-makemigrations- Create new database migrations based on the models using Poetry environment
  					(usage: py-makemigrations [app_label])
  py-collectstatic - Collect static files into STATIC_ROOT using Poetry environment
  					(usage: py-collectstatic [options])
  poetry           - Run a Poetry command
  					(usage: poetry <command> [args])
  poetry-install   - Install dependencies using Poetry
  					(usage: poetry-install [options])
  poetry-update    - Update dependencies using Poetry
  					(usage: poetry-update [options])
  poetry-manage    - Run a custom manage.py command using Poetry
  					(usage: poetry-manage <command> [args])
  poetry-makemessages - Create message files for translation using Poetry environment
  					(usage: poetry-makemessages [options])
  poetry-compilemessages - Compile message files for translation using Poetry environment
  					(usage: poetry-compilemessages [options])
  poetry-migrate   - Apply database migrations using Poetry environment
  					(usage: poetry-migrate [app_label] [migration_name])
  poetry-makemigrations - Create new database migrations based on the models using Poetry environment
  					(usage: poetry-makemigrations [app_label])
  poetry-collectstatic - Collect static files into STATIC_ROOT using Poetry environment
  					(usage: poetry-collectstatic [options])
  poetry-runserver - Run the development server using Poetry environment, binding to all interfaces
  					(usage: poetry-runserver [ip:port])
  help             - Show this help message
EOF
		exit 0
		;;
	*)
		echo "[INFO] Running command: $*"
		exec "$@"
		exit $?
		;;
esac
