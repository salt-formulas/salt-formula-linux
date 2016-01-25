#!/usr/bin/env bash

set -e
[ -n "$DEBUG" ] && set -x

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
METADATA=${CURDIR}/../metadata.yml
FORMULA_NAME=$(cat $METADATA | python -c "import sys,yaml; print yaml.load(sys.stdin)['name']")

## Overrideable parameters
PILLARDIR=${PILLARDIR:-${CURDIR}/pillar}
BUILDDIR=${BUILDDIR:-${CURDIR}/build}
VENV_DIR=${VENV_DIR:-${BUILDDIR}/virtualenv}
DEPSDIR=${BUILDDIR}/deps

SALT_FILE_DIR=${SALT_FILE_DIR:-${BUILDDIR}/file_root}
SALT_PILLAR_DIR=${SALT_PILLAR_DIR:-${BUILDDIR}/pillar_root}
SALT_CONFIG_DIR=${SALT_CONFIG_DIR:-${BUILDDIR}/salt}
SALT_CACHE_DIR=${SALT_CACHE_DIR:-${SALT_CONFIG_DIR}/cache}

SALT_OPTS="${SALT_OPTS} --retcode-passthrough --local -c ${SALT_CONFIG_DIR}"

if [ "x${SALT_VERSION}" != "x" ]; then
    PIP_SALT_VERSION="==${SALT_VERSION}"
fi

## Functions
log_info() {
    echo "[INFO] $*"
}

log_err() {
    echo "[ERROR] $*" >&2
}

setup_virtualenv() {
    log_info "Setting up Python virtualenv"
    virtualenv $VENV_DIR
    source ${VENV_DIR}/bin/activate
    pip install salt${PIP_SALT_VERSION}
}

setup_pillar() {
    [ ! -d ${SALT_PILLAR_DIR} ] && mkdir -p ${SALT_PILLAR_DIR}
    echo "base:" > ${SALT_PILLAR_DIR}/top.sls
    for pillar in ${PILLARDIR}/*; do
        state_name=$(basename ${pillar%.sls})
        echo -e "  ${state_name}:\n    - ${state_name}" >> ${SALT_PILLAR_DIR}/top.sls
    done
}

setup_salt() {
    [ ! -d ${SALT_FILE_DIR} ] && mkdir -p ${SALT_FILE_DIR}
    [ ! -d ${SALT_CONFIG_DIR} ] && mkdir -p ${SALT_CONFIG_DIR}
    [ ! -d ${SALT_CACHE_DIR} ] && mkdir -p ${SALT_CACHE_DIR}

    echo "base:" > ${SALT_FILE_DIR}/top.sls
    for pillar in ${PILLARDIR}/*.sls; do
        state_name=$(basename ${pillar%.sls})
        echo -e "  ${state_name}:\n    - ${FORMULA_NAME}" >> ${SALT_FILE_DIR}/top.sls
    done

    cat << EOF > ${SALT_CONFIG_DIR}/minion
file_client: local
cachedir: ${SALT_CACHE_DIR}
verify_env: False

file_roots:
  base:
  - ${SALT_FILE_DIR}
  - ${CURDIR}/..

pillar_roots:
  base:
  - ${SALT_PILLAR_DIR}
  - ${PILLARDIR}
EOF
}

fetch_dependency() {
    dep_root="${DEPSDIR}/$(basename $1 .git)"
    dep_metadata="${dep_root}/metadata.yml"

    [ -d $dep_root ] && log_info "Dependency $1 already fetched" && return 0

    log_info "Fetching dependency $1"
    [ ! -d ${DEPSDIR} ] && mkdir -p ${DEPSDIR}
    git clone $1 ${DEPSDIR}/$(basename $1 .git)

    dep_name=$(cat $dep_metadata | python -c "import sys,yaml; print yaml.load(sys.stdin)['name']")
    ln -s ${dep_root}/${dep_name} ${SALT_FILE_DIR}/${dep_name}

    METADATA="${dep_metadata}" install_dependencies
}

install_dependencies() {
    grep -E "^dependencies:" ${METADATA} >/dev/null || return 0
    (python - | while read dep; do fetch_dependency "$dep"; done) << EOF
import sys,yaml
for dep in yaml.load(open('${METADATA}', 'ro'))['dependencies']:
    print dep["source"]
EOF
}

clean() {
    log_info "Cleaning up ${BUILDDIR}"
    [ -d ${BUILDDIR} ] && rm -rf ${BUILDDIR} || exit 0
}

salt_run() {
    source ${VENV_DIR}/bin/activate
    salt-call ${SALT_OPTS} $*
}

prepare() {
    [ -d ${BUILDDIR} ] && mkdir -p ${BUILDDIR}

    setup_virtualenv
    setup_pillar
    setup_salt
    install_dependencies
}

run() {
    for pillar in ${PILLARDIR}/*.sls; do
        state_name=$(basename ${pillar%.sls})
        salt_run --id=${state_name} state.show_sls ${FORMULA_NAME} || (log_err "Execution of ${FORMULA_NAME}.${state_name} failed"; exit 1)
    done
}

_atexit() {
    RETVAL=$?
    trap true INT TERM EXIT

    if [ $RETVAL -ne 0 ]; then
        log_err "Execution failed"
    else
        log_info "Execution successful"
    fi
    return $RETVAL
}

## Main
trap _atexit INT TERM EXIT

case $1 in
    clean)
        clean
        ;;
    prepare)
        prepare
        ;;
    run)
        run
        ;;
    *)
        prepare
        run
        ;;
esac
