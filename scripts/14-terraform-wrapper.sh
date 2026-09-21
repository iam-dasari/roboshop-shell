#!/usr/bin/env bash

set -Eeuo pipefail

ENVIRONMENT="${2:-}"

TERRAFORM_DIR="terraform/environments"

if [[ -z "$ENVIRONMENT" ]]; then
    echo "Usage:"
    echo "$0 <command> <environment>"
    echo
    echo "Commands:"
    echo "  init"
    echo "  validate"
    echo "  plan"
    echo "  apply"
    echo "  destroy"
    exit 1
fi

TF_DIR="${TERRAFORM_DIR}/${ENVIRONMENT}"

if [[ ! -d "$TF_DIR" ]]; then
    echo "ERROR: Terraform environment not found:"
    echo "$TF_DIR"
    exit 1
fi

COMMAND="${1:-}"

echo "======================================"
echo " Terraform Wrapper"
echo "======================================"
echo "Environment: $ENVIRONMENT"
echo "Directory  : $TF_DIR"
echo

case "$COMMAND" in

    init)

        terraform -chdir="$TF_DIR" init
        ;;

    validate)

        terraform -chdir="$TF_DIR" fmt -check
        terraform -chdir="$TF_DIR" validate
        ;;

    plan)

        terraform -chdir="$TF_DIR" init
        terraform -chdir="$TF_DIR" validate
        terraform -chdir="$TF_DIR" plan
        ;;

    apply)

        terraform -chdir="$TF_DIR" init
        terraform -chdir="$TF_DIR" validate

        terraform -chdir="$TF_DIR" plan

        read -r -p "Apply Terraform changes? [y/N]: " CONFIRM

        if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
            terraform -chdir="$TF_DIR" apply
        else
            echo "Apply cancelled."
        fi
        ;;

    destroy)

        echo "WARNING: This will destroy infrastructure."

        read -r -p "Type DESTROY to continue: " CONFIRM

        if [[ "$CONFIRM" == "DESTROY" ]]; then
            terraform -chdir="$TF_DIR" destroy
        else
            echo "Destroy cancelled."
        fi
        ;;

    *)

        echo "ERROR: Unknown command: $COMMAND"
        exit 1
        ;;

esac

#Usage: ./14-terraform-wrapper.sh apply dev