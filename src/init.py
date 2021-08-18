#!/usr/bin/python

import argparse
import os

from kubernetes import client, config
from kubernetes.client import ApiClient, Configuration

from openshift.dynamic import DynamicClient

parser = argparse.ArgumentParser(description="Options to Program")
parser.add_argument('-n', default="openshift-machine-api", required=False, dest="namespace", help="Namespace to use")
parser.add_argument('-c', default="/config/env/CLUSTERID", required=False, dest="clusteridfile", help="Location to write CLUSTERID")
parser.add_argument('-r', default="/secrets/aws/config.ini", required=False, dest="regionfile", help="Location to write AWS region config.ini")
parser.add_argument('-o', default="/secrets/aws/credentials.ini", required=False, dest="credsfile", help="Location to write AWS credentials.ini")
parser.add_argument('-a', default="/secrets/aws_access_key_id", required=False, dest="accesskeyinfile", help="Source of AWS access key")
parser.add_argument('-A', default="/secrets/aws_secret_access_key", required=False, dest="secretkeyinfile", help="Source of AWS secret key")

args = vars(parser.parse_args())

def ensure_dir(filepath):
    if not os.path.exists(os.path.dirname(filepath)):
        os.makedirs(os.path.dirname(filepath))

def get_cluster_id(dclient, namespace):
    v1b_machines = dclient.resources.get(kind='Machine')
    return v1b_machines.get(namespace=namespace).items[0]['metadata']['labels']['machine.openshift.io/cluster-api-cluster']

def get_region_id(dclient, namespace):
    v1b_machines = dclient.resources.get(kind='Machine')
    return v1b_machines.get(namespace=namespace).items[0]['spec']['providerSpec']['value']['placement']['region']

def write_region_config(dest, regionid):
    ensure_dir(dest)

    with open(dest, 'wb') as cfgfile:
        cfgfile.write('[default]\n')
        cfgfile.write('region = {}\n'.format(regionid))

def write_credentials_file(dest, access_key_id, secret_key_id):
    ensure_dir(dest)

    with open(dest, 'wb') as cfgfile:
        cfgfile.write('[default]\n')
        cfgfile.write('aws_access_key_id = {}\n'.format(access_key_id))
        cfgfile.write('aws_secret_access_key = {}\n'.format(secret_key_id))

def write_cluster_id(dest, clusterid):
    ensure_dir(dest)

    with open(dest, 'wb') as clusterfile:
        clusterfile.write('CLUSTERID="{}"\n'.format(clusterid))

def read_aws_access_key(src):
    ''' Attempt to read the value of the AWS access key
    '''
    f = open(src, 'r')
    return f.readline()

def read_aws_secret_key(src):
    ''' Attempt to read the value of the AWS secret key
    '''
    f = open(src, 'r')
    return f.readline()


incluster = config.load_incluster_config()
k8s_client = ApiClient(incluster)
dclient = DynamicClient(k8s_client)

# Write everything, cos why not?
try:
    access_key = read_aws_access_key(args['accesskeyinfile'])
    secret_key = read_aws_secret_key(args['secretkeyinfile'])
    write_credentials_file(args['credsfile'], access_key, secret_key)
    write_region_config(args['regionfile'], get_region_id(dclient, args['namespace']))
except IOError as err:
    print("Not writing AWS credentials because there aren't any source files.")

write_cluster_id(args['clusteridfile'], get_cluster_id(dclient, args['namespace']))