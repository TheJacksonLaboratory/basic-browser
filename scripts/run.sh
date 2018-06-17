#!/bin/bash
exec supervisord -n
exec "$@";
