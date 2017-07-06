#!/usr/bin/env bash

###
# Script requirments:
#apt-get install -y python-yaml virtualenv git

__ScriptVersion="2018.08.16"
__ScriptName="run_tests.sh"
__ScriptFullName="$0"
__ScriptArgs="$*"

set -e
[ -n "$DEBUG" ] && set -x

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
METADATA=${CURDIR}/../metadata.yml
FORMULA_NAME=$(cat $METADATA | python -c "import sys,yaml; print yaml.load(sys.stdin)['name']")
FORMULA_META_DIR=${CURDIR}/../${FORMULA_NAME}/meta

## Overrideable parameters
PILLARDIR=${PILLARDIR:-${CURDIR}/pillar}
BUILDDIR=${BUILDDIR:-${CURDIR}/build}
VENV_DIR=${VENV_DIR:-${BUILDDIR}/virtualenv}
MOCK_BIN_DIR=${MOCK_BIN_DIR:-${CURDIR}/mock_bin}
DEPSDIR=${BUILDDIR}/deps
SCHEMARDIR=${SCHEMARDIR:-"${CURDIR}/../${FORMULA_NAME}/schemas/"}

SALT_FILE_DIR=${SALT_FILE_DIR:-${BUILDDIR}/file_root}
SALT_PILLAR_DIR=${SALT_PILLAR_DIR:-${BUILDDIR}/pillar_root}
SALT_CONFIG_DIR=${SALT_CONFIG_DIR:-${BUILDDIR}/salt}
SALT_CACHE_DIR=${SALT_CACHE_DIR:-${SALT_CONFIG_DIR}/cache}
SALT_CACHE_EXTMODS_DIR=${SALT_CACHE_EXTMODS_DIR:-${SALT_CONFIG_DIR}/cache_master_extmods}

SALT_OPTS="${SALT_OPTS} --retcode-passthrough --local -c ${SALT_CONFIG_DIR} --log-file=/dev/null"

IGNORE_MODELVALIDATE_MASK=${IGNORE_MODELVALIDATE_MASK:-"novalidate"}

if [ "x${SALT_VERSION}" != "x" ]; then
    PIP_SALT_VERSION="==${SALT_VERSION}"
fi

## Functions
log_info() {
    echo -e "[INFO] $*"
}

log_err() {
    echo -e "[ERROR] $*" >&2
}

setup_virtualenv() {
    log_info "Setting up Python virtualenv"
    dependency_check virtualenv
    virtualenv $VENV_DIR
    source ${VENV_DIR}/bin/activate
    python -m pip install salt${PIP_SALT_VERSION}
    if [[ -f ${CURDIR}/test-requirements.txt ]]; then
       python -m pip install -r ${CURDIR}/test-requirements.txt
    fi
}

setup_mock_bin() {
    # If some state requires a binary, a lightweight replacement for
    # such binary can be put into MOCK_BIN_DIR for test purposes
    if [ -d "${MOCK_BIN_DIR}" ]; then
        PATH="${MOCK_BIN_DIR}:$PATH"
        export PATH
    fi
}

setup_pillar() {
    [ ! -d ${SALT_PILLAR_DIR} ] && mkdir -p ${SALT_PILLAR_DIR}
    echo "base:" > ${SALT_PILLAR_DIR}/top.sls
    for pillar in ${PILLARDIR}/*; do
        grep ${FORMULA_NAME}: ${pillar} &>/dev/null || continue
        state_name=$(basename ${pillar%.sls})
        echo -e "  ${state_name}:\n    - ${state_name}" >> ${SALT_PILLAR_DIR}/top.sls
    done
}

setup_salt() {
    [ ! -d ${SALT_FILE_DIR} ] && mkdir -p ${SALT_FILE_DIR}
    [ ! -d ${SALT_CONFIG_DIR} ] && mkdir -p ${SALT_CONFIG_DIR}
    [ ! -d ${SALT_CACHE_DIR} ] && mkdir -p ${SALT_CACHE_DIR}
    [ ! -d ${SALT_CACHE_EXTMODS_DIR} ] && mkdir -p ${SALT_CACHE_EXTMODS_DIR}

    echo "base:" > ${SALT_FILE_DIR}/top.sls
    for pillar in ${PILLARDIR}/*.sls; do
        grep ${FORMULA_NAME}: ${pillar} &>/dev/null || continue
        state_name=$(basename ${pillar%.sls})
        echo -e "  ${state_name}:\n    - ${FORMULA_NAME}" >> ${SALT_FILE_DIR}/top.sls
    done

    cat << EOF > ${SALT_CONFIG_DIR}/minion
file_client: local
cachedir: ${SALT_CACHE_DIR}
extension_modules:  ${SALT_CACHE_EXTMODS_DIR}
verify_env: False
minion_id_caching: False

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
    # example: fetch_dependency "linux:https://github.com/salt-formulas/salt-formula-linux"
    dep_name="$(echo $1|cut -d : -f 1)"
    dep_source="$(echo $1|cut -d : -f 2-)"
    dep_root="${DEPSDIR}/$(basename $dep_source .git)"
    dep_metadata="${dep_root}/metadata.yml"

    dependency_check git
    [ -d $dep_root ] && { log_info "Dependency $dep_name already fetched"; return 0; }

    log_info "Fetching dependency $dep_name"
    [ ! -d ${DEPSDIR} ] && mkdir -p ${DEPSDIR}
    git clone $dep_source ${DEPSDIR}/$(basename $dep_source .git)
    ln -s ${dep_root}/${dep_name} ${SALT_FILE_DIR}/${dep_name}

    METADATA="${dep_metadata}" install_dependencies
}

link_modules(){
    # Link modules *.py files to temporary salt-root
    local SALT_ROOT=${1:-$SALT_FILE_DIR}
    local SALT_ENV=${2:-$DEPSDIR}

    mkdir -p "${SALT_ROOT}/_modules/"
    # from git, development versions
    find ${SALT_ENV} -maxdepth 3 -mindepth 3 -path '*_modules*' -iname "*.py" -type f -print0 | while read -d $'\0' file; do
      ln -fs $(readlink -e ${file}) "$SALT_ROOT"/_modules/$(basename ${file}) ;
    done
    salt_run saltutil.sync_all
}

install_dependencies() {
    grep -E "^dependencies:" ${METADATA} >/dev/null || return 0
    (python - | while read dep; do fetch_dependency "$dep"; done) << EOF
import sys,yaml
for dep in yaml.load(open('${METADATA}', 'ro'))['dependencies']:
    print '%s:%s' % (dep["name"], dep["source"])
EOF
}

clean() {
    log_info "Cleaning up ${BUILDDIR}"
    [ -d ${BUILDDIR} ] && rm -rf ${BUILDDIR} || exit 0
}

salt_run() {
    [ -e ${VENV_DIR}/bin/activate ] && source ${VENV_DIR}/bin/activate
    python $(which salt-call) ${SALT_OPTS} $*
}

prepare() {
    if [[ -f ${BUILDDIR}/.prepare_done ]]; then
      log_info "${BUILDDIR}/.prepare_done exist, not rebuilding BUILDDIR"
      return
    fi
    [[ -d ${BUILDDIR} ]] && mkdir -p ${BUILDDIR}

    [[ ! -f "${VENV_DIR}/bin/activate" ]] && setup_virtualenv
    setup_mock_bin
    setup_pillar
    setup_salt
    install_dependencies
    link_modules
    touch ${BUILDDIR}/.prepare_done
}

lint_releasenotes() {
    [[ ! -f "${VENV_DIR}/bin/activate" ]] && setup_virtualenv
    source ${VENV_DIR}/bin/activate
    reno lint ${CURDIR}/../
}

lint() {
#    lint_releasenotes
    log_err "TODO: lint_releasenotes"
}

run() {
    for pillar in ${PILLARDIR}/*.sls; do
        grep ${FORMULA_NAME}: ${pillar} &>/dev/null || continue
        state_name=$(basename ${pillar%.sls})
        salt_run grains.set 'noservices' False force=True

        echo "Checking state ${FORMULA_NAME}.${state_name} ..."
        salt_run --id=${state_name} state.show_sls ${FORMULA_NAME} || (log_err "Execution of ${FORMULA_NAME}.${state_name} failed"; exit 1)

        # Check that all files in 'meta' folder can be rendered using any valid pillar
        for meta in `find ${FORMULA_META_DIR} -type f`; do
            meta_name=$(basename ${meta})
            echo "Checking meta ${meta_name} ..."
            salt_run --out=quiet --id=${state_name} cp.get_template ${meta} ${SALT_CACHE_DIR}/${meta_name} \
              || { log_err "Failed to render meta ${meta} using pillar ${FORMULA_NAME}.${state_name}"; exit 1; }
            cat ${SALT_CACHE_DIR}/${meta_name}
        done
    done
}

real_run() {
    for pillar in ${PILLARDIR}/*.sls; do
        state_name=$(basename ${pillar%.sls})
        salt_run --id=${state_name} state.sls ${FORMULA_NAME} || { log_err "Execution of ${FORMULA_NAME}.${state_name} failed"; exit 1; }
    done
}

run_model_validate(){
  # Run modelschema.model_validate validation.
  # TEST iterateble, run for `each formula ROLE against each ROLE_PILLARNAME`
  # Pillars should be named in conviend ROLE_XXX.sls or ROLE.sls
  # Example:
  # client.sls  client_auth.sls  server.sls  server_auth.sls
  if [ -d ${SCHEMARDIR} ]; then
    # model validator require py modules
    fetch_dependency "salt:https://github.com/salt-formulas/salt-formula-salt"
    link_modules
    salt_run saltutil.clear_cache; salt_run saltutil.refresh_pillar; salt_run saltutil.sync_all;
    for role in ${SCHEMARDIR}/*.yaml; do
      role_name=$(basename "${role%*.yaml}")
      for pillar in $(ls pillar/${role_name}*.sls | grep -v ${IGNORE_MODELVALIDATE_MASK} ); do
        pillar_name=$(basename "${pillar%*.sls}")
        local _message="FORMULA:${FORMULA_NAME} ROLE:${role_name} against PILLAR:${pillar_name}"
        log_info "model_validate ${_message}"
        # Rendered Example:
        # python $(which salt-call) --local -c /test1/maas/tests/build/salt --id=maas_cluster modelschema.model_validate maas cluster
        salt_run -m ${DEPSDIR}/salt-formula-salt --id=${pillar_name} modelschema.model_validate ${FORMULA_NAME} ${role_name} || { log_err "Execution of model_validate ${_message} failed"; exit 1 ; }
      done
    done
  else
    log_info "${SCHEMARDIR} not found!";
  fi
}

dependency_check() {
  local DEPENDENCY_COMMANDS=$*

  for DEPENDENCY_COMMAND in $DEPENDENCY_COMMANDS; do
    which $DEPENDENCY_COMMAND > /dev/null || ( log_err "Command \"$DEPENDENCY_COMMAND\" can not be found in default path."; exit 1; )
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

log_info "Running version: ${__ScriptVersion}"
log_info "Command line: '${__ScriptFullName} ${__ScriptArgs}'"

trap _atexit INT TERM EXIT

case $1 in
    clean)
        clean
        ;;
    prepare)
        prepare
        ;;
    lint)
        lint
        ;;
    run)
        run
        ;;
    real-run)
        real_run
        ;;
    model-validate)
       prepare
       run_model_validate
        ;;
    *)
        prepare
#        lint
        run
        run_model_validate
        ;;
esac
