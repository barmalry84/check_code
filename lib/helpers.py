import os
from string import Template
import json
import shutil
from .terraform_exec import Terraform

class Helpers(object):
    """JsonParser application & userdata configuration
    """
    def __init__(self, args, module_name, add_variables):
        """ Applicaiton & Userdata Json file parser
            exit if it fails to open/load the json file
        """
        self.helper_args = args
        self.module_name = module_name
        self.add_variables = add_variables
        try:
            with open(self.helper_args.config) as config_file:
                self.config_dict = json.load(config_file)
        except (IOError) as e:
            print(e)
            exit(1)

    def clean_up(self):
        """ Clean terraform module directory before creating run time files.
        """
        print("Deleting .terraform directory from {0}..".format(self.get_module_path()))
        old_state_reference = "{0}/{1}".format(self.get_module_path(), ".terraform")
        state_backup = "{0}/{1}".format(self.get_module_path(), ".terraform.tfstate.backup")
        if os.path.isdir(old_state_reference):
            shutil.rmtree(old_state_reference)
        if os.path.exists(state_backup):
            os.remove(state_backup)

    def app_config(self):
        """Collect application configuration from config_dict.

        rerun : application config dict.
        """
        app_config = {}

        # vars from default
        if 'default' in self.config_dict['default']:
            for key, value in self.config_dict['default']['default'].items():
                app_config[key] = value
        # vars from default regional
        if self.helper_args.region in self.config_dict['default']:
            for key, value in self.config_dict['default'][self.helper_args.region].items():
                app_config[key] = value
        app_config['region'] = self.helper_args.region

        return app_config

    def get_module_path(self):
        """ Get terraform module path"""
        return os.path.abspath("{0}/{1}".format("terraform", self.module_name))

    def create_backend_file(self):
        """Create backend configuration file """
        state_key = "{0}/{1}/{2}.tfstate".format(self.helper_args.env,self.helper_args.version,self.module_name)
        print("State Key: {0}".format(state_key))
        print("Generating backend configuration..")
        values = {
            "backendtype": "s3",
            "bucket": self.app_config()['state_bucket'],
            "key": state_key,
            "region": self.app_config()['state_bucket_region']
        }
        temp = Template("""terraform {\n\tbackend \"$backendtype\" {\n\t\tbucket=\"$bucket\" \
                           \n\t\tkey=\"$key\" \n\t\tregion=\"$region\"\n\t} \n}""")
        backend_config = temp.substitute(values)
        print(self.get_module_path())
        backend_config_file = "{0}/{1}".format(self.get_module_path(),
                                               "backend.tf")
        backend_config_file = os.path.abspath(backend_config_file)
        try:
            print("Writing backend configuration to: {0}".format(backend_config_file))
            with open(backend_config_file, 'w') as config_file:
                config_file.write(backend_config)
            return True
        except OSError as err:
            print(err)
            exit(1)

    def create_tf_file(self, update=None):
        """ Create tf vars file """
        print("Generating tfvars..")
        tfvar_file = "{0}/{1}".format(self.get_module_path(),
                                      self.module_name + ".tfvars")
        with open(tfvar_file, "w") as tfvars:
            for key, value in self.app_config().items():
                if isinstance(value, list):
                    if not value or isinstance(value[0], (int, str)):
                        tfvars.write("{0}={1}\n".format(key, json.dumps(value)))
                    elif isinstance(value[0], dict):
                        # convert to HCL dict
                        hcl_dict = "["
                        for indx, item in enumerate(value):
                            hcl_dict += "\n  {\n"
                            # only dict depth 1 is supported.
                            for key_1, value_1 in item.items():
                                hcl_dict += "    {0}=\"{1}\"\n".format(key_1, value_1)
                            hcl_dict += "  }"
                            if indx < (len(value) - 1):
                                hcl_dict += ","
                        hcl_dict += "\n]"
                        tfvars.write("{0}={1}\n".format(key, hcl_dict))
                    else:
                        print("Unsupported data type at: {0}".format(key))
                        exit(1)
                elif (isinstance(value, str) and "\n" not in value) or isinstance(value, int):
                    tfvars.write("{0}=\"{1}\"\n".format(key, value))
                else:
                    print("Unsupported: Key: {0}, value: {1}".format(key, value))

            for key, value in self.add_variables.items():
                if isinstance(value, list):
                    if not value or isinstance(value[0], (int, str)):
                        tfvars.write("{0}={1}\n".format(key, json.dumps(value)))
                elif (isinstance(value, str) and "\n" not in value) or isinstance(value, int):
                    tfvars.write("{0}=\"{1}\"\n".format(key, value))
                else:
                    print("Unsupported: Key: {0}, value: {1}".format(key, value))
        return True

    @staticmethod
    def parse_output(output):
        """ parse output
        """
        out_dict = {}
        output = output.decode('utf8')
        out_dict = json.loads(output)
        for key, value in out_dict.items():
            out_dict[key] = value['value']
        return out_dict

    @staticmethod
    def show_exec_status(code, err):
        """ Check if terraform run successfull"""
        if code == 0:
            print("Status: Successful.")
        else:
            print(err.decode('utf8'), end='')
            exit(1)

    @staticmethod
    def show_tf_response(code, out, err):
        """ Show terraform response on standard out"""
        print(out.decode('utf8'), end='')
        if code != 0:
            print(err.decode('utf8'), end='')
            exit(1)

    def create(self):
        """ Create resource """
        if self.create_backend_file() and self.create_tf_file():
            print(".tfvars and .backend files are created successfully.")
            self.clean_up()
            terra_form = Terraform(self.module_name, self.get_module_path())
            # terraform init
            code, _, err = terra_form.init()
            self.show_exec_status(code, err)
            # terraform plan
            code, out, err = terra_form.plan()
            self.show_tf_response(code, out, err)
            # terraform apply
            apply_code, _, apply_err = terra_form.apply()
            self.show_exec_status(apply_code, apply_err)
            # output
            output_code, output_out, output_err = terra_form.output()
            self.show_exec_status(output_code, output_err)
            out_dict_utf8 = self.parse_output(output_out)
            print("Output: ", json.dumps(out_dict_utf8, sort_keys=True, indent=4))
        return out_dict_utf8

    def destroy(self):
        """ Destroy resource """
        if self.create_backend_file() and self.create_tf_file():
            print(".backend file created successfully.")
            self.clean_up()
            terra_form = Terraform(self.module_name, self.get_module_path())
            # terraform init
            init_code, _, init_err = terra_form.init()
            self.show_exec_status(init_code, init_err)
            # terraform plan
            dest_code, dest_out, dest_err = terra_form.destroy()
            self.show_tf_response(dest_code, dest_out, dest_err)