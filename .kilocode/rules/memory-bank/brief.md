# Dotfiles Project Description

## Overview

This repository contains a comprehensive personal development environment configuration using Nix flakes for reproducible, cross-platform system management. It provides declarative configuration for both macOS (via nix-darwin/home-manager) and Linux (via home-manager) systems.

## Main Objectives

- **Reproducible Environments**: Ensure consistent development setup across different machines and operating systems
- **Declarative Configuration**: Manage system configuration, applications, and dotfiles through code
- **Cross-Platform Support**: Unified configuration for macOS and Linux environments
- **Development Productivity**: Streamlined setup for software development workflows

## Key Features

### System Management

- **Nix Flakes**: Modern Nix configuration with flake.nix for dependency management
- **nix-darwin**: macOS system configuration and package management
- **Home Manager**: User environment and dotfile management
- **Modular Architecture**: Separated configurations for different tools and services

### Development Tools

- **Version Control**: Comprehensive Git configuration with productivity aliases
- **Editor Setup**: Full Vim configuration with extensive plugin ecosystem
- **Shell Environment**: Zsh with custom prompts, completions, and integrations
- **Container Tools**: Docker, development containers, and related utilities
- **Development Utilities**: GitHub CLI, DevBox, 1Password CLI, and custom scripts

### Infrastructure & DevOps

- **Database Tools**: PostgreSQL, SQLite, MySQL configurations
- **AI/ML Tools**: Qdrant vector database, Ollama for local LLMs
- **Networking**: Wake-on-LAN, VPN configurations
- **System Monitoring**: Custom CPU and load monitoring scripts

### Configuration Management

- **FZF Integration**: Fuzzy finder with shell and tmux integration
- **Direnv**: Automatic environment loading for project directories
- **MCPM**: Multi-Cloud Package Manager configuration
- **Terminal Multiplexing**: Tmux configuration for session management
- **Kilocode Integration**: VS Code extension with MCP servers and rule file management

## Technologies Used

### Core Technologies

- **Nix/NixOS**: Functional package manager and Linux distribution
- **Nix Flakes**: Modern Nix configuration system
- **Home Manager**: Declarative user environment management
- **nix-darwin**: Nix-based macOS system configuration

### Development Stack

- **Shell**: Zsh with custom configurations
- **Editor**: Vim with comprehensive plugin setup
- **Version Control**: Git with productivity-focused aliases
- **Terminal**: Tmux for session management
- **Package Management**: Nix packages with custom shell applications

### Supporting Tools

- **DevBox**: Development environment isolation
- **Direnv**: Environment variable management
- **FZF**: Command-line fuzzy finder
- **Poetry**: Python dependency management
- **Various CLI Tools**: ripgrep, bat, jq, htop, and more

## Project Structure

- **`home/`**: Home Manager configurations for user environment
- **`hosts/`**: Host-specific configurations for different machines
- **`config/`**: Application-specific configuration files
- **`nix/`**: Core Nix system configurations
- **`lib/`**: Custom Nix library functions for configuration generation
- **`bin/`**: Custom shell scripts and utilities

## Significance

This project represents a modern approach to dotfiles management, leveraging Nix's strengths in reproducibility and declarative configuration. It eliminates the traditional complexity of setting up development environments across multiple machines and operating systems, providing a single source of truth for personal computing setup. The modular design allows for easy customization while maintaining consistency and reliability across different environments.
