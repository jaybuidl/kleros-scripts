

# Function to find the running ssh-agent process and its socket
load_ssh_agent() {
    # Find the PID of the ssh-agent process
    SSH_AGENT_PID=$(ps -u $USER | grep "[s]sh-agent" | awk '{print $2}' | head -n 1)

    # If no ssh-agent process is found, return an error
    if [ -z "$SSH_AGENT_PID" ]; then
        echo "Error: No running ssh-agent process found."
        return 1
    fi

    # Find the socket file associated with the ssh-agent process in a subshell to prevent a directory change
    SSH_AUTH_SOCK=$( (lsof -Ua -p $SSH_AGENT_PID 2>/dev/null | grep 'agent' | awk '{print $NF}') )

    # If no socket file is found, return an error
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "Error: Unable to find the socket file for ssh-agent with PID $SSH_AGENT_PID."
        return 1
    fi

    # Export the environment variables
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID

    echo "Successfully loaded ssh-agent with PID $SSH_AGENT_PID."
    echo "SSH_AUTH_SOCK is set to $SSH_AUTH_SOCK."
    echo "SSH_AGENT_PID is set to $SSH_AGENT_PID."

    return 0
}

# Call the function
if load_ssh_agent; then
    # Verify the setup by listing the keys
    ssh-add -l
else
    exit 1
fi

