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
        echo "Gitleaks succesfuly installed";
    elif [ "$OSTYPE" = "darwin" ]; then
        # macOS
        brew install gitleaks
        echo "Gitleaks succesfuly installed";
    else
        echo "Unsupported OS for automatic installation. Please install gitleaks manually."
        exit 1
    fi
}

# Check and install gitleaks
if [ ! -x "$(command -v gitleaks)" ]; then
    echo "Gitleaks is not installed"
    install_gitleaks;
else
    echo "Gitleaks is already installed"
fi

# Create pre-commit file
cat <<EOF > ./.git/hooks/pre-commit
#!/bin/bash

# Variables
HOOK_ENABLED=$(git config --get hooks.pre-commit.enable)

# Run gitleaks
if [ "$HOOK_ENABLED" = "true" ]; then
    echo "Running gitleaks..."
    gitleaks detect --verbose --log-opts HEAD~1^..HEAD;

elif [ "$HOOK_ENABLED" = "false" ]; then
    echo "Pre-commit hook is disabled."
fi
EOF

# Check and enable pre-commit hook
if [ "$HOOK_ENABLED" != "true" ]; then
    git config hooks.pre-commit.enable true;
      echo "Pre-commit hook succesfuly enabled";
    else
      echo "Pre-commit hook is already enabled"
fi