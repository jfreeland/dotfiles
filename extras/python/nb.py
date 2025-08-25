#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "joblib",
#     "requests",
#     "rich",
# ]
# ///

import json
import os
import sys
from pprint import pprint

import requests
from joblib import Parallel, delayed
from rich.console import Console
from rich.table import Table


def netbox(method="GET", path="", params={}, value=None):
    nb_url = os.getenv("NETBOX_URL")
    nb_token = os.getenv("NETBOX_TOKEN")
    nb_headers = {"Authorization": f"Token {nb_token}", "Accept": "application/json"}
    if method == "GET":
        return requests.get(f"{nb_url}/{path}", headers=nb_headers, params=params)
    elif method == "PATCH":
        return requests.patch(
            f"{nb_url}/{path}", headers=nb_headers, params=params, json=value
        )
    elif method == "DELETE":
        return requests.delete(f"{nb_url}/{path}", headers=nb_headers)
    elif method == "POST":
        nb_headers["Content-Type"] = "application/json"
        return requests.post(f"{nb_url}/{path}", headers=nb_headers, json=value)
    else:
        return None


def get_device(name):
    params = {"name__ic": name}
    devices = netbox(path="/api/dcim/devices/", params=params).json()
    try:
        if devices["count"] == 0:
            devices = netbox(
                path="/api/virtualization/virtual-machines/", params=params
            ).json()
    except:
        print(f"Error getting device: {name}")
        print(devices)
    return devices


if __name__ == "__main__":

    args = sys.argv
    all_devices = []
    if args[1] not in ["patch"]:
        output = Parallel(n_jobs=30, verbose=0, backend="threading")(
            map(delayed(get_device), args)
        )

        for devices in output:
            if devices["count"] > 0:
                all_devices += devices["results"]
        devices_table = [
            [
                "NAME",
                "STATUS",
                "ENV",
                "PURPOSE",
                "PLATFORM",
                "BMC",
                "MODEL",
                "PARENT",
                "K8S CLUSTER",
            ]
        ]
        for device in all_devices:
            # pprint(device)
            row = list()
            row.append(device["name"])
            row.append(device["status"]["label"])
            row.append(device["custom_fields"]["environment"])
            row.append(device["custom_fields"]["purpose"])
            try:
                row.append(device["platform"]["name"])
            except:
                row.append(None)
            if "virtualization" in device["url"]:
                row.append(None)
                row.append("VM")
                row.append(None)
            else:
                row.append(device["custom_fields"]["bmc_ip4"])
                row.append(device["device_type"]["display"])
                try:
                    row.append(device["parent_device"]["display"])
                except:
                    row.append(None)
            row.append(device["custom_fields"]["k8s_cluster"])
            devices_table.append(row)

        # data = sys.stdin.read()
        table = Table(
            box=None,
        )
        header = False
        for row in devices_table:
            if not header:
                for col in row:
                    table.add_column(col)
                header = True
            else:
                table.add_row(*row)
        console = Console()
        console.print(table)
    elif args[1] == "patch":
        patch = json.loads(args[-1])
        for host in range(2, len(args) - 1):
            try:
                print(f"Patching {args[host]} with {args[-1]}")
                device = netbox(
                    path=f"/api/dcim/devices/", params={"name__ic": args[host]}
                ).json()
                id = device["results"][0]["id"]
                result = netbox(
                    method="PATCH", path=f"/api/dcim/devices/{id}/", value=patch
                )
                print(f"{args[host]}: {result.status_code}")
            except:
                print(f"{args[host]}: Error")
