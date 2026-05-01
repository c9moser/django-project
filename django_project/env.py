# vim: syn=python ts=4 sts=4 sw=4 smartindent expandtab

from pathlib import Path
from environ import Env
from .env_files import CONFIG_ENV_FILES, ENV_FILES

BASE_DIR = Path(__file__).resolve().parent.parent

ENV = Env(
        DJANGO_SETTINGS_MODULE=(str, "django_project.settings"),
        DJANGO_DATA_DIR=(str, str(BASE_DIR / ".data")),
        VENV_DIR=(str, str(BASE_DIR / ".venv")),
        CONTAINER_DATA_DIR=(str, "/data"),
        CONTAINERIZED=(bool, False),
        DEBUG=(bool, False),
        SECRET_KEY=(str, "django-insecure-j#05f7jxku!2oy7(nzim=zl15c50_(=2nkfl*mtp28$+ubt(rl"),  # noqa: E501
        SECRET_KEY_FALLBACKS=(list, []),  # noqa: E501
        DATABASE_CONFIG_METHOD=(str, "url"),
        DATABASE_URL=(str, f"sqlite:///{BASE_DIR}/.data/db.sqlite3"),
        MEDIA_URL=(str, "/media/"),
        MEDIA_ROOT=(str, str(BASE_DIR / ".data" / "media")),
        STATIC_URL=(str, "/static/"),
        STATIC_ROOT=(str, str(BASE_DIR / ".data" / "static")),
        ALLOWED_HOSTS=(list, ['*']),  # allow all hosts by default, override in production  # noqa: E501
        ENV_FILES=(list, []),
        CONFIG_ENV_FILES=(list, []),
)

CONTAINERIZED = ENV("CONTAINERIZED")


for env_file in (Path(i).resolve() for i in CONFIG_ENV_FILES):
    if env_file.is_file():
        ENV.read_env(env_file)


if env_file.is_file():
    ENV.read_env(env_file)

if CONTAINERIZED:
    env_file = Path("/etc/django.env")
    if env_file.is_file():
        ENV.read_env(env_file)
    env_file = Path(ENV("CONTAINER_DATA_DIR")) / ".env"
    if env_file.is_file():
        ENV.read_env(env_file)

LOCAL_ENV_DIR = Path(__file__).resolve().parent / "local_settings"
env_file = LOCAL_ENV_DIR / 'env.local'
if env_file.is_file():
    ENV.read_env(env_file)

for env_file in (Path(i).resolve() for i in ENV.list("ENV_FILES")):
    if env_file.is_file():
        ENV.read_env(env_file)

del env_file
