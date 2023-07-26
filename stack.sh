#!/bun/sh

#Vars
REPO_URL="https://github.com/mcMEJIA1/skybox-test.git"
CUSTOM_DIR="SkyBox-stack"


#Functions 

install() {
    if [ -d "$CUSTOM_DIR" ]; then
        cd "$CUSTOM_DIR"
        git pull origin main
    else
        git clone "$REPO_URL" "$CUSTOM_DIR"
        cd "$CUSTOM_DIR"
    fi
}

run() {
    if [ -d "$CUSTOM_DIR" ]; then
        cd "$CUSTOM_DIR"
        terraform init
        terraform apply --auto-approve
    else
        install
        terraform init
        terraform apply --auto-approve
}

destroy() {
    cd "$CUSTOM_DIR"
    terraform destroy --auto-approve
}

status() {
    cd "$CUSTOM_DIR"
    terraform show
}

case "$1" in 
    install)
        install
        ;;
    run)
        run
        ;;
    destroy)
        destroy
        ;;
    status)
        status
        ;;
    *)
    echo "Usage: $0 (install|run|destroy|status)"
    exit 1
esac

exit 0