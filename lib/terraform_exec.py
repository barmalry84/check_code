# Terraform executor

import sys
import subprocess

class Terraform:
    """
    Terraform executor
    """
    def __init__(self, aws_resource_name, module_path):
        self.tf_bin = "terraform"
        self.module_path = module_path
        self.tf_vars = "{0}.tfvars".format(aws_resource_name)

    def command_executor(self, command):
        """ Command Executor"""
        sys.stdout.flush()
        print("Terraform Command: {0}".format(command))
        process = subprocess.Popen(command, shell=True,
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   cwd=self.module_path)
        out, err = process.communicate()
        return process.returncode, out, err

    def init(self):
        """ Init """
        command = "{0} {1}".format(self.tf_bin,
                                   "init -force-copy")
        return self.command_executor(command)

    def apply(self):
        """ Apply """
        command = "{0} {1}{2}".format(self.tf_bin,
                                      "apply -input=false -auto-approve -var-file=",
                                      self.tf_vars)
        return self.command_executor(command)

    def plan(self):
        """ Plan """
        command = "{0} {1}{2}".format(self.tf_bin,
                                      "plan -input=false -var-file=",
                                      self.tf_vars)
        return self.command_executor(command)

    def output(self):
        """ Output """
        command = "{0} {1}".format(self.tf_bin,
                                   "output -json")
        return self.command_executor(command)

    def destroy(self):
        """ Destroy """
        command = "{0} {1}{2}".format(self.tf_bin,
                                      "destroy -force -var-file=",
                                      self.tf_vars)
        return self.command_executor(command)