if [ -z "$VIRTUAL_ENV" ]; then
	venv_targets="$(echo -en "$BASE_DIR/.venv\n$BASE_DIR/venv\n$(dirname "$BASE_DIR")/.venv\n$(dirname "$BASE_DIR")/venv")"

	if [ "$CONTAINERIZED" ]; then
		venv_targets=$(echo -en "/venv\n$venv_targets")
	fi
	if [ -n "$( echo "$PYTHON_POETRY" | grep -E '^(1|[yY]|[yY][eE][sS]|[oO][nN]|[tT][rR][uU][eE]|[Oo][Nn])$')" ]; then
		venv_targets=$(echo -en "$(poetry env info -p 2>/dev/null)\n$venv_targets")
	fi

	ifs_save="$IFS"
	IFS=$'\n'
	for i in $venv_targets; do
		if [ -d "$i" ]; then
			VIRTUAL_ENV="$i"
		fi
	done
	IFS="$ifs_save"

	if [ -z "$VIRTUAL_ENV" ]; then
		VIRTUAL_ENV="$DEFAULT_VIRTUAL_ENV"
	fi
fi
export VIRTUAL_ENV


if [ -z "$( echo "$PYTHON_POETRY" | grep -E '^(1|[yY]|[yY][eE][sS]|[oO][nN]|[tT][rR][uU][eE]|[Oo][Nn])$')" ]; then
	if [ ! -f "$VIRTUAL_ENV/bin/activate" ]; then
		python="$(which python 2>/dev/null)"
		if [ $? -ne 0 ]; then
			python="$(which python 2>/dev/null)"
			if [ $? -ne 0 ]; then
				echo "[CRITICAL] No python interpreter found!" >&2
				exit 3
			fi
		fi

		echo "[WARNING] Activate script not found!"
		echo "[INFO] Initializing virtual env!"
		"$python" -m venv "$VIRTUAL_ENV"
		rc=$?
		if [ $rc -ne 0 ]; then
			echo "[CRITICAL] Unable to initialize virtual environment!" >&2
			exit $rc
		fi
		"$VIRTUAL_ENV/bin/pip install -r requirements.txt"
		rc=$?
		if [ $? -ne 0 ]; then
			echo "[CRITICAL] Unable to install requirements!" >&2
			exit $rc
		fi
	fi
	. "$VIRTUAL_ENV/bin/activate"
fi

py-runserver() {
	if [ -n "$(echo "$CONTAINERIZED" | grep '(1|[yY][eE][sS]|[oO][nN]|[tT][rR][uU][eE])')" ]; then
		echo "[INFO] Running in containerized environment, binding to all interfaces"
		exec python manage.py runserver 0.0.0:8000
		return $?
	elif [ $# -eq 0 ]; then
		echo "[INFO] No arguments provided to runserver, defaulting to 'runserver' with IP 127.0.0.1:8000"
		exec python manage.py runserver 127.0.0.1:8000
		return $?
	fi
	python manage.py runserver "$@"
	return $?
}

py-update() {
	pip install --no-cache-dir -r $PYTHON_REQUIREMENTS
	rc=$?
	if [ $rc -ne 0 ]; then
		echo "[CRITICAL] Unable to update application! (Updating requirements failed!)" >&2
		return $?
	fi
	python manage.py migrate --noinput
	rc=$?
	if [ $rc -ne 0 ]; then
		echo "[CRITICAL] Unable to update application! (Database migration failed!)" >&2
		return $?
	fi
	python manage.py collectstatic --noinput
	rc=$?
	if [ $rc -ne 0 ]; then
		echo "[CRITICAL] Unable to update application! (Collecting static files failed!)" >&2
		return $?
	fi
	return 0
}

py-manage() {
	python manage.py "$@"
	return $?
}

if [ -z "$(echo "$CONTAINERIZED" | grep '(1|[yY][eE][sS]|[oO][nN]|[tT][rR][uU][eE])')" ]; then
	manage() {
		py-manage "$@"
		return $?
	}
	update() {
		py-update "$@"
		return $?

	}
	runserver() {
		py-runserver "$@"
		return $?
	}2
fi