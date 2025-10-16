import os
import sys

# Get project root path. 
PROJECT_PATH=os.environ.get("PROJECT_PATH")
DFST_PATH=os.environ.get("DFST_PATH")


# Determine project runtime mode.
PROJECT_RUNTIME_MODE=os.environ.get("PROJECT_RUNTIME_MODE")

# Load .env files. 
VARS_PATH=f"{PROJECT_PATH}/setup/vars"
ENV_FILES = [
    f"{VARS_PATH}/.env",
    f"{VARS_PATH}/.env.{PROJECT_RUNTIME_MODE}", 
    f"{VARS_PATH}/.env.final",
    f"{DFST_PATH}/.env"
]

# Load compose files.
SERVICES_PATH = f"{PROJECT_PATH}/setup/services/{PROJECT_RUNTIME_MODE}"

COMPOSE_FILES = [
    f"{SERVICES_PATH}/docker-compose.yml"
]

SERVICES = [
    FILE for FILE in os.listdir(SERVICES_PATH) 
    if not os.path.isfile(os.path.join(SERVICES_PATH, FILE))
]

for SERVICE in SERVICES: 
    COMPOSE_PATH=f"{SERVICES_PATH}/{SERVICE}/compose.yml"
    if not os.path.exists(COMPOSE_PATH):
        continue 
    COMPOSE_FILES.append(COMPOSE_PATH)
    

# Run docker command. 
ENV_ARGS = ["--env-file " + FILE for FILE in ENV_FILES]
COMPOSE_FILES_ARGS = ["-f " + FILE for FILE in COMPOSE_FILES]

# Command parts.
ENV_ARG_STR = " ".join(ENV_ARGS)
COMPOSE_ARGS_STR = " ".join(COMPOSE_FILES_ARGS)

ENV_ARG_STR += " " + os.environ.get("COMPOSE_EXTRA_ENV_FILES", "")
COMPOSE_ARGS_STR += " " + os.environ.get("COMPOSE_EXTRA_CONFIG_FILES", "")

COMMAND = (
    "docker compose " +
    ENV_ARG_STR + " " +
    COMPOSE_ARGS_STR  + " " +
    " ".join(sys.argv[1:])
)

os.system(COMMAND)