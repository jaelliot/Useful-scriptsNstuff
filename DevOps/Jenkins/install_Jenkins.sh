#!/usr/bin/env bash
# Title: Jenkins Installer
# Description: This script automates the installation or reinstallation of Jenkins and its dependencies (Java, Maven, Git, Curl) on Debian-based systems. It checks if Jenkins is already installed and prompts the user for uninstallation before proceeding with a fresh installation.
# Author: Jay-Alexander Elliot
# Date: 2024-01-23
# Usage: Run this script with root privileges. Usage: sudo ./jenkins_installer.sh

# Function to prompt the user before uninstalling Jenkins
ask_before_uninstall() {
    read -p "Do you want to uninstall Jenkins? (y/n) " check_ans
    case "$check_ans" in
        [Yy]* )
            sudo apt-get remove -y jenkins
            sudo apt-get purge -y jenkins
            clear
            echo "Previous Jenkins version uninstalled"
            echo
            sleep 2
            ;;
        [Nn]* )
            clear
            echo "Skipping uninstallation of previous Jenkins version"
            exit
            ;;
        * )
            clear
            echo "Invalid input, please enter y or n"
            ask_before_uninstall
            ;;
    esac
}

# Function to install Jenkins and its dependencies
install_jenkins() {
    # Update the package list
    sudo apt update

    # Install Java and set JAVA_HOME
    sudo apt install -y openjdk-11-jdk
    echo 'JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"' | sudo tee /etc/profile.d/jdk.sh
    source /etc/profile.d/jdk.sh
    clear
    java -version
    echo
    echo "Java is installed & configured"
    echo
    sleep 2

    # Install Maven
    sudo apt install -y maven
    clear
    mvn --version
    echo
    echo "Maven is installed"
    echo
    sleep 2

    # Install Git
    sudo apt install -y git
    clear
    git --version
    echo "Git is installed"
    echo
    sleep 2

    # Install Curl
    sudo apt install -y curl
    clear
    curl --version
    echo "Curl is installed"
    echo
    sleep 1

    # Install Jenkins
    echo "Installing Jenkins"
    echo
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-archive-keyring.gpg >/dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-archive-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
    sudo apt update
    sudo apt install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins

    clear 
    echo "Jenkins is now up & running :)"
    echo 
    echo "You can check its state with the following command:"
    echo "sudo systemctl status jenkins"
    echo 
    echo "To open the web browser, navigate to the Jenkins URL:"
    echo "http://<ip>:8080/ or http://localhost:8080/"
}

# Check if Jenkins is installed and decide the action based on it
check_jenkins() {
    if [ -x "$(command -v jenkins)" ]; then
        echo "Jenkins is already installed"
        echo
        ask_before_uninstall
    else
        install_jenkins
    fi
}

# Start the script by checking if Jenkins is installed
check_jenkins
