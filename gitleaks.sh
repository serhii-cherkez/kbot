#!/bin/bash

# Variables
OSTYPE=$(uname | tr '[:upper:]' '[:lower:]')
HOOK_ENABLED=$(git config --get hooks.pre-commit.enable)

# Function to install gitleaks
install_gitleaks() {
    echo "Installing gitleaks..."
    # Check the OS and install accordingly
    if  [ "$OSTYPE" = "linux" ]; then
        # Linux
        git clone https://github.com/gitleaks/gitleaks.git && cd gitleaks && make build && mv gitleaks /usr/bin/
        cd .. && rm -rf gitleaks
        echo "Gitleaks succesfuly installed"
    elif [ "$OSTYPE" = "darwin" ]; then
        # macOS
        brew install gitleaks
        echo "Gitleaks succesfuly installed"
    else
        echo "Unsupported OS for automatic installation. Please install gitleaks manually."
        exit 1
    fi
}

# Check and install gitleaks
gitleaks() {
if [ -x "$(command -v gitleaks)" ]; then
    echo "Gitleaks is already installed";
else
    install_gitleaks;
    # Create pre-commit file
    cd ./.git/hooks/
    touch pre-commit && chmod +x pre-commit
    cat <<EOF > pre-commit
#!/bin/bash

# Variables
HOOK_ENABLED=$(git config --get hooks.pre-commit.enable)
REPORT_PATCH=$"./gitleaks_report/report.json"
GITLEAKS_OPTS=$"detect --redact --verbose"
LOG_OPTS=$"HEAD~1^..HEAD"

# Run gitleaks
if [ "$HOOK_ENABLED" = "true" ]; then
    echo "Running gitleaks..."
    gitleaks $GITLEAKS_OPTS --report-path $REPORT_PATCH --log-opts $LOG_OPTS;

elif [ "$HOOK_ENABLED" = "false" ]; then
    echo "Pre-commit hook is disabled"
fi
EOF
fi
}

# Check and enable pre-commit hook
hook_enable() {
if [ "$HOOK_ENABLED" != "true" ]; then
    git config hooks.pre-commit.enable true;
      echo "Pre-commit hook succesfuly enabled"
    else
      echo "Pre-commit hook is already enabled"
fi
}

# Check and disable pre-commit hook
hook_disable() {
if [ "$HOOK_ENABLED" != "false" ]; then
      git config hooks.pre-commit.enable false;
      echo "Pre-commit hook succesfuly disabled"
    else
      echo "Pre-commit hook is already disabled"
fi
}

# Main menu
while true; do
    echo "Menu:"
    echo "1. Install Gitleaks and create Pre-commit hook"
    echo "2. Enable Pre-commit hook"
    echo "3. Disable Pre-commit hook"
    echo "4. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            gitleaks
            exit 0
            ;;
        2)
            hook_enable
            exit 0
            ;;
        3)
            hook_disable
            exit 0
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done