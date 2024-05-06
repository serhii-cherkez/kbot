#!/bin/bash

# Variables
OSTYPE=$(uname | tr '[:upper:]' '[:lower:]')

# Function to install gitleaks
install_gitleaks() {
    echo "Installing gitleaks..."
    # Check the OS and install accordingly
    if  [ "$OSTYPE" = "linux" ]; then
        # Linux
        git clone https://github.com/gitleaks/gitleaks.git && cd gitleaks && make build && mv gitleaks /usr/bin/
    elif [ "$OSTYPE" = "darwin" ]; then
        # macOS
        brew install gitleaks
    else
        echo "Unsupported OS for automatic installation. Please install gitleaks manually."
        exit 1
    fi
}

# Check if gitleaks is installed
if [ ! -x "$(command -v gitleaks)" ]; then
    echo "Gitleaks is not installed"
    install_gitleaks;
else
    echo "Gitleaks is already installed"
fi

# Create pre-commit file
cat <<EOF > ./.git/hooks/pre-commit
#!/bin/bash

# Run gitleaks
echo "Running gitleaks..."
if gitleaks detect --verbose --log-opts HEAD~1^..HEAD; then
    echo "No secrets found. Commit allowed."
    exit 0
else
    echo "Secrets found. Commit rejected."
    exit 1
fi
EOF

# Function to enable/disable pre-commit hook
# set_hook_enable() {
#     local enable="$1"
#     if [[ "$enable" == "true" ]]; then
#         git config --local --bool hooks.pre-commit true
#         echo "Pre-commit hook enabled."
#     else
#         git config --local --bool --unset hooks.pre-commit
#         echo "Pre-commit hook disabled."
#     fi
# }

# # Check if pre-commit hook is enabled
# hook_enabled=$(git config --local --get hooks.pre-commit)

# if [[ "$hook_enabled" != "true" ]]; then
#     read -p "Pre-commit hook is not enabled. Do you want to enable it now? (y/n): " enable_choice
#     case "$enable_choice" in
#         y|Y ) set_hook_enable true;;
#         * ) echo "Pre-commit hook not enabled. Exiting..."; exit 1;;
#     esac
# fi