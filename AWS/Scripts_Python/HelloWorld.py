#!/usr/local/bin/python3.6

import boto3
import json
from pprint import pprint,pformat

def hello (v):
    print("hello world!" + v)

hello("super yann")

def hellobis(liste):
    for element in liste.values():
        print(element)

maliste = []
maliste = ["hello","world"]
maliste.append("!")

mon_dict = {}
mon_dict = {
    "valeur1": "hello",
    "valeur2": "world"
}
mon_dict['valeur3'] = "!"

hellobis(mon_dict)

pprint(mon_dict)
print(json.dumps(mon_dict))

try:
    hello(toto)
except Exception,erreur:
    print("une erreur s'est produite")
    print(str(erreur))
print("fin du script")
