#!/usr/bin/python3

import os
import json
from ssm_parameter_store import EC2ParameterStore
print("settings env from ssm")
#os.environ['SSM_PATHS'] = '["/dev", "/prod"]'
print(json.loads(os.environ.get('SSM_PATHS')))

parameter_store = EC2ParameterStore()
for p in json.loads(os.environ.get('SSM_PATHS')):
    print(p)
    parameters = parameter_store.get_parameters_by_path(p , recursive=True)
    EC2ParameterStore.set_env(parameters)

    for k, v in parameters.items():
        print(f'export {k}={v}')
        with open("/tmp/env.sh", 'a') as f:
            print(f'export {k}={v}', file=f)

#for k, v in os.environ.items():
#    print(f'{k}={v}')   
