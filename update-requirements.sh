#!/bin/sh

poetry update
poetry export --without-hashes --format requirements.txt --output requirements.txt
exit=$?

