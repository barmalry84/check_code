#!/usr/bin/env python3

"""
Small framework to manage stack creation with terraform
"""

import argparse
from lib.helpers import Helpers


def appstack():
    """Appstack config"""
    stack_parser = argparse.ArgumentParser(description='appstack automation')
    stack_parser.add_argument('--action',
                              help='action to perform',
                              required=True,
                              choices=['raise', 'destroy'])
    stack_parser.add_argument('--config',
                              help='appstack config file. eg: configuration.json',
                              required=True)
    stack_parser.add_argument('--region',
                              help='AWS Region. eg: us-east-1',
                              required=True)
    stack_parser.add_argument('--service',
                              help='service name',
                              required=True)
    stack_parser.add_argument('--env',
                              help='Environment, eg: dev',
                              required=True)
    stack_parser.add_argument('--version',
                              help='Version of application',
                              required=True)
    stack_parser.add_argument('--stack_definition',
                              help='list of aws resource in order to create separated by ,',
                              required=True)
    args = stack_parser.parse_args()

    return args

def main():
    """ Main """
    args=appstack()
    add_variables = {}

    if args.action == 'raise':
        for item in args.stack_definition.split(","):
            engine = Helpers(args, item, add_variables)
            add_variables.update(engine.create())

    elif args.action == 'destroy':
        for item in args.stack_definition.split(","):
            engine = Helpers(args, item, add_variables)
            engine.destroy()
    else:
        print("Unsupported action!")
        exit(1)

if __name__ == "__main__":
    main()

