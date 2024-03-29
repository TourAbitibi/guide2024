"""Vérifier si les waypoints des fichiers GPX de signalisation sont les mêmes que dans le fichier de signalisation.xlsx

    Returns:
        Pytest : Impression des différences
    
"""

import re
import warnings
from typing import List

import gpxpy
import pandas as pd
from rich import print

warnings.filterwarnings("ignore", category=UserWarning, module="openpyxl")


def read_wp_gpx(file: str) -> List[str]:
    """Lire les informations des GPX

    Args:
        file (str): Nom du fichier GPX à lire

    Returns:
        List[str]: Listes des waypoints
    """

    list_wp = []

    gpx_file = open(file, "r")

    gpx = gpxpy.parse(gpx_file)

    for waypoint in gpx.waypoints:
        if re.search(r"^s", waypoint.name):
            list_wp.append(waypoint.name)

    list_wp.sort()

    return list_wp


def read_signalisation_column(onglet: str) -> List[str]:
    """Lire la colonne des id de signalisation dans le fichier Excel

    Args:
        onglet (str): Nom de l'onglet (étape)

    Returns:
        List[str]: Liste des id de signalisation
    """

    excel_file = "excel/signalisation.xlsx"

    df = pd.read_excel(io=excel_file, sheet_name=onglet, usecols=["uniq_id"])

    list_sign = df.uniq_id.tolist()
    list_sign.sort()

    return list_sign


def test_waypoint_signalisation() -> None:
    """Tester si les waypoints de signalisation sont les mêmes que dans le fichier Excel de signalisation"""
    for etape in range(1, 8):
        xmlfile: str = f"gpx/input/Signalisation_{etape}.gpx"

        list_wp: List[str] = read_wp_gpx(file=xmlfile)

        list_sign_excel: List[str] = read_signalisation_column(onglet=f"Etape{etape}")

        if list_sign_excel != list_wp:
            print(f"--- Étape {etape} ---")
            # print("WP :", list_wp)
            # print("Sign :", list_sign_excel)

            # Vérifier les différences
            diff1: List[str] = [item for item in list_wp if item not in list_sign_excel]
            diff2: List[str] = [item for item in list_sign_excel if item not in list_wp]

            if diff1:
                print("Dans le GPX mais pas dans Excel : ", diff1)
            if diff2:
                print("Dans le Excel mais pas dans le GPX", diff2)

        # Test pour pytest
        assert (
            list_sign_excel == list_wp
        ), f"Étape {etape} : Les deux listes sont différentes"


if __name__ == "__main__":
    try:
        test_waypoint_signalisation()
    except AssertionError as e:
        print(e)
